import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 0.5;
  bool _isMusicOn = true;
  String _selectedLanguage = 'ภาษาไทย';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'การตั้งค่า',
            style: GoogleFonts.mali(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [SizedBox(width: 40)], // ทำให้ Title อยู่กึ่งกลางจริง ๆ
      ),
      body: Stack(
        children: [
          // พื้นหลัง
          Positioned.fill(
            child: Image.asset(
              'assets/Writing_1.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  kToolbarHeight +
                  10, // เพิ่มระยะห่างจาก AppBar
              left: 24,
              right: 24,
              bottom: 20, // ป้องกันปุ่มชิดขอบล่าง
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                settingItem(
                  icon: Icons.music_note,
                  title: 'เพลงประกอบ',
                  trailing: Switch(
                    value: _isMusicOn,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        _isMusicOn = value;
                      });
                    },
                  ),
                ),
                const Divider(),
                settingItem(
                  icon: Icons.volume_up,
                  title: 'ระดับเสียงเพลง',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            if (_volume > 0) {
                              _volume -= 0.1;
                            }
                          });
                        },
                      ),
                      Text(
                        _volume.toStringAsFixed(1),
                        style: GoogleFonts.itim(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
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
                ),
                const Divider(),
                settingItem(
                  icon: Icons.language,
                  title: 'ภาษา',
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: Colors.white,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                    items: <String>['ภาษาไทย', 'English']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.itim(fontSize: 18),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                const Spacer(), // ดันปุ่มออกจากระบบไปด้านล่าง

                // ปุ่มออกจากระบบ
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) =>
                            false, // เคลียร์ Stack ทั้งหมด
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('ออกจากระบบ',
                        style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20), // ป้องกันปุ่มติดขอบล่างเกินไป
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget settingItem(
      {required IconData icon,
      required String title,
      required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style:
                    GoogleFonts.itim(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}
