import functions_framework
import cv2
import numpy as np
import requests
import firebase_admin
from firebase_admin import storage, firestore
from google.cloud import storage as gcs_storage
from skimage.metrics import structural_similarity as ssim

# ✅ เริ่ม Firebase Admin SDK
firebase_admin.initialize_app()

db = firestore.client()
gcs_client = gcs_storage.Client()

@functions_framework.http
def evaluate_writing(request):
    request_json = request.get_json()

    if not request_json:
        return "❌ ไม่มีข้อมูล", 400

    try:
        uid = request_json["uid"]
        language = request_json["language"]
        file_name = request_json["fileName"]
        image_url = request_json["imageUrl"]

        print(f"📥 ได้รับภาพจาก: {image_url}")

        # ✅ ดาวน์โหลดภาพที่ผู้ใช้วาดจาก Firebase Storage
        response = requests.get(image_url)
        if response.status_code != 200:
            return "❌ ดาวน์โหลดภาพไม่สำเร็จ", 500
        
        image_array = np.asarray(bytearray(response.content), dtype=np.uint8)
        user_img = cv2.imdecode(image_array, cv2.IMREAD_GRAYSCALE)

        if user_img is None:
            return "❌ ไม่สามารถโหลดภาพของผู้ใช้", 500

        # ✅ ดึงภาพต้นแบบจาก Firebase Storage
        template_path = f"user_writings/templates/{language}/{file_name}"  
        bucket = gcs_client.bucket("your-firebase-storage-bucket")  # 🔹 ใส่ชื่อ Bucket ของคุณ
        blob = bucket.blob(template_path)
        
        if not blob.exists():
            return {"error": "❌ ไม่พบภาพต้นแบบ"}, 400

        template_bytes = blob.download_as_bytes()
        template_array = np.asarray(bytearray(template_bytes), dtype=np.uint8)
        template_img = cv2.imdecode(template_array, cv2.IMREAD_GRAYSCALE)

        if template_img is None:
            return "❌ ไม่สามารถโหลดภาพต้นแบบ", 500

        # ✅ ปรับขนาดภาพของผู้ใช้ให้ตรงกับภาพต้นแบบ
        user_img = cv2.resize(user_img, (template_img.shape[1], template_img.shape[0]))

        # ✅ คำนวณเปอร์เซ็นต์พื้นที่ที่เติม
        _, user_thresh = cv2.threshold(user_img, 150, 255, cv2.THRESH_BINARY_INV)
        _, template_thresh = cv2.threshold(template_img, 150, 255, cv2.THRESH_BINARY_INV)

        total_pixels = template_thresh.size
        filled_pixels = np.count_nonzero(user_thresh)
        fill_accuracy = round((filled_pixels / total_pixels) * 100, 2)

        # ✅ คำนวณค่าความคล้ายคลึง SSIM
        ssim_score = ssim(template_thresh, user_thresh)
        ssim_percentage = round(ssim_score * 100, 2)

        print(f"📊 Fill Accuracy: {fill_accuracy}%, SSIM Score: {ssim_percentage}%")

        # ✅ อัปโหลดผลลัพธ์ไปยัง Firestore
        result_ref = db.collection("evaluations").document(uid)
        result_ref.set({
            "userId": uid,
            "language": language,
            "fileName": file_name,
            "imageUrl": image_url,
            "fill_accuracy": fill_accuracy,
            "ssim_score": ssim_percentage,
            "status": "completed",
        }, merge=True)

        return {"status": "success", "fill_accuracy": fill_accuracy, "ssim_score": ssim_percentage}, 200

    except Exception as e:
        print(f"❌ เกิดข้อผิดพลาด: {e}")
        return {"status": "error", "message": str(e)}, 500
