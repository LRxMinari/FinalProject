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
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ลิงก์สำหรับรีเซ็ตรหัสผ่านได้ถูกส่งแล้ว!',
            style: GoogleFonts.itim(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ให้พื้นหลังเต็มจอรวมถึงด้านหลัง AppBar
      body: Stack(
        children: [
          // พื้นหลัง
          Positioned(
            top: -600, // เลื่อนภาพพื้นหลังขึ้น 50px
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/Writing_1.png', // รูปพื้นหลัง
              fit: BoxFit.cover, // ให้ภาพเต็มหน้าจอ
              alignment: Alignment.bottomCenter,
            ),
          ),

          // คอนเทนต์หลัก
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.black87),
                  const SizedBox(height: 20),

                  // หัวข้อ
                  Text(
                    'ลืมรหัสผ่าน',
                    style: GoogleFonts.mali(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // คำอธิบาย
                  Text(
                    'กรุณากรอกที่อยู่อีเมลที่คุณใช้สมัคร\nระบบจะส่งลิงก์ไปให้คุณ',
                    style:
                        GoogleFonts.itim(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // ช่องกรอกอีเมล
                  Container(
                    width: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
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
                            _emailError = 'กรุณากรอกอีเมล์';
                          } else if (!_isValidEmail(value)) {
                            _emailError = 'รูปแบบอีเมล์ไม่ถูกต้อง';
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
                      onPressed: () {
                        if (_emailController.text.isEmpty) {
                          setState(() {
                            _emailError = 'กรุณากรอกอีเมล์';
                          });
                        } else if (!_isValidEmail(_emailController.text)) {
                          setState(() {
                            _emailError = 'รูปแบบอีเมล์ไม่ถูกต้อง';
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
                      child: Text(
                        'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                        style:
                            GoogleFonts.itim(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ปุ่มย้อนกลับ
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // จัดให้อยู่กึ่งกลาง
                    children: [
                      Text(
                        'มีบัญชีกับเราแล้ว?',
                        style: GoogleFonts.itim(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8), // ระยะห่างระหว่างข้อความและปุ่ม
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color(0xFFCDE8D3), // สีเขียวอ่อน
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ล็อคอินเข้าสู่ระบบ',
                            style: GoogleFonts.itim(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
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
