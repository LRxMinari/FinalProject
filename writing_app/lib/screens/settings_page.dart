import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [SizedBox(width: 40)],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -600, // เลื่อนภาพพื้นหลังขึ้น 50px
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/Writing_1.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  settingCard(
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
                  settingCard(
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
                  settingCard(
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn()
                          .signOut(); // สำคัญสำหรับผู้ใช้ที่ล็อกอินผ่าน Google

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                    child: Text('ออกจากระบบ',
                        style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingCard(
      {required IconData icon,
      required String title,
      required Widget trailing}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blueGrey, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.itim(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
