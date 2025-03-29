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
    // ตรวจสอบว่ากำลังรันบน Web หรือไม่
    if (kIsWeb) {
      // สำหรับ Web: ใช้ Firebase.initializeApp() พร้อม FirebaseOptions
      await Firebase.initializeApp(options: firebaseOptions);
      // เรียกใช้ App Check
      await FirebaseAppCheck.instance.activate();
    } else {
      // สำหรับ Android/iOS/Desktop: เรียก Firebase.initializeApp() แบบปกติ
      await Firebase.initializeApp();
      // เรียกใช้ App Check
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
