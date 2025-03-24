import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';

class EvaluationPage extends StatefulWidget {
  final String language;
  final String character;

  const EvaluationPage({
    super.key,
    required this.language,
    required this.character,
  });

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  String? _downloadUrl;
  bool _isLoading = false;
  String _selectedCharacter = '';
  String selectedLanguage = "Thai"; // ✅ กำหนดค่าเริ่มต้นให้ selectedLanguage
  late List<String> _characters;

  @override
  void initState() {
    super.initState();
    _characters =
        selectedLanguage == 'English' ? englishCharacters : thaiCharacters;

    if (_characters.isNotEmpty) {
      _selectedCharacter = _characters.first;
      _fetchImage(_selectedCharacter);
    }
  }

  String getCurrentUserUID() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "unknown_user";
  }

  Future<void> _fetchImage(String character) async {
    setState(() {
      _isLoading = true;
      _downloadUrl = null;
    });

    try {
      String uid = getCurrentUserUID();
      String languageFolder =
          selectedLanguage == "English" ? "English" : "Thai";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("การประเมินผล"),
        backgroundColor: Colors.purple[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage()), // 🔥 เปลี่ยน HomePage เป็นหน้าหลักของคุณ
              (Route<dynamic> route) => false, // ❌ ลบทุกหน้าเก่าทิ้ง
            );
          },
        ),
      ),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // กล่องแสดงผลตัวอักษร
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
                  const Text(
                    "86.0% ★★★☆☆",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

            // ตารางตัวอักษร (ฝั่งขวา)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ ปุ่มเปลี่ยนภาษา
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

                  // ตารางตัวอักษร
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

  // ✅ ฟังก์ชันสร้างปุ่มเปลี่ยนภาษา
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
            _fetchImage(_selectedCharacter);
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

  // ✅ ปุ่มเลือกตัวอักษร
  Widget _buildCharacterTile(String char) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = char;
        });
        _fetchImage(char);
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

// ✅ ตัวอักษรภาษาไทย
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

// ✅ ตัวอักษรภาษาอังกฤษ
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
