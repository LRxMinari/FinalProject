import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // เพิ่ม dependency audioplayers
import 'home_page.dart';
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

  AudioPlayer _audioPlayer = AudioPlayer();
  // URL หรือ path ของไฟล์เพลงใน assets (หรือสามารถใช้ AssetSource)
  // สมมุติว่าเพลงอยู่ที่ assets/background_music.mp3
  String musicPath = "assets/background_music.mp3";

  @override
  void initState() {
    super.initState();
    // เริ่มเล่นเพลงถ้าตัวเลือกเปิดเพลงถูกเปิดไว้
    if (_isMusicOn) {
      _startMusic();
    }
  }

  Future<void> _startMusic() async {
    // เล่นเพลงใน loop ด้วย audioplayers (ใช้ setReleaseMode)
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // เริ่มเล่นเพลงจาก assets (แน่ใจว่าได้ระบุใน pubspec.yaml แล้ว)
    await _audioPlayer.play(AssetSource("background_music.mp3"),
        volume: _volume);
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
  }

  void _toggleMusic(bool value) {
    setState(() {
      _isMusicOn = value;
    });
    if (_isMusicOn) {
      _startMusic();
    } else {
      _stopMusic();
    }
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(_volume);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้ extendBodyBehindAppBar เพื่อให้พื้นหลังแสดงเต็มหน้าจอ
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
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        actions: [const SizedBox(width: 40)],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -600,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  settingCard(
                    icon: Icons.music_note,
                    title: 'เพลงประกอบ',
                    trailing: Switch(
                      value: _isMusicOn,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        _toggleMusic(value);
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
                            if (_volume > 0) {
                              _changeVolume((_volume - 0.1).clamp(0.0, 1.0));
                            }
                          },
                        ),
                        Text(
                          _volume.toStringAsFixed(1),
                          style: GoogleFonts.itim(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            if (_volume < 1) {
                              _changeVolume((_volume + 0.1).clamp(0.0, 1.0));
                            }
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
                          child: Text(value,
                              style: GoogleFonts.itim(fontSize: 18)),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn().signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 5,
                    ),
                    child: Text(
                      'ออกจากระบบ',
                      style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
