import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError; // ใช้เก็บข้อความแสดงข้อผิดพลาดของอีเมล

  // ฟังก์ชันตรวจสอบรูปแบบอีเมล
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E4), // สีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'กรุณากรอกที่อยู่อีเมลที่คุณลงทะเบียน',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFECE4D6),
                    errorText: _emailError, // แสดงข้อความข้อผิดพลาดถ้ามี
                  ),
                  onChanged: (value) {
                    setState(() {
                      // ตรวจสอบรูปแบบอีเมล
                      if (value.isEmpty) {
                        _emailError = 'กรุณากรอกอีเมล์';
                      } else if (!_isValidEmail(value)) {
                        _emailError = 'รูปแบบอีเมล์ไม่ถูกต้อง';
                      } else {
                        _emailError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // ตรวจสอบอีกครั้งก่อนกดปุ่ม
                    if (_emailController.text.isEmpty) {
                      setState(() {
                        _emailError = 'กรุณากรอกอีเมล์';
                      });
                    } else if (!_isValidEmail(_emailController.text)) {
                      setState(() {
                        _emailError = 'รูปแบบอีเมล์ไม่ถูกต้อง';
                      });
                    } else {
                      // เพิ่มฟังก์ชันการรีเซ็ตรหัสผ่าน
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset link has been sent!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6CFC7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
