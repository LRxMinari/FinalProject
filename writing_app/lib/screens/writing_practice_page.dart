import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'evaluation_page.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WritingPracticePage extends StatefulWidget {
  final String language;
  final String character;

  const WritingPracticePage(
      {Key? key, required this.language, required this.character})
      : super(key: key);

  @override
  _WritingPracticePageState createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends State<WritingPracticePage> {
  List<Offset?> points = [];
  late List<String> _charactersToPractice;
  int _currentCharacterIndex = 0;
  late ConfettiController _confettiController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // URL ของ Cloud Function ที่ประเมินผล (ซึ่งใน Cloud Function นี้จะใช้ไฟล์ Mask ที่เตรียมไว้)
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

  // ตรวจสอบว่าเด็กวาดแล้วมีเส้นหรือไม่ (bad case)
  bool isBadCase(List<Offset?> points) {
    final validPoints = points.where((p) => p != null).cast<Offset>().toList();
    if (validPoints.isEmpty) return true;
    double minX = validPoints.first.dx;
    double maxX = validPoints.first.dx;
    double minY = validPoints.first.dy;
    double maxY = validPoints.first.dy;
    double totalLength = 0;
    for (int i = 1; i < validPoints.length; i++) {
      Offset prev = validPoints[i - 1];
      Offset curr = validPoints[i];
      totalLength += (curr - prev).distance;
      if (curr.dx < minX) minX = curr.dx;
      if (curr.dx > maxX) maxX = curr.dx;
      if (curr.dy < minY) minY = curr.dy;
      if (curr.dy > maxY) maxY = curr.dy;
    }
    double boundingBoxArea = (maxX - minX) * (maxY - minY);
    print("BoundingBoxArea: $boundingBoxArea, TotalLength: $totalLength");
    return (boundingBoxArea < 800 && totalLength > 300);
  }

  Future<String?> _getCurrentUserUID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        UserCredential credential =
            await FirebaseAuth.instance.signInAnonymously();
        user = credential.user;
        print("Signed in anonymously: ${user?.uid}");
      } catch (e) {
        print("Anonymous sign-in failed: $e");
        return null;
      }
    } else {
      print("User already signed in: ${user.uid}");
    }
    return user?.uid;
  }

  Future<void> _uploadImageAndEvaluate() async {
    if (isBadCase(points)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("การเขียนดูไม่ชัดเจน กรุณาเขียนใหม่!")),
      );
      return;
    }
    try {
      String? uid = await _getCurrentUserUID();
      if (uid == null) {
        print("User not authenticated, cannot upload image.");
        return;
      }
      final langFolder = widget.language.trim().toLowerCase() == 'english'
          ? 'English'
          : 'Thai';
      String character = _charactersToPractice[_currentCharacterIndex];
      String fileName = "writing_$character.png";
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
      String uidStr = uid;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("user_writings/$uidStr/$langFolder/$fileName");
      UploadTask uploadTask = ref.putData(pngBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded: $downloadUrl");

      Map<String, dynamic> body = {
        'uid': uidStr,
        'language': langFolder,
        'fileName': fileName,
        'imageUrl': downloadUrl,
      };

      http.Response response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        double score = result['score'];
        String recommendation = result['recommendation'];
        String status = result['status'];
        print("Evaluation successful: Score = $score");
        // ถ้าเป็นตัวสุดท้ายแล้ว ให้ไปหน้าประเมินผล
        if (_currentCharacterIndex == _charactersToPractice.length - 1) {
          // แสดงข้อความยินดีด้วย (ผ่าน SnackBar หรือปรับเป็นหน้าจอแยกได้)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "เยี่ยมมาก! คุณฝึกครบทุกตัวแล้ว",
                style: GoogleFonts.itim(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EvaluationPage(
                language: widget.language,
                character: character,
              ),
            ),
          );
        } else {
          // ไม่ต้องแสดง popup สำหรับตัวที่ไม่ใช่ตัวสุดท้าย
          print("ยังมีตัวอักษรให้ฝึกต่อไป");
          // เคลียร์การวาดใหม่เพื่อฝึกตัวต่อไป
          setState(() {
            points.clear();
          });
        }
      } else {
        print("Cloud Function error: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เกิดข้อผิดพลาดในการประเมินผล")),
        );
      }
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
      // ถ้าฝึกครบทุกตัวแล้ว ก็ไปหน้าประเมิน (ซึ่งใน _uploadImageAndEvaluate จะจัดการแล้ว)
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
                const Text('ฝึกเขียนตัวอักษร',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 400,
                  height: 300,
                  child: ClipRect(
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              widget.language.trim().toLowerCase() == 'english'
                                  ? 'assets/English/${_charactersToPractice[_currentCharacterIndex]}.png'
                                  : 'assets/Thai/${_charactersToPractice[_currentCharacterIndex]}.jpg',
                              width: 400,
                              height: 300,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text(
                                      "ไม่มี Template สำหรับตัวอักษรนี้"),
                            ),
                          ),
                          GestureDetector(
                            onPanUpdate: (details) {
                              RenderBox box = _repaintBoundaryKey
                                  .currentContext!
                                  .findRenderObject() as RenderBox;
                              Offset localPos =
                                  box.globalToLocal(details.globalPosition);
                              if (localPos.dx >= 0 &&
                                  localPos.dx <= 400 &&
                                  localPos.dy >= 0 &&
                                  localPos.dy <= 300) {
                                setState(() {
                                  points.add(localPos);
                                });
                              }
                            },
                            onPanEnd: (_) {
                              setState(() {
                                points.add(null);
                              });
                            },
                            child: CustomPaint(
                              size: const Size(400, 300),
                              painter: MyPainter(points),
                            ),
                          ),
                        ],
                      ),
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
      ..strokeWidth = 22.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

List<String> thaiCharacters = [
  "ก",
  "ข",
  "ฃ",
  "ค",
  "ฅ",
  "ฆ",
  "ง",
  "จ",
  "ฉ",
  "ช",
  "ซ",
  "ญ",
  "ฎ",
  "ฏ",
  "ฐ",
  "ฑ",
  "ฒ",
  "ณ",
  "ด",
  "ต",
  "ถ",
  "ท",
  "ธ",
  "น",
  "บ",
  "ป",
  "ผ",
  "ฝ",
  "พ",
  "ฟ",
  "ภ",
  "ม",
  "ย",
  "ร",
  "ล",
  "ว",
  "ศ",
  "ษ",
  "ส",
  "ห",
  "ฬ",
  "อ",
  "ฮ"
];

List<String> englishCharacters = [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z"
];
