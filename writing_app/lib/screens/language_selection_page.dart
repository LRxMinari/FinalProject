import 'package:flutter/material.dart';
import 'writing_practice_page.dart'; // นำเข้าหน้าฝึกเขียน

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ปุ่มย้อนกลับ
          },
        ),
      ),
      backgroundColor: const Color(0xFFFDF6E4),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'หมวดหมู่ภาษา',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _buildLanguageButton('ภาษาไทย', Icons.language, 'ก'),
              const SizedBox(height: 16),
              _buildLanguageButton('English', Icons.translate, 'A'),
            ],
          ),
        ),
      ),
    );
  }

// ฟังก์ชันสร้างปุ่มภาษา
  Widget _buildLanguageButton(
      String language, IconData icon, String character) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language; // อัปเดตภาษาที่เลือก
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WritingPracticePage(
              language: language,
              character: character,
            ),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFECE4D6),
            child: Icon(
              icon,
              size: 30,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
