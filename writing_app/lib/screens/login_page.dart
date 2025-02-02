import 'package:flutter/material.dart';
import 'home_page.dart'; // นำเข้าไฟล์ HomePage
import 'register_page.dart'; // นำเข้าไฟล์ Register Page
import 'forgetpassword_page.dart'; // นำเข้าไฟล์ Forget Password Page
import 'package:firebase_auth/firebase_auth.dart'; // เพิ่มการนำเข้า FirebaseAuth

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false; // สถานะแสดง/ซ่อนรหัสผ่าน
  bool _isLoading = false; // สถานะการโหลด

  // ฟังก์ชันสำหรับตรวจสอบรูปแบบอีเมล
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // ฟังก์ชันสำหรับตรวจสอบข้อมูลเมื่อกรอก
  void _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() {
        _emailError = 'กรุณากรอกอีเมล';
      });
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'รูปแบบอีเมลไม่ถูกต้อง';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'กรุณากรอกรหัสผ่าน';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

   // ฟังก์ชันจัดการการล็อกอิน
  void _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // ใช้งาน Firebase Authentication สำหรับการล็อกอิน
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // การล็อกอินสำเร็จ
    setState(() {
      _isLoading = false;
    });

    // แสดง Popup เมื่อเข้าสู่ระบบสำเร็จ
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เข้าสู่ระบบสำเร็จ'),
          content: const Text('ยินดีต้อนรับสู่ระบบของเรา!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Popup
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'เกิดข้อผิดพลาด')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Practice Writing',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // ช่องกรอกอีเมล
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'กรุณากรอกอีเมล',
                  filled: true,
                  fillColor: const Color(0xFFECE4D6),
                  border: const OutlineInputBorder(),
                  errorText: _emailError, // แสดงข้อผิดพลาดอีเมล
                ),
                onChanged: (value) {
                  // ตรวจสอบอีเมลเมื่อกรอกข้อมูล
                  _validateEmail(value);
                },
              ),
              const SizedBox(height: 16),
              // ช่องกรอกรหัสผ่าน
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'กรุณากรอกรหัสผ่าน',
                  filled: true,
                  fillColor: const Color(0xFFECE4D6),
                  border: const OutlineInputBorder(),
                  errorText: _passwordError, // แสดงข้อผิดพลาดรหัสผ่าน
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  // ตรวจสอบรหัสผ่านเมื่อกรอกข้อมูล
                  _validatePassword(value);
                },
              ),
              const SizedBox(height: 16),
              // ปุ่มล็อกอิน
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6CFC7),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: Colors.black)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forget Password',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}