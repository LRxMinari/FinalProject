// index.js
console.log("Starting functions module...");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const fs = require("fs");
const path = require("path");
const axios = require("axios");
const PNG = require("pngjs").PNG;
const sharp = require("sharp");

admin.initializeApp({
  storageBucket: "practice-writing-app-c6bd8.firebasestorage.app",
});
console.log("Firebase admin initialized.");

// โหลด pixelmatch แบบ dynamic import (ถ้าต้องการใช้ debug additional image diff)
let pixelmatch;
(async () => {
  try {
    const imported = await import("pixelmatch");
    pixelmatch = imported.default;
    console.log("pixelmatch loaded successfully.");
  } catch (error) {
    console.error("Failed to load pixelmatch:", error);
  }
})();

/**
 * saveMask: สร้าง PNG จาก mask (Uint8Array) และบันทึกลงใน /tmp/
 */
function saveMask(mask, width, height, filename) {
  const outputPath = `/tmp/${filename}`;
  const png = new PNG({ width, height });
  for (let i = 0; i < mask.length; i++) {
    const val = mask[i] * 255; // แปลง 0/1 เป็น 0/255
    png.data[i * 4] = val; // R
    png.data[i * 4 + 1] = val; // G
    png.data[i * 4 + 2] = val; // B
    png.data[i * 4 + 3] = 255; // A
  }
  return new Promise((resolve, reject) => {
    png
      .pack()
      .pipe(fs.createWriteStream(outputPath))
      .on("finish", () => {
        console.log("Saved mask to", outputPath);
        resolve(outputPath);
      })
      .on("error", (err) => {
        console.error("Error saving mask:", err);
        reject(err);
      });
  });
}

/**
 * uploadFile: อัปโหลดไฟล์จาก localPath ไปยัง Cloud Storage ใน bucket
 */
async function uploadFile(localPath, destinationPath) {
  const bucket = admin.storage().bucket();
  await bucket.upload(localPath, {
    destination: destinationPath,
    metadata: { contentType: "image/png" },
  });
  console.log("Uploaded", localPath, "to", destinationPath);
  fs.unlink(localPath, (err) => {
    if (err) console.error("Error deleting local file:", err);
    else console.log("Deleted local file", localPath);
  });
  return `gs://${bucket.name}/${destinationPath}`;
}

// ตรวจสอบว่ามีไฟล์ template อยู่หรือไม่
function isValidTemplateFile(fileName, language) {
  const templateFolder = path.join(__dirname, "templates", language);
  if (!fs.existsSync(templateFolder)) return false;
  const templateFiles = fs.readdirSync(templateFolder);
  return templateFiles.includes(fileName);
}

// สกัดตัวอักษรจากชื่อไฟล์ เช่น "A.png" หรือ "ก.jpg"
function getCharacterFromFileName(fileName) {
  return path.basename(fileName, path.extname(fileName));
}

// แปลงชื่อไฟล์จากผู้ใช้ (เช่น "writing_A.png") ให้เป็นชื่อ template (เช่น "A.png")
function getTemplateFileName(userFileName) {
  const prefix = "writing_";
  if (userFileName.startsWith(prefix)) {
    return userFileName.slice(prefix.length);
  }
  return userFileName;
}

// Cloud Function evaluateWriting โดยใช้ไฟล์ Mask แยกจาก Template
exports.evaluateWriting = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }
    const { uid, language, fileName, imageUrl } = req.body;
    if (!uid || !language || !fileName || !imageUrl) {
      return res.status(400).send("Missing required parameters");
    }
    // แปลงชื่อ template และ mask
    const templateFileName = getTemplateFileName(fileName);
    if (!isValidTemplateFile(templateFileName, language)) {
      return res.status(404).send("Template image not found");
    }
    // สมมติว่าไฟล์ mask มีชื่อว่า "<ตัวอักษร>_mask.png" เช่น "A_mask.png"
    const maskFileName =
      getCharacterFromFileName(templateFileName) + "_mask.png";
    const maskFilePath = path.join(
      __dirname,
      "templates",
      language,
      maskFileName
    );
    if (!fs.existsSync(maskFilePath)) {
      return res.status(404).send("Template mask file not found");
    }

    // ดาวน์โหลดภาพผู้ใช้
    const response = await axios.get(imageUrl, { responseType: "arraybuffer" });
    const userImageBuffer = Buffer.from(response.data, "binary");

    // สำหรับ template: อ่านไฟล์ template (จะใช้เพื่อครอปภาพ template)
    const templateImagePath = path.join(
      __dirname,
      "templates",
      language,
      templateFileName
    );
    const templateBuffer = fs.readFileSync(templateImagePath);

    // Preprocessing Template:
    // Resize ด้วย fit: "contain" ให้ targetWidth=370 แล้ว trim() เพื่อลบขอบสีขาวออก
    const targetWidth = 370;
    const processedTemplateBufferInitial = await sharp(templateBuffer)
      .resize(targetWidth, null, {
        fit: "contain",
        background: { r: 255, g: 255, b: 255 },
      })
      .toBuffer();
    const trimmedTemplateBuffer = await sharp(processedTemplateBufferInitial)
      .trim()
      .toBuffer();
    // ครอปเฉพาะส่วนตัวอักษร (สมมติอยู่ด้านซ้าย 60% ของภาพหลัง trim)
    const templateMeta = await sharp(trimmedTemplateBuffer).metadata();
    const cropWidth = Math.floor(templateMeta.width * 0.6);
    const croppedTemplateBuffer = await sharp(trimmedTemplateBuffer)
      .extract({
        left: 0,
        top: 0,
        width: cropWidth,
        height: templateMeta.height,
      })
      .toBuffer();

    // Preprocessing User:
    // Resize ด้วย fit: "contain" ให้ targetWidth=370 แล้ว trim()
    const processedUserBufferInitial = await sharp(userImageBuffer)
      .resize(targetWidth, null, {
        fit: "contain",
        background: { r: 255, g: 255, b: 255 },
      })
      .toBuffer();
    const trimmedUserBuffer = await sharp(processedUserBufferInitial)
      .trim()
      .toBuffer();

    // Resize ทั้งสองภาพให้มีขนาด common size 300x300 ด้วย fit: "fill"
    const commonWidth = 300;
    const commonHeight = 300;
    // สำหรับ template mask: โหลดไฟล์ mask ที่เตรียมไว้ล่วงหน้า
    const { data: templateMaskData, info: templateMaskInfo } = await sharp(
      maskFilePath
    )
      .resize(commonWidth, commonHeight, { fit: "fill" })
      .grayscale()
      .threshold(128) // ได้ผลลัพธ์เป็น binary mask (0/255)
      .raw()
      .toBuffer({ resolveWithObject: true });
    // แปลงข้อมูล mask ให้เป็น array แบบ 0/1
    let finalTemplateMask = new Uint8Array(
      templateMaskInfo.width * templateMaskInfo.height
    );
    for (let i = 0; i < templateMaskData.length; i++) {
      finalTemplateMask[i] = templateMaskData[i] >= 128 ? 1 : 0;
    }

    // สำหรับ user: แปลงเป็น grayscale + threshold (threshold 70)
    const { data: userRawData, info: userInfo } = await sharp(trimmedUserBuffer)
      .resize(commonWidth, commonHeight, { fit: "fill" })
      .grayscale()
      .threshold(70)
      .raw()
      .toBuffer({ resolveWithObject: true });
    let userMask = new Uint8Array(userRawData.length);
    for (let i = 0; i < userRawData.length; i++) {
      userMask[i] = userRawData[i] < 128 ? 1 : 0;
    }

    // (สำหรับ debug) Save mask files ขึ้น Cloud Storage
    const templateMaskLocalPath = await saveMask(
      finalTemplateMask,
      templateMaskInfo.width,
      templateMaskInfo.height,
      "templateMask_debug.png"
    );
    const userMaskLocalPath = await saveMask(
      userMask,
      userInfo.width,
      userInfo.height,
      "userMask_debug.png"
    );
    await uploadFile(templateMaskLocalPath, `debug/templateMask_debug.png`);
    await uploadFile(userMaskLocalPath, `debug/userMask_debug.png`);

    // คำนวณคะแนนโดยการคำนวณการ overlap ของ finalTemplateMask กับ userMask
    let intersection = 0;
    let templateSum = 0;
    for (let i = 0; i < finalTemplateMask.length; i++) {
      templateSum += finalTemplateMask[i];
      if (finalTemplateMask[i] === 1 && userMask[i] === 1) {
        intersection++;
      }
    }
    let finalScore = 0;
    if (templateSum > 0) {
      finalScore = (intersection / templateSum) * 100;
    }

    // ตีความคะแนนและให้ recommendation
    let status = "OK";
    let recommendation = "";
    if (finalScore >= 90) {
      recommendation = "ยอดเยี่ยม! งานเขียนของคุณน่ารักมาก เหมือนวาดด้วยหัวใจ!";
    } else if (finalScore >= 80) {
      recommendation = "ดีมาก! มีแค่บางจุดเล็ก ๆ ที่ควรปรับปรุงเพิ่มเติม";
    } else if (finalScore >= 70) {
      recommendation =
        "ดีอยู่แล้ว แต่ลองฝึกซ้อมเพิ่มอีกนิดเพื่อให้ชัดเจนยิ่งขึ้น";
    } else {
      recommendation =
        "ไม่เป็นไร! ทุกคนเริ่มต้นจากที่ต่ำสุด ลองฝึกฝนอีกหน่อยแล้วคุณจะเก่งขึ้น!";
    }

    // อัปโหลดภาพผู้ใช้ (ต้นฉบับ) ไปยัง Cloud Storage
    const bucket = admin.storage().bucket();
    const langFolder = language === "English" ? "English" : "Thai";
    const filePathInBucket = `user_writings/${uid}/${langFolder}/${fileName}`;
    const file = bucket.file(filePathInBucket);
    await file.save(userImageBuffer, {
      metadata: { contentType: "image/png" },
    });
    console.log("Image uploaded successfully to:", filePathInBucket);
    const [downloadUrl] = await file.getSignedUrl({
      action: "read",
      expires: "03-09-2491",
    });
    console.log("Download URL:", downloadUrl);

    // บันทึกผลลง Firestore
    await admin
      .firestore()
      .collection("evaluations")
      .doc(uid)
      .collection(language)
      .doc(getCharacterFromFileName(templateFileName).trim().toUpperCase())
      .set({
        score: finalScore,
        timestamp: FieldValue.serverTimestamp(),
        recommendation,
        status,
      });

    return res.status(200).json({
      score: finalScore,
      recommendation,
      status,
    });
  } catch (error) {
    console.error("Error in evaluateWriting:", error);
    return res.status(500).json({ error: error.message });
  }
});

console.log("Functions exported");
