import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 0.5; // ใช้สำหรับระดับเสียง
  double _brightness = 0.5; // ใช้สำหรับแสงหน้าจอ
  bool _isMusicOn = true; // ใช้สำหรับสลับเพลง
  bool _isDarkMode = false; // ใช้สำหรับโหมดมืด
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
            // เพลงประประกอบ
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
            // โหมดดึงถอดสายตา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('โหมดถอดสายตา'),
                Switch(
                  value: _isDarkMode,
                  onChanged: (bool value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            // แสงหน้าจอ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('แสงหน้าจอ'),
                Slider(
                  value: _brightness,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  onChanged: (double value) {
                    setState(() {
                      _brightness = value;
                    });
                  },
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
            // ปิดการตั้งค่า
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // ปุ่มออกจากหน้าการตั้งค่า
                  },
                  child: const Text('ออกจากการตั้งค่า'),
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFD6CFC7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
