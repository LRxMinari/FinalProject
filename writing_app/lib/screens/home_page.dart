import 'package:flutter/material.dart';
import 'language_selection_page.dart';
import 'evaluation_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ให้พื้นหลังอยู่ด้านหลัง AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ทำให้ AppBar โปร่งใส
        elevation: 0, // ลบเงาออก
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: Colors.black), // ไอคอนสีดำให้มองเห็นชัดขึ้น
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Writing_1.png'), // ใส่พื้นหลังที่ต้องการ
            fit: BoxFit.cover, // ปรับให้เต็มหน้าจอ
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/practice.gif',
                  width: 400,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFECE4D6),
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LanguageSelectionPage(),
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
      ),
    );
  }
}
