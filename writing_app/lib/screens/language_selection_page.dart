import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'writing_practice_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Writing_1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'หมวดหมู่ภาษา',
              textAlign: TextAlign.center,
              style: GoogleFonts.itim(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 109, 20, 0),
                height: 1,
              ),
            ),
            const SizedBox(height: 32),
            _buildLanguageButton('ภาษาไทย', 'Thai', 'ก'),
            const SizedBox(height: 24),
            _buildLanguageButton('ภาษาอังกฤษ', 'English', 'A'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
      String languageTH, String languageEN, String character) {
    return GestureDetector(
      onTap: () => _onLanguageSelected(languageEN, character),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFCDE5D7),
            child: Center(
              child: Text(
                languageTH,
                style: GoogleFonts.itim(fontSize: 22, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            languageEN,
            style: GoogleFonts.itim(fontSize: 20, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _onLanguageSelected(String language, String character) {
    setState(() {
      _selectedLanguage = language;
    });

    if (_selectedLanguage == null || _selectedLanguage!.isEmpty) {
      print("⚠️ Language is empty!");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WritingPracticePage(
            language: language,
            character: character, // ส่งค่าตัวอักษรไปด้วย
          ),
        ),
      );
    }
  }
}
