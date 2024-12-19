import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Firebase และตรวจสอบการเริ่มต้น
  try {
    await Firebase.initializeApp();
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
