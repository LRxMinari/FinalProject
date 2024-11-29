import 'package:flutter/material.dart';
import 'home_page.dart'; // นำเข้าไฟล์ HomePage
import 'register_page.dart'; // นำเข้าไฟล์ Register Page
import 'forgetpassword_page.dart'; // นำเข้าไฟล์ Forget Password Page

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

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

    // จำลองการรอการเชื่อมต่อ
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (_emailError == null && _passwordError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ถูกต้อง")),
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
