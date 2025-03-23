import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';

class EvaluationPage extends StatefulWidget {
  final String character;

  const EvaluationPage({super.key, required this.character});

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  late String selectedCharacter;
  double score = 65.0;
  int stars = 2;
  String feedback = 'ลองฝึกการเขียนเส้นโค้งให้ราบรื่นขึ้น';
  bool isThaiAlphabet = true;

  final List<String> thaiAlphabet = [
    'ก',
    'ข',
    'ฃ',
    'ค',
    'ฅ',
    'ฆ',
    'ง',
    'จ',
    'ฉ',
    'ช',
    'ซ',
    'ฌ',
    'ญ',
    'ฎ',
    'ฏ',
    'ฐ',
    'ฑ',
    'ฒ',
    'ณ',
    'ด',
    'ต',
    'ถ',
    'ท',
    'ธ',
    'น',
    'บ',
    'ป',
    'ผ',
    'ฝ',
    'พ',
    'ฟ',
    'ภ',
    'ม',
    'ย',
    'ร',
    'ล',
    'ว',
    'ศ',
    'ษ',
    'ส',
    'ห',
    'ฬ',
    'อ',
    'ฮ'
  ];

  final List<String> englishAlphabet =
      List.generate(26, (index) => String.fromCharCode(65 + index));

  @override
  void initState() {
    super.initState();
    selectedCharacter = widget.character;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'การประเมินผล',
          style: GoogleFonts.mali(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false, // ล้าง stack ทั้งหมด ทำให้กลับไปหน้าแรกเลย
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          selectedCharacter,
                          style: GoogleFonts.mali(
                            fontSize: 140,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ToggleButtons(
                          isSelected: [isThaiAlphabet, !isThaiAlphabet],
                          onPressed: (index) {
                            setState(() {
                              isThaiAlphabet = index == 0;
                              selectedCharacter = isThaiAlphabet ? 'ก' : 'A';
                            });
                          },
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('ภาษาไทย',
                                  style: GoogleFonts.mali(fontSize: 18)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('ภาษาอังกฤษ',
                                  style: GoogleFonts.mali(fontSize: 18)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 5,
                            childAspectRatio: 1.2,
                            children: (isThaiAlphabet
                                    ? thaiAlphabet
                                    : englishAlphabet)
                                .map((char) => buildCharButton(char))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: GoogleFonts.mali(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              feedback,
              style: GoogleFonts.mali(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildCharButton(String char) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCharacter = char;
          score = (50 + (char.codeUnitAt(0) % 50)).toDouble();
          stars = (score / 33).floor().clamp(1, 3);
          feedback = 'ลองฝึกการเขียนให้สมดุลมากขึ้น';
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selectedCharacter == char ? Colors.purple[300] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            char,
            style: GoogleFonts.mali(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: selectedCharacter == char ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
