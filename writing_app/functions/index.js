console.log("Starting functions module...");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const fs = require("fs");
const path = require("path");
const axios = require("axios");
const PNG = require("pngjs").PNG;
const sharp = require("sharp");

// กำหนด storageBucket ให้ถูกต้อง (โดยอัตโนมัติจาก Firebase Console)
admin.initializeApp({
  storageBucket: "practice-writing-app-c6bd8.firebasestorage.app",
});
console.log("Firebase admin initialized.");

// โหลด pixelmatch แบบ dynamic import เพื่อลด delay ในช่วงเริ่มต้น
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

// ฟังก์ชัน evaluateWriting สำหรับประเมินผลการฝึกเขียน (Production Ready)
exports.evaluateWriting = functions.https.onRequest(async (req, res) => {
  try {
    // ใช้ POST เท่านั้น
    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }

    // (สำหรับตอนนี้ให้ปิดการตรวจสอบ App Check เพื่อทดสอบ)
    // const appCheckToken = req.header("X-Firebase-AppCheck");
    // if (!appCheckToken) {
    //   return res.status(401).send("No App Check token provided.");
    // }
    // try {
    //   await admin.appCheck().verifyToken(appCheckToken);
    // } catch (tokenError) {
    //   console.error("App Check token verification failed:", tokenError);
    //   return res.status(401).send("Invalid App Check token.");
    // }

    // รับ parameter จาก client
    const { uid, language, fileName, imageUrl } = req.body;
    if (!uid || !language || !fileName || !imageUrl) {
      return res.status(400).send("Missing required parameters");
    }

    const templateFileName = getTemplateFileName(fileName);
    if (!isValidTemplateFile(templateFileName, language)) {
      return res.status(404).send("Template image not found");
    }

    // ดาวน์โหลดภาพผู้ใช้จาก imageUrl
    const response = await axios.get(imageUrl, { responseType: "arraybuffer" });
    const userImageBuffer = Buffer.from(response.data, "binary");

    // อ่าน template image จากไฟล์ในโฟลเดอร์ templates/{language}/
    const templateImagePath = path.join(
      __dirname,
      "templates",
      language,
      templateFileName
    );
    const templateBuffer = fs.readFileSync(templateImagePath);

    // ประมวลผลภาพ: แปลงเป็น grayscale และ threshold เพื่อลด noise
    const processedUserBuffer = await sharp(userImageBuffer)
      .grayscale()
      .threshold(128)
      .toBuffer();
    const processedTemplateBuffer = await sharp(templateBuffer)
      .grayscale()
      .threshold(128)
      .toBuffer();

    let processedUserPNG = PNG.sync.read(processedUserBuffer);
    const processedTemplatePNG = PNG.sync.read(processedTemplateBuffer);

    // หากขนาดภาพไม่ตรงกัน ให้ปรับขนาดภาพผู้ใช้ให้ตรงกับ template
    if (
      processedUserPNG.width !== processedTemplatePNG.width ||
      processedUserPNG.height !== processedTemplatePNG.height
    ) {
      const resizedUserBuffer = await sharp(processedUserBuffer)
        .resize(processedTemplatePNG.width, processedTemplatePNG.height)
        .toBuffer();
      processedUserPNG = PNG.sync.read(resizedUserBuffer);
      console.log("User image resized to match template size.");
    }

    if (!pixelmatch) {
      console.error("pixelmatch module is not loaded.");
      return res.status(500).send("Server configuration error.");
    }
    const diff = new PNG({
      width: processedUserPNG.width,
      height: processedUserPNG.height,
    });
    const numDiffPixels = pixelmatch(
      processedUserPNG.data,
      processedTemplatePNG.data,
      diff.data,
      processedUserPNG.width,
      processedUserPNG.height,
      { threshold: 0.05 }
    );
    const totalPixels = processedUserPNG.width * processedUserPNG.height;
    const similarity = 100 - (numDiffPixels / totalPixels) * 100;

    const character = getCharacterFromFileName(templateFileName);
    let recommendation = "";
    if (similarity >= 90) {
      recommendation =
        "สุดยอดเลยจ๊ะ! งานเขียนของคุณน่ารักมาก เหมือนวาดด้วยหัวใจ! รักษาความเก่งไว้นะ!";
    } else if (similarity >= 80) {
      recommendation =
        "ดีมากเลยจ๊ะ! มีแค่บางจุดเล็ก ๆ ที่อยากให้ปรับปรุงอีกนิด งานเขียนของคุณน่ารักมากอยู่แล้ว!";
    } else if (similarity >= 70) {
      recommendation =
        "งานเขียนของคุณก็ดีอยู่แล้วจ๊ะ แต่ลองฝึกซ้อมเพิ่มอีกนิด งานเขียนจะน่ารักและชัดเจนขึ้นนะ!";
    } else {
      recommendation =
        "ไม่เป็นไรจ๊ะ! ทุกคนเริ่มต้นจากที่ต่ำสุด ลองฝึกฝนอีกหน่อย แล้วคุณจะเก่งขึ้นอย่างรวดเร็ว!";
    }

    // อัปโหลดไฟล์ผู้ใช้ไปยัง Firebase Storage โดยใช้ Admin SDK (bypass Security Rules)
    const bucket = admin.storage().bucket();
    const langFolder = language === "English" ? "English" : "Thai";
    const filePathInBucket = `user_writings/${uid}/${langFolder}/${fileName}`;
    const file = bucket.file(filePathInBucket);
    await file.save(userImageBuffer, {
      metadata: { contentType: "image/png" },
    });
    console.log("Image uploaded successfully to:", filePathInBucket);

    // สร้าง Signed URL สำหรับให้ client เข้าถึงไฟล์
    const [downloadUrl] = await file.getSignedUrl({
      action: "read",
      expires: "03-09-2491", // ปรับวันหมดอายุได้ตามต้องการ
    });
    console.log("Download URL:", downloadUrl);

    // บันทึกผลลง Firestore
    await admin
      .firestore()
      .collection("evaluations")
      .doc(uid)
      .collection(language)
      .doc(character)
      .set({
        score: similarity,
        timestamp: FieldValue.serverTimestamp(),
        recommendation: recommendation,
      });

    return res
      .status(200)
      .json({ score: similarity, recommendation: recommendation });
  } catch (error) {
    console.error("Error in evaluateWriting:", error);
    return res.status(500).json({ error: error.message });
  }
});

console.log("Functions exported");
