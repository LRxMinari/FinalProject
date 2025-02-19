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
                      'WRITING PRACTICE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'APPLICATION',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 0, 0),
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
                            width: 80, // ปรับขนาดให้เหมาะสม
                            height: 80,
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
                            width: 80, // ปรับขนาดให้เหมาะสม
                            height: 80,
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
