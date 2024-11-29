import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = 'ภาษาไทย'; // ค่าเริ่มต้นของภาษาที่เลือก

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
              _buildLanguageButton('ภาษาไทย', Icons.language),
              const SizedBox(height: 16),
              _buildLanguageButton('English', Icons.translate),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างปุ่มภาษา
  Widget _buildLanguageButton(String language, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: _selectedLanguage == language
                ? Colors.lightGreenAccent
                : const Color(0xFFECE4D6),
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
