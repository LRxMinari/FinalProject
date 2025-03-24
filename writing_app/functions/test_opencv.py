import cv2
import matplotlib.pyplot as plt

# โหลดภาพ
image = cv2.imread("test.jpg")

# แปลงสีจาก BGR เป็น RGB (เพราะ OpenCV ใช้ BGR แต่ Matplotlib ใช้ RGB)
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# แสดงภาพ
plt.imshow(image)
plt.axis("off")  # ซ่อนแกน x, y
plt.show()
