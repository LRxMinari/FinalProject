import 'package:flutter/material.dart';
import 'login_page.dart'; // นำเข้า LoginPage

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 0.5; // ใช้สำหรับระดับเสียง
  bool _isMusicOn = true; // ใช้สำหรับสลับเพลง
  String _selectedLanguage = 'ภาษาไทย'; // เลือกภาษา

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
        title: const Text('การตั้งค่า'),
      ),
      backgroundColor: const Color(0xFFFDF6E4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // เพลงประกอบ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('เพลงประกอบ'),
                Switch(
                  value: _isMusicOn,
                  onChanged: (bool value) {
                    setState(() {
                      _isMusicOn = value;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            // ระดับเสียง
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ระดับเสียงเพลง'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_volume > 0) {
                            _volume -= 0.1;
                          }
                        });
                      },
                    ),
                    Text(_volume.toStringAsFixed(1)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (_volume < 1) {
                            _volume += 0.1;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            // การเลือกภาษา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ภาษา'),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                  items: <String>['ภาษาไทย', 'English', 'Chinese']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Divider(),
            // ปุ่มออกจากระบบ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // ใช้ pushAndRemoveUntil เพื่อเคลียร์ Stack และไปหน้า LoginPage
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false, // เคลียร์ Stack ทั้งหมด
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6CFC7),
                  ),
                  child: const Text('ออกจากระบบ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
