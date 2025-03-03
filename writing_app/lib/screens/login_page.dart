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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Writing_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'WRITING\nPRACTICE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 100, // ปรับขนาดตัวอักษร
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 109, 20, 0),
                        height: 1, // ลดค่าลงเพื่อให้บรรทัดชิดกัน
                      ),
                    ),
                    Transform.translate(
                      offset:
                          Offset(0, -10), // ขยับขึ้น 10 พิกเซลเพื่อลดระยะห่าง
                      child: Text(
                        'APPLICATION',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 40, // ปรับขนาดให้เล็กลง
                          color: const Color.fromARGB(255, 109, 20, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 450, // ปรับขนาดให้เล็กลง
                  child: Container(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5), // ลด padding
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'E-mail',
                        hintText: 'example@email.com',
                        labelStyle: GoogleFonts.itim(fontSize: 18),
                        errorText: _emailError,
                      ),
                      onChanged: _validateEmail,
                    ),
                  ),
                ),

                const SizedBox(height: 10), // ลดระยะห่างระหว่างกล่อง
                SizedBox(
                  width: 450, // ปรับขนาดให้เล็กลง
                  child: Container(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5), // ลด padding
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Password',
                        hintText: 'กรุณากรอกรหัสผ่าน',
                        labelStyle: GoogleFonts.itim(fontSize: 18),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      onChanged: _validatePassword,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // **ปุ่มเข้าสู่ระบบ**
                SizedBox(
                  width: 450, // กำหนดให้กว้างเท่ากับกล่องข้อความ
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14), // กำหนดความสูงของปุ่ม
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // ให้ตรงกับกล่องข้อความ
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'เข้าสู่ระบบ',
                            style: GoogleFonts.itim(
                                fontSize: 22, color: Colors.white),
                          ),
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
                          fontSize: 14,
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
                          fontSize: 14,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        )),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                      },
                      child: Text(
                        'สมัครสมาชิก',
                        style: GoogleFonts.mali(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 105, 205, 255),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
