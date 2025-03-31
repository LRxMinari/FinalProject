import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetLink() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
    });
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ลิงก์สำหรับรีเซ็ตรหัสผ่านถูกส่งแล้ว!',
            style: GoogleFonts.itim(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'เกิดข้อผิดพลาด',
            style: GoogleFonts.itim(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เกิดข้อผิดพลาด: ${e.toString()}',
            style: GoogleFonts.itim(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ไม่ใช้ AppBar
      body: Stack(
        children: [
          // พื้นหลัง
          Positioned(
            top: -600,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/Writing_1.png', // รูปพื้นหลัง
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.lock_outline,
                      size: 80, color: Colors.black87),
                  const SizedBox(height: 20),
                  Text(
                    'ลืมรหัสผ่าน',
                    style: GoogleFonts.mali(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'กรุณากรอกที่อยู่อีเมลที่คุณใช้สมัคร\nระบบจะส่งลิงก์ไปให้คุณ',
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.itim(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  // ช่องกรอกอีเมล
                  Container(
                    width: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'E-mail',
                        hintText: 'example@email.com',
                        labelStyle: GoogleFonts.itim(fontSize: 18),
                        errorText: _emailError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _emailError = 'กรุณากรอกอีเมล';
                          } else if (!_isValidEmail(value)) {
                            _emailError = 'รูปแบบอีเมลไม่ถูกต้อง';
                          } else {
                            _emailError = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ปุ่มส่งลิงก์รีเซ็ตรหัสผ่าน
                  SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_emailController.text.isEmpty) {
                                setState(() {
                                  _emailError = 'กรุณากรอกอีเมล';
                                });
                              } else if (!_isValidEmail(
                                  _emailController.text)) {
                                setState(() {
                                  _emailError = 'รูปแบบอีเมลไม่ถูกต้อง';
                                });
                              } else {
                                _sendPasswordResetLink();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                              style: GoogleFonts.itim(
                                  fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ปุ่มย้อนกลับ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'มีบัญชีกับเราแล้ว?',
                        style: GoogleFonts.itim(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDE8D3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ล็อกอินเข้าสู่ระบบ',
                            style: GoogleFonts.itim(
                                fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
