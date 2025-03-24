from flask import Flask, request, jsonify
import cv2
import numpy as np
from skimage.metrics import structural_similarity as ssim
import os
import uuid

app = Flask(__name__)

# 📌 เปลี่ยน BASE_DIR ให้ตรงกับตำแหน่งของไฟล์ต้นแบบ
BASE_DIR = os.path.abspath(os.path.join(os.getcwd(), "..", "assets"))

@app.route("/compare", methods=["POST"])
def compare_images():
    if "image" not in request.files or "language" not in request.form:
        return jsonify({"error": "Missing image or language parameter"}), 400

    language = request.form["language"].strip()
    template_name = request.form.get("template", "").strip()
    language_folder = os.path.join(BASE_DIR, language)

    if not os.path.exists(language_folder):
        return jsonify({"error": f"Language folder '{language}' not found"}), 400

    template_files = sorted(os.listdir(language_folder))
    if not template_files:
        return jsonify({"error": "No template images found"}), 400

    # ✅ ตรวจสอบว่าภาษาไทยถูกเข้ารหัสอย่างถูกต้อง
    if template_name and template_name in template_files:
        template_path = os.path.join(language_folder, template_name)
    else:
        template_path = os.path.join(language_folder, template_files[0])

    # ✅ โหลดภาพแบบรองรับชื่อไฟล์ภาษาไทย
    try:
        with open(template_path, "rb") as f:
            file_bytes = np.asarray(bytearray(f.read()), dtype=np.uint8)
            template_image = cv2.imdecode(file_bytes, cv2.IMREAD_GRAYSCALE)
    except Exception as e:
        return jsonify({"error": f"Failed to load template image: {str(e)}"}), 400

    if template_image is None:
        return jsonify({"error": "Failed to decode template image"}), 400

    # 📌 บันทึกไฟล์ที่อัปโหลดโดยใช้ UUID ป้องกันชื่อซ้ำ
    file = request.files["image"]
    uploaded_filename = f"uploaded_{uuid.uuid4().hex}.jpg"
    uploaded_path = os.path.join("uploads", uploaded_filename)

    os.makedirs("uploads", exist_ok=True)
    file.save(uploaded_path)

    # ✅ โหลดภาพที่ผู้ใช้ส่งมา (รองรับชื่อภาษาไทย)
    try:
        with open(uploaded_path, "rb") as f:
            file_bytes = np.asarray(bytearray(f.read()), dtype=np.uint8)
            user_image = cv2.imdecode(file_bytes, cv2.IMREAD_GRAYSCALE)
    except Exception as e:
        return jsonify({"error": f"Failed to load user image: {str(e)}"}), 400

    if user_image is None:
        return jsonify({"error": "Failed to decode user image"}), 400

    # ปรับขนาดให้ตรงกับภาพต้นแบบ
    user_image = cv2.resize(user_image, (template_image.shape[1], template_image.shape[0]))

    # คำนวณค่าความคล้ายคลึง SSIM
    score, _ = ssim(template_image, user_image, full=True)
    similarity_percentage = round(score * 100, 2)

    return jsonify({
        "score": similarity_percentage,
        "language": language,
        "template_used": os.path.basename(template_path),
    })

if __name__ == "__main__":
    app.run(debug=True)
