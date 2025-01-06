import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';

// เพิ่ม FirebaseOptions สำหรับ Web
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'YOUR_API_KEY', // คัดลอกจาก Firebase Console
  authDomain: 'YOUR_AUTH_DOMAIN',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  appId: 'YOUR_APP_ID',
  measurementId: 'YOUR_MEASUREMENT_ID',
  databaseURL: 'YOUR_DATABASE_URL', // ใช้หากใช้ Realtime Database
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
      home: LoginPage(),
    );
  }
}
