import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';

class EvaluationPage extends StatefulWidget {
  final String language; // ภาษา (Thai / English)
  final String character; // เพิ่มตัวแปร character

  const EvaluationPage({
    super.key,
    required this.language,
    required this.character, // ใส่ this.character ตรงนี้
  });

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  String? _downloadUrl; // เก็บ URL ของรูปที่ดึงมาได้
  bool _isLoading = false; // ใช้แสดงสถานะโหลดข้อมูล
  String _selectedCharacter = ''; // ตัวอักษรที่ถูกเลือก

  late List<String> _characters; // รายชื่อตัวอักษรของแต่ละภาษา

  @override
  void initState() {
    super.initState();
    _characters = widget.language == 'English'
        ? List.generate(26, (index) => String.fromCharCode(65 + index)) // A-Z
        : [
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
          ]; // ตัวอักษรไทย

    if (_characters.isNotEmpty) {
      _selectedCharacter = _characters.first; // เริ่มที่ตัวแรก
      _fetchImage(_selectedCharacter);
    }
  }

  // ✅ ดึง UID ของผู้ใช้
  String getCurrentUserUID() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "unknown_user";
  }

  // ✅ ดึง URL ของรูปจาก Firebase Storage
  Future<void> _fetchImage(String character) async {
    setState(() {
      _isLoading = true;
      _downloadUrl = null;
    });

    try {
      String uid = getCurrentUserUID();
      String languageFolder = widget.language == "English" ? "English" : "Thai";
      String filePath =
          "user_writings/$uid/$languageFolder/writing_$character.png";

      print("📢 Fetching image from: $filePath");

      String downloadUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();

      setState(() {
        _downloadUrl = downloadUrl;
      });

      print("✅ Image URL: $downloadUrl");
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
      appBar: AppBar(title: Text("ประเมินตัวอักษร (${widget.language})")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // ✅ แสดงปุ่มเลือกตัวอักษร
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _characters.map((char) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCharacter = char;
                    });
                    _fetchImage(char);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedCharacter == char
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      char,
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedCharacter == char
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ แสดงผลรูปภาพที่โหลดมา
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _downloadUrl != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "รูปที่คุณเขียน: $_selectedCharacter",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Image.network(_downloadUrl!,
                                width: 300, height: 300, fit: BoxFit.contain),
                          ],
                        )
                      : const Text("❌ ไม่พบรูปที่คุณเขียน",
                          style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
