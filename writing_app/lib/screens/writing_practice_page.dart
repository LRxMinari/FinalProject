import 'package:flutter/material.dart';
import 'evaluation_page.dart'; // นำเข้าหน้าประเมินผล

class WritingPracticePage extends StatefulWidget {
  final String language;
  final String character;

  const WritingPracticePage(
      {super.key, required this.language, required this.character});

  @override
  _WritingPracticePageState createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends State<WritingPracticePage> {
  List<Offset?> points = [];
  String _character = '';
  late List<String> _charactersToPractice;
  int _currentCharacterIndex = 0;

  @override
  void initState() {
    super.initState();
    _character = widget.character;

    if (widget.language == 'ภาษาไทย') {
      _charactersToPractice = [
        'ก',
        'ข',
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
    } else if (widget.language == 'English') {
      _charactersToPractice = List.generate(26, (index) {
        return String.fromCharCode(index + 65); // A-Z
      });
    } else {
      _charactersToPractice = [];
    }
  }

  void _nextCharacter() {
    setState(() {
      if (_currentCharacterIndex < _charactersToPractice.length - 1) {
        _currentCharacterIndex++;
        _character = _charactersToPractice[_currentCharacterIndex];
        points.clear();
      } else {
        // // เมื่อฝึกเขียนตัวอักษรสุดท้าย
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => EvaluationPage(
        //       character: _character,
        //       score: 80.0, // ตัวอย่างคะแนนที่คำนวณ
        //       stars: 4, // ตัวอย่างจำนวนดาว
        //       feedback: 'ทำได้ดี แต่ควรฝึกให้ชัดเจนขึ้น',
        //     ),
        //   ),
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFFFDF6E4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ฝึกเขียนตัวอักษร',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'ตัวอักษร: $_character',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  points.add(details.localPosition);
                });
              },
              onPanEnd: (_) {
                points.add(null);
              },
              child: CustomPaint(
                size: const Size(300, 300),
                painter: MyPainter(points, _character),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  points.clear();
                });
              },
              child: const Text('เริ่มใหม่'),
            ),
            const SizedBox(height: 20),
            // ปรับปุ่ม ถัดไป เป็น เสร็จสิ้น เมื่อถึงตัวอักษรสุดท้าย
            ElevatedButton(
              onPressed: _nextCharacter,
              child: Text(
                  _currentCharacterIndex == _charactersToPractice.length - 1
                      ? 'เสร็จสิ้น'
                      : 'ถัดไป'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points; // จุดที่ผู้ใช้วาด
  final String character; // ตัวอักษรลายน้ำ

  MyPainter(this.points, this.character);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. สร้างตัวอักษรลายน้ำ
    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: size.width * 0.6,
          color: Colors.grey.withOpacity(0.4), // สีลายน้ำ
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);

    // 2. วาดเส้นจากการลากของผู้ใช้
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
