import 'package:flutter/material.dart';
import 'language_selection_page.dart'; // นำเข้าหน้าเลือกหมวดหมู่

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  String selectedCharacter = 'ก'; // ตัวอักษรที่เลือก
  double score = 65.0;
  int stars = 2;
  String feedback = 'ลองฝึกการเขียนเส้นโค้งให้ราบรื่นขึ้น';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'ตัวอย่าง',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            selectedCharacter,
                            style: const TextStyle(
                              fontSize: 120,
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
                          const Text(
                            'พยัญชนะ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 5,
                              childAspectRatio: 1.2,
                              children: [
                                ...thaiAlphabet
                                    .map((char) => buildCharButton(char)),
                                ...englishAlphabet
                                    .map((char) => buildCharButton(char)),
                              ],
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
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
          boxShadow: [
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedCharacter == char ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
