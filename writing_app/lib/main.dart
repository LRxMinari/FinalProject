import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/login_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// FirebaseOptions สำหรับ Web (ปรับค่าให้ตรงกับโปรเจกต์ของคุณ)
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
      // สำหรับ Web: ใช้ FirebaseOptions ที่ระบุไว้
      await Firebase.initializeApp(options: firebaseOptions);
      // หาก firebase_app_check เวอร์ชันที่ใช้ไม่รองรับ parameter เฉพาะสำหรับ Web ให้ activate แบบปกติ
      await FirebaseAppCheck.instance.activate();
    } else {
      // สำหรับ Android, iOS และ Desktop: ใช้ Firebase.initializeApp() แบบปกติ
      await Firebase.initializeApp();
      await FirebaseAppCheck.instance.activate();
    }

    runApp(const PracticeWritingApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class PracticeWritingApp extends StatelessWidget {
  const PracticeWritingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
