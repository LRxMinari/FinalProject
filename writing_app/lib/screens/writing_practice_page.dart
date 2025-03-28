import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'evaluation_page.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WritingPracticePage extends StatefulWidget {
  final String language; // "English" หรือ "Thai"
  final String character;

  const WritingPracticePage({
    Key? key,
    required this.language,
    required this.character,
  }) : super(key: key);

  @override
  _WritingPracticePageState createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends State<WritingPracticePage> {
  List<Offset?> points = [];
  late List<String> _charactersToPractice;
  int _currentCharacterIndex = 0;
  late ConfettiController _confettiController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // อัปเดต Endpoint ให้เป็น URL จริงของ Cloud Function evaluateWriting
  final String cloudFunctionUrl =
      'https://us-central1-practice-writing-app-c6bd8.cloudfunctions.net/evaluateWriting';

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    if (widget.language.trim().toLowerCase() == 'english') {
      _charactersToPractice =
          List.generate(26, (index) => String.fromCharCode(index + 65));
    } else {
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
    }
    _currentCharacterIndex = 0;
  }

  Future<String?> _getCurrentUserUID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      user = (await FirebaseAuth.instance.signInAnonymously()).user;
    }
    return user?.uid;
  }

  // ฟังก์ชันสำหรับอัปโหลดภาพและเรียก Cloud Function evaluateWriting
  Future<void> _uploadImageAndEvaluate() async {
    try {
      String? uid = await _getCurrentUserUID();
      if (uid == null) {
        print("User not logged in, cannot upload image.");
        return;
      }

      final langFolder = widget.language.trim().toLowerCase() == 'english'
          ? 'English'
          : 'Thai';
      String character = _charactersToPractice[_currentCharacterIndex];
      String fileName = "writing_$character.png";

      // จับภาพจาก RepaintBoundary
      RenderRepaintBoundary? boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print("RepaintBoundary not found");
        return;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print("Unable to get image bytes");
        return;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // อัปโหลดภาพไปยัง Firebase Storage
      String uidStr = uid;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("user_writings/$uidStr/$langFolder/$fileName");
      UploadTask uploadTask = ref.putData(pngBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded: $downloadUrl");

      // เตรียมข้อมูลสำหรับเรียก Cloud Function
      Map<String, dynamic> body = {
        'uid': uidStr,
        'language': langFolder,
        'fileName': fileName,
        'imageUrl': downloadUrl,
      };

      // เรียก Cloud Function evaluateWriting ผ่าน HTTP POST
      http.Response response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        print("Evaluation successful: Score = ${result['score']}");
      } else {
        print("Cloud Function error: ${response.statusCode} ${response.body}");
        return;
      }

      // เปลี่ยนไปตัวอักษรถัดไป หรือไปหน้าประเมินผลเมื่อฝึกครบแล้ว
      _nextCharacter();
    } catch (e) {
      print("Error in upload and evaluate: $e");
    }
  }

  void _nextCharacter() {
    if (_currentCharacterIndex < _charactersToPractice.length - 1) {
      setState(() {
        _currentCharacterIndex++;
        points.clear();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluationPage(
            language: widget.language,
            character: _charactersToPractice[_currentCharacterIndex],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/Writing_1.png', fit: BoxFit.cover)),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
              onPressed: () => Navigator.pop(context),
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
                RepaintBoundary(
                  key: _repaintBoundaryKey,
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
                        // แสดง template image สำหรับตัวอักษรที่ฝึก
                        Image.asset(
                          widget.language.trim().toLowerCase() == 'english'
                              ? 'assets/English/${_charactersToPractice[_currentCharacterIndex]}.png'
                              : 'assets/Thai/${_charactersToPractice[_currentCharacterIndex]}.jpg',
                          width: 350,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text("ไม่มี Template สำหรับตัวอักษรนี้"),
                        ),
                        // ให้ผู้ใช้วาดลายเส้น
                        GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              points.add(details.localPosition);
                            });
                          },
                          onPanEnd: (_) => points.add(null),
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
                ElevatedButton(
                  onPressed: () => setState(() => points.clear()),
                  child: const Text('เริ่มใหม่'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadImageAndEvaluate,
                  child: const Text('บันทึกและประเมินผล'),
                ),
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
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
