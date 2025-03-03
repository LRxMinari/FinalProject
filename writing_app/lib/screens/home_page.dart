import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ใช้ Google Fonts
import 'language_selection_page.dart';
import 'evaluation_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
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
          image: const DecorationImage(
            image: AssetImage('assets/Writing_1.png'), // พื้นหลัง
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // แทนที่ GIF ด้วยตัวหนังสือ
                Column(
                  children: [
                    Text(
                      'WRITING\nPRACTICE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 100, // ปรับขนาดตัวอักษร
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 109, 20, 0),
                        height: 1, // ลดค่าลงเพื่อให้บรรทัดชิดกัน
                      ),
                    ),
                    Transform.translate(
                      offset:
                          Offset(0, -10), // ขยับขึ้น 10 พิกเซลเพื่อลดระยะห่าง
                      child: Text(
                        'APPLICATION',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 40, // ปรับขนาดให้เล็กลง
                          color: const Color.fromARGB(255, 109, 20, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
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
                          child: Image.asset(
                            'assets/evaluate_icon.png', // ใช้ PNG เป็นปุ่มโดยตรง
                            width: 150, // ปรับขนาดให้เหมาะสม
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ประเมินผลลัพธ์',
                          style: GoogleFonts.itim(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LanguageSelectionPage(),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/practice_icon.png',
                            width: 200, // ปรับขนาดให้เหมาะสม
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ฝึกเขียน',
                          style: GoogleFonts.itim(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
