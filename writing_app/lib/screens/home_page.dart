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
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -600, // เลื่อนภาพพื้นหลังขึ้น 50px
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/Writing_1.png', // พื้นหลัง
              fit: BoxFit.cover,
              alignment: Alignment.topCenter, // ปรับตำแหน่งให้เหมาะสม
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'WRITING\nPRACTICE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 109, 20, 0),
                          height: 1,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: Text(
                          'APPLICATION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 40,
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
                                  builder: (context) => EvaluationPage(
                                    language:
                                        'English', // หรือ 'Thai' ตามที่ผู้ใช้เลือก
                                    character:
                                        'A', // หรืออักษรที่ต้องการประเมิน
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/evaluate_icon.png',
                              width: 150,
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ประเมินผลลัพธ์',
                            style: GoogleFonts.itim(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 255, 255, 255),
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
                              width: 200,
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ฝึกเขียน',
                            style: GoogleFonts.itim(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 255, 255, 255),
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
        ],
      ),
    );
  }
}
