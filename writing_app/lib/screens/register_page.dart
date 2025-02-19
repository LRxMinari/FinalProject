import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ใช้ Google Fonts
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? nameError;
  String? surnameError;
  String? phoneError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void _validateField() {
    Map<String, String?> errors = {
      'name': nameController.text.isEmpty ? 'กรุณากรอกชื่อ' : null,
      'surname': surnameController.text.isEmpty ? 'กรุณากรอกนามสกุล' : null,
      'phone': phoneController.text.isEmpty
          ? 'กรุณากรอกเบอร์โทร'
          : !RegExp(r'^[0-9]+$').hasMatch(phoneController.text)
              ? 'เบอร์โทรต้องเป็นตัวเลข'
              : null,
      'email': emailController.text.isEmpty
          ? 'กรุณากรอกอีเมล'
          : !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                  .hasMatch(emailController.text)
              ? 'รูปแบบอีเมลไม่ถูกต้อง'
              : null,
      'password': passwordController.text.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
      'confirmPassword': confirmPasswordController.text.isEmpty
          ? 'กรุณากรอกยืนยันรหัสผ่าน'
          : confirmPasswordController.text != passwordController.text
              ? 'รหัสผ่านไม่ตรงกัน'
              : null,
    };

    setState(() {
      nameError = errors['name'];
      surnameError = errors['surname'];
      phoneError = errors['phone'];
      emailError = errors['email'];
      passwordError = errors['password'];
      confirmPasswordError = errors['confirmPassword'];
    });
  }

  Future<void> saveUserData(UserCredential userCredential) async {
    try {
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  void _register() async {
    try {
      _validateField();
      if (nameError == null &&
          surnameError == null &&
          phoneError == null &&
          emailError == null &&
          passwordError == null &&
          confirmPasswordError == null) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        await saveUserData(userCredential);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('สมัครสมาชิกสำเร็จ', style: GoogleFonts.poppins()),
              content: Text('คุณได้สมัครสมาชิกเรียบร้อยแล้ว',
                  style: GoogleFonts.poppins()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: Text('ตกลง',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกข้อมูลให้ถูกต้อง')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    bool obscureText = false,
    required TextEditingController controller,
    String? errorText,
  }) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.itim(fontSize: 18),
          errorText: errorText,
        ),
        onChanged: (_) => _validateField(),
      ),
    );
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Writing_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'สมัครสมาชิก',
                    style: GoogleFonts.mali(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'ชื่อ',
                      hint: 'กรุณากรอกชื่อ',
                      controller: nameController,
                      errorText: nameError),
                  const SizedBox(height: 8),
                  _buildTextField(
                      label: 'นามสกุล',
                      hint: 'กรุณากรอกนามสกุล',
                      controller: surnameController,
                      errorText: surnameError),
                  const SizedBox(height: 8),
                  _buildTextField(
                      label: 'เบอร์โทร',
                      hint: 'กรุณากรอกเบอร์โทร',
                      controller: phoneController,
                      errorText: phoneError),
                  const SizedBox(height: 8),
                  _buildTextField(
                      label: 'E-mail',
                      hint: 'กรุณากรอกอีเมล',
                      controller: emailController,
                      errorText: emailError),
                  const SizedBox(height: 8),
                  _buildTextField(
                      label: 'Password',
                      hint: 'กรุณากรอกรหัสผ่าน',
                      obscureText: true,
                      controller: passwordController,
                      errorText: passwordError),
                  const SizedBox(height: 8),
                  _buildTextField(
                      label: 'ยืนยันรหัสผ่าน',
                      hint: 'กรุณากรอกยืนยันรหัสผ่าน',
                      obscureText: true,
                      controller: confirmPasswordController,
                      errorText: confirmPasswordError),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('สมัครสมาชิก',
                          style: GoogleFonts.itim(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
