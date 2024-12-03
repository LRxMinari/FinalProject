import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const PracticeWritingApp());
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
