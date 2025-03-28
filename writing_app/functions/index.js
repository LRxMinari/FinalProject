console.log("Starting functions module...");

const functions = require("firebase-functions");
console.log("Required firebase-functions and firebase-admin");
const admin = require("firebase-admin");
// ดึง FieldValue จาก firebase-admin/firestore
const { FieldValue } = require("firebase-admin/firestore");

const fs = require("fs");
const path = require("path");
const axios = require("axios");
const PNG = require("pngjs").PNG;
// ไม่ require pixelmatch แบบ global เพราะเป็น ES Module

// สำหรับ Production ไม่ต้องตั้งค่า Firestore Emulator
// admin.initializeApp() จะใช้ configuration จาก Firebase Console โดยอัตโนมัติ
admin.initializeApp();
console.log("Firebase admin initialized");

// ฟังก์ชันตรวจสอบว่าไฟล์ใน template มีอยู่จริงหรือไม่
function isValidTemplateFile(fileName, language) {
  const templateFolder = path.join(__dirname, "templates", language);
  if (!fs.existsSync(templateFolder)) return false;
  const templateFiles = fs.readdirSync(templateFolder);
  return templateFiles.includes(fileName);
}

// ฟังก์ชันสกัดตัวอักษรจากชื่อไฟล์ เช่น "A.png" หรือ "ก.jpg"
function getCharacterFromFileName(fileName) {
  return path.basename(fileName, path.extname(fileName));
}

// ฟังก์ชันแปลงชื่อไฟล์จากผู้ใช้ (เช่น "writing_A.png") ให้เป็นชื่อ template (เช่น "A.png")
function getTemplateFileName(userFileName) {
  const prefix = "writing_";
  if (userFileName.startsWith(prefix)) {
    return userFileName.slice(prefix.length);
  }
  return userFileName;
}

// ฟังก์ชัน processData สำหรับการทดสอบหรือใช้งานอื่น ๆ
exports.processData = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }
    const data = req.body;
    if (!data || !data.message) {
      return res.status(400).send('Missing required field "message"');
    }
    const docRef = await admin.firestore().collection("messages").add({
      message: data.message,
      timestamp: FieldValue.serverTimestamp(),
    });
    return res.status(200).json({ success: true, id: docRef.id });
  } catch (error) {
    console.error("Error processing data:", error);
    return res.status(500).json({ error: error.message });
  }
});

// ฟังก์ชัน evaluateWriting สำหรับประเมินผลการฝึกเขียน และให้คำแนะนำที่น่ารักสำหรับเด็ก
exports.evaluateWriting = functions.https.onRequest(async (req, res) => {
  try {
    // dynamic import โมดูล pixelmatch เมื่อฟังก์ชันถูกเรียกใช้งาน
    const { default: pixelmatch } = await import("pixelmatch");

    // ตรวจสอบให้แน่ใจว่าใช้ POST เท่านั้น
    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }

    // รับ parameter จาก client
    const { uid, language, fileName, imageUrl } = req.body;
    if (!uid || !language || !fileName || !imageUrl) {
      return res.status(400).send("Missing required parameters");
    }

    // แปลงชื่อไฟล์จากผู้ใช้ให้ตรงกับชื่อใน template folder
    const templateFileName = getTemplateFileName(fileName);

    // ตรวจสอบว่ามีไฟล์ template อยู่จริงหรือไม่
    if (!isValidTemplateFile(templateFileName, language)) {
      return res.status(404).send("Template image not found");
    }

    // ดาวน์โหลดภาพที่ผู้ใช้ส่งเข้ามาจาก imageUrl
    const response = await axios.get(imageUrl, { responseType: "arraybuffer" });
    const userImageBuffer = Buffer.from(response.data, "binary");

    // อ่านภาพผู้ใช้จาก buffer ด้วย pngjs
    let userPNG = PNG.sync.read(userImageBuffer);

    // กำหนด path สำหรับ template image ในโฟลเดอร์ templates/{language}/
    const templateImagePath = path.join(
      __dirname,
      "templates",
      language,
      templateFileName
    );
    const templateBuffer = fs.readFileSync(templateImagePath);
    const templatePNG = PNG.sync.read(templateBuffer);

    // หากขนาดภาพไม่ตรงกัน ให้ปรับขนาดภาพผู้ใช้ให้ตรงกับ template ด้วย sharp
    if (
      userPNG.width !== templatePNG.width ||
      userPNG.height !== templatePNG.height
    ) {
      const sharp = require("sharp");
      const resizedBuffer = await sharp(userImageBuffer)
        .resize(templatePNG.width, templatePNG.height)
        .toBuffer();
      userPNG = PNG.sync.read(resizedBuffer);
    }

    // เปรียบเทียบภาพโดยใช้ pixelmatch
    const diff = new PNG({ width: userPNG.width, height: userPNG.height });
    const numDiffPixels = pixelmatch(
      userPNG.data,
      templatePNG.data,
      diff.data,
      userPNG.width,
      userPNG.height,
      { threshold: 0.1 }
    );

    // คำนวณคะแนนความคล้าย (เปอร์เซ็นต์)
    const totalPixels = userPNG.width * userPNG.height;
    const similarity = 100 - (numDiffPixels / totalPixels) * 100;

    // สกัดตัวอักษรจาก templateFileName
    const character = getCharacterFromFileName(templateFileName);

    // กำหนดคำแนะนำสำหรับการเขียนให้เด็ก (มีความน่ารักและให้กำลังใจ)
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

    // บันทึกผลคะแนนและคำแนะนำลง Firestore ใน collection evaluations/{uid}/{language}/{character}
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

    // ส่งผลคะแนนและคำแนะนำกลับไปยัง client
    return res
      .status(200)
      .json({ score: similarity, recommendation: recommendation });
  } catch (error) {
    console.error("Error in evaluateWriting:", error);
    return res.status(500).json({ error: error.message });
  }
});

console.log("Functions exported");
