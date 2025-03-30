import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'forgetpassword_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  @override
  void initState() {
    super.initState();
    // ตรวจสอบสถานะผู้ใช้ ถ้ามีผู้ใช้ล็อกอินอยู่แล้ว ให้ไปที่ HomePage ทันที
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // ถ้าผู้ใช้ล็อกอินอยู่แล้ว ให้รีไดเรคไปหน้า HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

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
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // เมื่อ login สำเร็จ authStateChanges listener จะรีไดเรคไปหน้า HomePage
      setState(() => _isLoading = false);
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(e.message ?? 'เกิดข้อผิดพลาด', style: GoogleFonts.poppins()),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // ผู้ใช้ยกเลิก
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      // authStateChanges listener จะรีไดเรคไปหน้า HomePage
    } catch (e) {
      print("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เข้าสู่ระบบด้วย Google ล้มเหลว")));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, String? errorText,
      {bool isPassword = false}) {
    return Container(
      width: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
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
        onChanged: (value) {
          if (label == "E-mail") _validateEmail(value);
          if (label == "Password") _validatePassword(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Positioned(
            top: -600,
            left: 0,
            right: 0,
            child: Image.asset('assets/Writing_1.png', fit: BoxFit.cover),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Column(
                      children: [
                        Text('WRITING\nPRACTICE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.luckiestGuy(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 109, 20, 0),
                                height: 1)),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Text('APPLICATION',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 40,
                                color: const Color.fromARGB(255, 109, 20, 0),
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Email field
                    _buildTextField(_emailController, 'E-mail',
                        'example@email.com', _emailError),
                    const SizedBox(height: 16),
                    // Password field
                    _buildTextField(_passwordController, 'Password',
                        'กรุณากรอกรหัสผ่าน', _passwordError,
                        isPassword: true),
                    const SizedBox(height: 8),
                    // Login button
                    SizedBox(
                      width: 500,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('เข้าสู่ระบบ',
                                style: GoogleFonts.itim(
                                    fontSize: 22, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Forgot password button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordPage()));
                      },
                      child: Text('ลืมรหัสผ่าน?',
                          style: GoogleFonts.mali(
                              color: const Color.fromARGB(255, 255, 0, 0),
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 1),
                    // Register button
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
                                    builder: (context) =>
                                        const RegisterPage()));
                          },
                          child: Text('สมัครสมาชิก',
                              style: GoogleFonts.mali(
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 0, 204, 255),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Google Sign-In button
                    SizedBox(
                      width: 500,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Image.asset('assets/google_logo.png', height: 24),
                        label: Text('Sign in with Google',
                            style: GoogleFonts.itim(
                                fontSize: 20, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
