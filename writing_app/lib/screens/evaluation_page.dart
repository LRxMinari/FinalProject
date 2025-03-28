import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  double _score = 0.0; // กำหนดค่าเริ่มต้นให้ _score

  @override
  void initState() {
    super.initState();
    // กำหนดตารางตัวอักษรตามภาษา (ค่า default)
    _characters =
        selectedLanguage == 'English' ? englishCharacters : thaiCharacters;

    // เมื่อเริ่มต้น ให้ใช้ตัวอักษรแรกของตารางเป็นตัวที่เลือก
    if (_characters.isNotEmpty) {
      _selectedCharacter = _characters.first;
      _fetchImage(_selectedCharacter);
      _fetchScore(_selectedCharacter);
    }
  }

  String getCurrentUserUID() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "unknown_user";
  }

  // ดึง URL รูปจาก Firebase Storage ตามตัวอักษรที่เลือก
  Future<void> _fetchImage(String character) async {
    setState(() {
      _isLoading = true;
      _downloadUrl = null;
    });

    try {
      String uid = getCurrentUserUID();
      String languageFolder =
          selectedLanguage == "English" ? "English" : "Thai";
      // ใช้ parameter character ที่ส่งเข้ามา
      String filePath =
          "user_writings/$uid/$languageFolder/writing_$character.png";

      print("Fetching image from: $filePath");

      String downloadUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();

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

  // ดึงคะแนนจาก Firestore ตามตัวอักษรที่เลือก
  Future<void> _fetchScore(String character) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String uid = getCurrentUserUID();
      String languageFolder =
          selectedLanguage == "English" ? "English" : "Thai";

      DocumentSnapshot scoreDoc = await FirebaseFirestore.instance
          .collection("evaluations")
          .doc(uid)
          .collection(languageFolder)
          .doc(character)
          .get();

      if (scoreDoc.exists) {
        setState(() {
          _score = (scoreDoc["score"] as num).toDouble();
        });
      } else {
        setState(() {
          _score = 0.0;
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

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
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
            // กล่องแสดงผลตัวอักษรและคะแนน
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
                    "${_score.toStringAsFixed(2)}% ★★★☆☆",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "ลองฝึกการเขียนให้สมบูรณ์มากขึ้น",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // ตารางตัวอักษร (แถบด้านขวา) สำหรับเปลี่ยนภาษาและเลือกตัวอักษร
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ปุ่มเปลี่ยนภาษา
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
                  // ตารางแสดงตัวอักษร
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

  // ฟังก์ชันสร้างปุ่มเปลี่ยนภาษา
  Widget _buildLanguageTab(String langCode, String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedLanguage = langCode;
            _characters =
                selectedLanguage == "Thai" ? thaiCharacters : englishCharacters;
            // เมื่อเปลี่ยนภาษา ให้ใช้ตัวอักษรแรกของตาราง
            _selectedCharacter = _characters.first;
            _fetchImage(_selectedCharacter);
            _fetchScore(_selectedCharacter);
          });
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

  // ฟังก์ชันสร้าง tile สำหรับเลือกตัวอักษร
  Widget _buildCharacterTile(String char) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = char;
          _fetchImage(char);
          _fetchScore(char);
        });
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

// ตัวอักษรภาษาไทย
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

// ตัวอักษรภาษาอังกฤษ
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
