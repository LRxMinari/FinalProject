import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'login_page.dart';

class EvaluationPage extends StatefulWidget {
  final String language;
  final String character;

  const EvaluationPage({
    Key? key,
    required this.language,
    required this.character,
  }) : super(key: key);

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  String? _downloadUrl;
  bool _isLoading = false;
  String _selectedCharacter = '';
  String selectedLanguage = "Thai";
  late List<String> _characters;
  double _score = 0.0; // คะแนนเริ่มต้น
  String _recommendation = "ลองฝึกการเขียนให้สมบูรณ์มากขึ้น"; // ค่าเริ่มต้น

  String? _uid; // UID ของผู้ใช้ที่ล็อกอินอยู่

  // Timers สำหรับ debouncing
  Timer? _debounceImage;
  Timer? _debounceScore;

  // Cache สำหรับเก็บข้อมูลที่ดึงมาแล้ว เพื่อลดการเรียก API ซ้ำ
  final Map<String, String> _imageCache = {};
  final Map<String, double> _scoreCache = {};

  @override
  void initState() {
    super.initState();
    _checkUserAndInitData();
  }

  // ตรวจสอบว่าผู้ใช้ได้ล็อกอินแล้วหรือไม่
  Future<void> _checkUserAndInitData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return;
    }
    _uid = user.uid;
    // กำหนดตัวอักษรเริ่มต้นตามภาษาที่เลือก
    _characters =
        selectedLanguage == 'English' ? englishCharacters : thaiCharacters;
    if (_characters.isNotEmpty) {
      _selectedCharacter = _characters.first;
      _fetchImage(_selectedCharacter);
      _fetchScore(_selectedCharacter);
    }
  }

  // ใช้ debouncing เมื่อมีการเปลี่ยนตัวอักษรหรือเปลี่ยนภาษา
  void _debounceFetchImageAndScore(String character) {
    _debounceImage?.cancel();
    _debounceScore?.cancel();
    _debounceImage = Timer(const Duration(milliseconds: 300), () {
      _fetchImage(character);
    });
    _debounceScore = Timer(const Duration(milliseconds: 300), () {
      _fetchScore(character);
    });
  }

  // ดึง URL รูปจาก Firebase Storage โดยใช้ UID จริง พร้อมใช้ cache เพื่อลดการเรียกซ้ำ
  Future<void> _fetchImage(String character) async {
    if (_uid == null) return;

    final cacheKey = "$selectedLanguage-$character";
    if (_imageCache.containsKey(cacheKey)) {
      setState(() {
        _downloadUrl = _imageCache[cacheKey];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _downloadUrl = null;
    });

    try {
      String languageFolder =
          selectedLanguage == "English" ? "English" : "Thai";
      String filePath =
          "user_writings/$_uid/$languageFolder/writing_$character.png";
      print("Fetching image from: $filePath");
      String downloadUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      _imageCache[cacheKey] = downloadUrl;
      setState(() {
        _downloadUrl = downloadUrl;
      });
      print("Image URL: $downloadUrl");
    } catch (e) {
      print("❌ Error fetching image: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ดึงคะแนนและคำแนะนำจาก Firestore โดยใช้ UID จริง พร้อมใช้ cache เพื่อลดการเรียกซ้ำ
  Future<void> _fetchScore(String character) async {
    if (_uid == null) return;

    final cacheKey = "$selectedLanguage-$character";
    if (_scoreCache.containsKey(cacheKey)) {
      setState(() {
        _score = _scoreCache[cacheKey]!;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String languageFolder =
          selectedLanguage == "English" ? "English" : "Thai";
      DocumentSnapshot scoreDoc = await FirebaseFirestore.instance
          .collection("evaluations")
          .doc(_uid)
          .collection(languageFolder)
          .doc(character)
          .get();
      if (scoreDoc.exists) {
        double fetchedScore = (scoreDoc["score"] as num).toDouble();
        String fetchedRecommendation = scoreDoc["recommendation"] as String;
        _scoreCache[cacheKey] = fetchedScore;
        setState(() {
          _score = fetchedScore;
          _recommendation = fetchedRecommendation;
        });
      } else {
        _scoreCache[cacheKey] = 0.0;
        setState(() {
          _score = 0.0;
          _recommendation = "ลองฝึกการเขียนให้สมบูรณ์มากขึ้น";
        });
      }
    } catch (e) {
      print("❌ Error fetching score: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // นำผู้ใช้กลับไปที่หน้า HomePage
  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  // ฟังก์ชันสำหรับการคำนวณดาวจากคะแนน
  String _buildStars(double score) {
    if (score >= 90) {
      return "★★★★★";
    } else if (score >= 80) {
      return "★★★★☆";
    } else if (score >= 70) {
      return "★★★☆☆";
    } else if (score >= 60) {
      return "★★☆☆☆";
    } else {
      return "★☆☆☆☆";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("การประเมินผล"),
        backgroundColor: Colors.purple[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goHome,
        ),
      ),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนแสดงผลรูปและคะแนน
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.purple[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : _downloadUrl != null
                              ? Image.network(
                                  _downloadUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                      "❌ ไม่พบรูปภาพ",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    );
                                  },
                                )
                              : const Text(
                                  "❌ ไม่พบรูปภาพ",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${_score.toStringAsFixed(2)}%",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _buildStars(_score),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recommendation,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // ส่วนตัวเลือกภาษาและตัวอักษร
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLanguageTab(
                          "Thai", "ภาษาไทย", selectedLanguage == "Thai"),
                      _buildLanguageTab("English", "ภาษาอังกฤษ",
                          selectedLanguage == "English"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: selectedLanguage == "Thai"
                          ? thaiCharacters.length
                          : englishCharacters.length,
                      itemBuilder: (context, index) {
                        String char = selectedLanguage == "Thai"
                            ? thaiCharacters[index]
                            : englishCharacters[index];
                        return _buildCharacterTile(char);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้างปุ่มเปลี่ยนภาษา เมื่อกดจะเปลี่ยนรายการตัวอักษรและดึงข้อมูลใหม่ (ใช้ debouncing)
  Widget _buildLanguageTab(String langCode, String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedLanguage = langCode;
            _characters =
                selectedLanguage == "Thai" ? thaiCharacters : englishCharacters;
            _selectedCharacter = _characters.first;
          });
          _debounceFetchImageAndScore(_selectedCharacter);
          print("✅ Selected language: $selectedLanguage");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Text(text),
      ),
    );
  }

  // สร้าง tile สำหรับเลือกตัวอักษร โดยใช้ debouncing เมื่อมีการเลือก
  Widget _buildCharacterTile(String char) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = char;
        });
        _debounceFetchImageAndScore(char);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedCharacter == char ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            char,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _selectedCharacter == char ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// รายการตัวอักษรสำหรับภาษาไทยและภาษาอังกฤษ
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
