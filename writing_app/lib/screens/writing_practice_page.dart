import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'evaluation_page.dart';

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
    _initializeCharacters();
  }

  void _initializeCharacters() {
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
      _charactersToPractice =
          List.generate(26, (index) => String.fromCharCode(index + 65));
    } else {
      _charactersToPractice = [];
    }

    if (_charactersToPractice.isNotEmpty) {
      _character = _charactersToPractice[_currentCharacterIndex];
    } else {
      _character = '?'; // กรณีไม่มีตัวอักษรให้แสดงค่าเริ่มต้น
    }
  }

  void _nextCharacter() {
    setState(() {
      if (_currentCharacterIndex < _charactersToPractice.length - 1) {
        _currentCharacterIndex++;
        _character = _charactersToPractice[_currentCharacterIndex];
        points.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Writing_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ฝึกเขียนตัวอักษร',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: CharacterGuidePainter(_character),
                      ),
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
                          painter: MyPainter(points),
                        ),
                      ),
                    ],
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
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points;

  MyPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
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

class CharacterGuidePainter extends CustomPainter {
  final String character;

  CharacterGuidePainter(this.character);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.8);

    final dashedPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    drawDashedPath(canvas, path, dashedPaint);
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    Path dashPath = Path();
    for (var metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
            metric.extractPath(distance, distance + 10), Offset.zero);
        distance += 20;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
