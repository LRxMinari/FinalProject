import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/login_page.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBUaN_bf7E9uWUS1Uo70d6U44S1ShetHzk",
  authDomain: "practice-writing-app-c6bd8.firebaseapp.com",
  projectId: "practice-writing-app-c6bd8",
  storageBucket: "practice-writing-app-c6bd8.firebasestorage.app",
  messagingSenderId: "271773865581",
  appId: "1:271773865581:web:9d0b9c173bb15ab186d164",
  measurementId: "G-YB2RKLXGZD",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: firebaseOptions);
      await FirebaseAppCheck.instance.activate();
    } else {
      await Firebase.initializeApp();
      await FirebaseAppCheck.instance.activate();
    }
    runApp(const PracticeWritingApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class PracticeWritingApp extends StatefulWidget {
  const PracticeWritingApp({Key? key}) : super(key: key);

  @override
  _PracticeWritingAppState createState() => _PracticeWritingAppState();
}

class _PracticeWritingAppState extends State<PracticeWritingApp> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _startBackgroundMusic();
  }

  Future<void> _startBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      AssetSource("Old MacDonald Had A Farm.mp3"),
      volume: 0.5,
    );
  }

  @override
  void dispose() {
    // ปล่อยทรัพยากรเมื่อแอปปิด (แต่ widget นี้จะอยู่ตลอดการใช้งานแอป)
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp นี้จะครอบคลุมแอปทั้งแอป
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // หน้าแรกที่ต้องการให้แสดง (เช่น LoginPage)
    );
  }
}
