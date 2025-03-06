import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ใช้ Google Fonts
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
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _validateEmail(String email) {
    setState(() {
      _emailError = email.isEmpty
          ? 'กรุณากรอกอีเมล'
          : (!_isValidEmail(email) ? 'รูปแบบอีเมลไม่ถูกต้อง' : null);
    });
  }

  void _validatePassword(String password) {
    setState(() {
      _passwordError = password.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null;
    });
  }

  void _login() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('เข้าสู่ระบบสำเร็จ', style: GoogleFonts.poppins()),
            content: Text('ยินดีต้อนรับสู่ระบบของเรา!',
                style: GoogleFonts.poppins()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Text('ตกลง',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message ?? 'เกิดข้อผิดพลาด',
                style: GoogleFonts.poppins())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ทำให้พื้นหลังอยู่หลัง AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // **ภาพพื้นหลัง**
          Positioned(
            top: -600, // เลื่อนภาพพื้นหลังขึ้น 50px
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/Writing_1.png',
              fit: BoxFit.cover,
            ),
          ),

          // **คอนเทนต์หลัก (UI หน้า Login)**
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // **Title**
                  Column(
                    children: [
                      Text(
                        'WRITING\nPRACTICE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 109, 20, 0),
                          height: 1,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -10), // ขยับขึ้น 10 พิกเซล
                        child: Text(
                          'APPLICATION',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 40,
                            color: const Color.fromARGB(255, 109, 20, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // **ช่องกรอก Email**
                  _buildTextField(_emailController, 'E-mail',
                      'example@email.com', _emailError),

                  const SizedBox(height: 16),

                  // **ช่องกรอก Password**
                  _buildTextField(_passwordController, 'Password',
                      'กรุณากรอกรหัสผ่าน', _passwordError,
                      isPassword: true),

                  const SizedBox(height: 8),

                  // **ปุ่มเข้าสู่ระบบ**
                  SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('เข้าสู่ระบบ',
                              style: GoogleFonts.itim(
                                  fontSize: 22, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // **ปุ่มลืมรหัสผ่าน**
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgetPasswordPage()));
                    },
                    child: Text('ลืมรหัสผ่าน?',
                        style: GoogleFonts.mali(
                            color: const Color.fromARGB(255, 255, 0, 0),
                            fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 1),

                  // **ปุ่มสมัครสมาชิก**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ยังไม่มีบัญชี?",
                          style: GoogleFonts.mali(
                              fontSize: 14, color: Colors.black)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                        child: Text('สมัครสมาชิก',
                            style: GoogleFonts.mali(
                                fontSize: 18,
                                color: const Color.fromARGB(255, 0, 204, 255),
                                fontWeight: FontWeight.bold)),
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

// **ฟังก์ชันสร้างช่องกรอกข้อมูล**
  Widget _buildTextField(TextEditingController controller, String label,
      String hint, String? errorText,
      {bool isPassword = false}) {
    return Container(
      width: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.itim(fontSize: 18),
          errorText: errorText,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
        ),
      ),
    );
  }
}
