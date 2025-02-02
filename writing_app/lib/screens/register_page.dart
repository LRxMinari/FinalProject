import 'package:flutter/material.dart';
import 'login_page.dart'; // นำเข้า LoginPage
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
  final TextEditingController confirmPasswordController = TextEditingController();

  String nameError = '';
  String surnameError = '';
  String phoneError = '';
  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';

   final bool _isPasswordVisible = false;

  // ฟังก์ชันสำหรับตรวจสอบข้อมูลในแต่ละช่อง
  void _validateField() {
    setState(() {
      nameError = nameController.text.isNotEmpty && nameController.text.isEmpty
          ? 'กรุณากรอกชื่อ'
          : '';
      surnameError =
          surnameController.text.isNotEmpty && surnameController.text.isEmpty
              ? 'กรุณากรอกนามสกุล'
              : '';
      phoneError = phoneController.text.isNotEmpty
          ? !RegExp(r'^[0-9]+$').hasMatch(phoneController.text)
              ? 'เบอร์โทรต้องเป็นตัวเลข'
              : ''
          : '';
      emailError = emailController.text.isNotEmpty
          ? !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                  .hasMatch(emailController.text)
              ? 'รูปแบบอีเมล์ไม่ถูกต้อง'
              : ''
          : '';
      passwordError = passwordController.text.isNotEmpty
          ? passwordController.text.isEmpty
              ? 'กรุณากรอกรหัสผ่าน'
              : ''
          : '';
      confirmPasswordError = confirmPasswordController.text.isEmpty
          ? 'กรุณากรอกยืนยันรหัสผ่าน'
          : confirmPasswordController.text != passwordController.text
              ? 'รหัสผ่านไม่ตรงกัน'
              : '';
    });
  }

  // ฟังก์ชันสำหรับช่องกรอกข้อมูล
  Widget _buildTextField({
    required String label,
    required String hint,
    bool obscureText = false,
    required TextEditingController controller,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: const TextStyle(fontSize: 16),
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: const Color(0xFFECE4D6), // สีพื้นหลังของช่องกรอกข้อมูล
          ),
          onChanged: (_) => _validateField(), // ตรวจสอบข้อมูลเมื่อกรอก
        ),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

   // ฟังก์ชันสำหรับบันทึกข้อมูลผู้ใช้ลงใน Firestore
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

  // ฟังก์ชันสำหรับการสมัครสมาชิกโดยใช้ Firebase
  void _register() async {
  try {
    // ตรวจสอบว่าไม่มีข้อผิดพลาดในข้อมูลที่กรอก
    if (nameError.isEmpty &&
        surnameError.isEmpty &&
        phoneError.isEmpty &&
        emailError.isEmpty &&
        passwordError.isEmpty &&
        confirmPasswordError.isEmpty) {
      // สมัครสมาชิกผู้ใช้กับ Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // บันทึกข้อมูลผู้ใช้ลง Firestore
      await saveUserData(userCredential);

      // แสดงข้อความเมื่อสมัครสมาชิกสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')),
      );

      // แสดง Popup เมื่อสมัครสมาชิกเสร็จแล้ว
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('สมัครสมาชิกสำเร็จ'),
            content: const Text('คุณได้สมัครสมาชิกเรียบร้อยแล้ว'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // ปิด Popup และนำทางไปยังหน้าล็อกอิน
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );
    } else {
      // แสดงข้อความหากข้อมูลไม่ถูกต้อง
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ถูกต้อง')),
      );
    }
  } catch (e) {
    // แสดงข้อความเมื่อเกิดข้อผิดพลาด
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ปุ่มย้อนกลับ
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFDF6E4), // สีพื้นหลังของหน้า
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'สมัครสมาชิก',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'ชื่อ :',
                hint: 'กรุณากรอกชื่อ',
                controller: nameController,
                errorText: nameError,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                label: 'นามสกุล :',
                hint: 'กรุณากรอกนามสกุล',
                controller: surnameController,
                errorText: surnameError,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                label: 'เบอร์โทร :',
                hint: 'กรุณากรอกเบอร์โทร',
                controller: phoneController,
                errorText: phoneError,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                label: 'E-mail :',
                hint: 'กรุณากรอกอีเมล',
                controller: emailController,
                errorText: emailError,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                label: 'Password :',
                hint: 'กรุณากรอกรหัสผ่าน',
                obscureText: true,
                controller: passwordController,
                errorText: passwordError,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                label: 'ยืนยันรหัสผ่าน :',
                hint: 'กรุณากรอกยืนยันรหัสผ่าน',
                obscureText: true,
                controller: confirmPasswordController,
                errorText: confirmPasswordError,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _register, // เรียกใช้ฟังก์ชันสมัครสมาชิก
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6CFC7), // สีของปุ่ม
                  ),
                  child: const Text('สมัครสมาชิก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
