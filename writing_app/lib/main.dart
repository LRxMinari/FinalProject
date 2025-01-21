import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';

// เพิ่ม FirebaseOptions สำหรับ Web
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBUaN_bf7E9uWUS1Uo70d6U44S1ShetHzk", // คัดลอกจาก Firebase Console
  authDomain: "practice-writing-app-c6bd8.firebaseapp.com",
  projectId: "practice-writing-app-c6bd8",
  storageBucket: "practice-writing-app-c6bd8.firebasestorage.app",
  messagingSenderId: "271773865581",
  appId: "1:271773865581:web:9d0b9c173bb15ab186d164",
  measurementId: "G-YB2RKLXGZD"
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Firebase ด้วย FirebaseOptions
  try {
    await Firebase.initializeApp(options: firebaseOptions);
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
      home: LoginPage(), // หน้าแรกของแอป
    );
  }
}
