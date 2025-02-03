import 'package:flutter/material.dart';
import 'language_selection_page.dart';
import 'evaluation_page.dart'; // นำเข้าหน้าจอการประเมินผล
import 'settings_page.dart'; // นำเข้าหน้าตั้งค่า

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6E4),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // เปิดหน้าการตั้งค่า
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SettingsPage(), // นำผู้ใช้ไปที่หน้า SettingsPage
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF6E4),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 0, bottom: 200), // ลดระยะห่างด้านบน
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/practice.gif',
                width: 400, // ปรับขนาดตามต้องการ
                height: 300, // ปรับความสูง
                fit: BoxFit.contain, // ปรับให้ภาพอยู่ในขอบเขต
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่มสำหรับประเมินผล
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFECE4D6),
                        child: IconButton(
                          icon: const Icon(Icons.pets),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EvaluationPage(
                                  character: 'ก',
                                  score: 85.0,
                                  stars: 4,
                                  feedback:
                                      'ดีมาก! ลองปรับการเขียนหัวตัวอักษรให้คมขึ้น.',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Text('ประเมินผลลัพธ์'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // ปุ่มสำหรับฝึกเขียน
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFECE4D6),
                        child: IconButton(
                          icon: const Icon(Icons.edit), // ปุ่ม "ฝึกเขียน"
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LanguageSelectionPage(), // ไปยังหน้าฝึกเขียน
                              ),
                            );
                          },
                        ),
                      ),
                      const Text('ฝึกเขียน'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
