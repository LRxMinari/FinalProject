import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'evaluation_page.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WritingPracticePage extends StatefulWidget {
  final String language;
  final String character;

  const WritingPracticePage({
    super.key,
    required this.language,
    required this.character,
  });

  @override
  _WritingPracticePageState createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends State<WritingPracticePage> {
  List<Offset?> points = [];
  late List<String> _charactersToPractice;
  int _currentCharacterIndex = 0;
  late ConfettiController _confettiController;

  GlobalKey _repaintBoundaryKey = GlobalKey(); // 🔥 ใช้เพื่อจับภาพ

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    print("Selected Language: ${widget.language}"); // ✅ เช็คค่าภาษา

    if (widget.language == 'ภาษาไทย' || widget.language == 'Thai') {
      _charactersToPractice = [
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
    } else if (widget.language == 'English') {
      _charactersToPractice = List.generate(26, (index) {
        return String.fromCharCode(index + 65);
      });
    } else {
      _charactersToPractice = [];
      print("⚠️ ไม่รองรับภาษา: ${widget.language}");
    }

    print(
        "Characters to practice: $_charactersToPractice"); // ✅ เช็คว่ามีค่าจริงไหม

    // ตั้งค่า index ให้ถูกต้อง
    _currentCharacterIndex = _charactersToPractice.isNotEmpty ? 0 : -1;
  }

  Future<void> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      print("✅ ได้รับสิทธิ์จัดการไฟล์แล้ว");
    } else {
      print("❌ ถูกปฏิเสธการเข้าถึงไฟล์");
    }
  }

  GlobalKey repaintKey = GlobalKey();

  Future<void> uploadImageToFirebase(GlobalKey repaintKey) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        RenderRepaintBoundary? boundary = repaintKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary?;

        if (boundary == null) {
          print("❌ ไม่พบ RepaintBoundary");
          return;
        }

        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();

          Reference ref = FirebaseStorage.instance.ref().child(
              "user_writings/writing_${DateTime.now().millisecondsSinceEpoch}.png");
          UploadTask uploadTask = ref.putData(pngBytes);

          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          print("✅ รูปถูกอัปโหลดที่: $downloadUrl");
        }
      } catch (e) {
        print("❌ เกิดข้อผิดพลาด: $e");
      }
    });
  }

  void _nextCharacter() {
    if (_charactersToPractice.isEmpty)
      return; // ถ้าไม่มีตัวอักษร ให้ return ทันที

    setState(() {
      if (_currentCharacterIndex < _charactersToPractice.length - 1) {
        _currentCharacterIndex++;
        points.clear();
      } else {
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) _showCompletionDialog();
        });
      }
    });
  }

  void _showCompletionDialog() async {
    print("📢 _showCompletionDialog() เริ่มทำงาน");

    _confettiController.play();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      print("⚠ _showCompletionDialog() ถูกเรียก แต่ context หมดอายุ");
      return;
    }

    print("✅ _showCompletionDialog() เปิด Dialog");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 ยินดีด้วย! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('คุณฝึกครบทุกตัวแล้ว! เก่งมาก!'),
              const SizedBox(height: 10),
              Image.asset('assets/congrats.gif', width: 300, height: 300),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentCharacterIndex = 0;
                  points.clear();
                });
              },
              child: const Text('เริ่มใหม่'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EvaluationPage(character: 'ก'), // เริ่มที่ "ก" เสมอ
                  ),
                );
              },
              child: const Text('ไปหน้าประเมินผล'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Current index: $_currentCharacterIndex / Total: ${_charactersToPractice.length}");
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Writing_1.png', fit: BoxFit.cover),
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
                const Text('ฝึกเขียนตัวอักษร',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                RepaintBoundary(
                  key: _repaintBoundaryKey, // 🔥 ครอบส่วนที่ต้องการบันทึก
                  child: Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(252, 255, 209, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        (_charactersToPractice.isNotEmpty &&
                                _currentCharacterIndex >= 0)
                            ? Image.asset(
                                widget.language == 'English'
                                    ? 'assets/English/${_charactersToPractice[_currentCharacterIndex]}.png'
                                    : 'assets/Thai/${_charactersToPractice[_currentCharacterIndex]}.jpg',
                                width: 350,
                                height: 200,
                                fit: BoxFit.fitHeight,
                              )
                            : const Text('ไม่มีตัวอักษรให้ฝึก',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.red)),
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
                            size: const Size(350, 200),
                            painter: MyPainter(points),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => setState(() => points.clear()),
                    child: const Text('เริ่มใหม่')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // ✅ กระตุ้นให้ UI build ใหม่
                    Future.delayed(Duration(milliseconds: 100), () {
                      // ✅ รอให้ UI build เสร็จ
                      uploadImageToFirebase(_repaintBoundaryKey);
                    });
                  },
                  child: Text('บันทึกไป Firebase'),
                ),
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [
                    Colors.blue,
                    Colors.green,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
