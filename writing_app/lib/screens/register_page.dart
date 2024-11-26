import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String nameError = '';
  String surnameError = '';
  String phoneError = '';
  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';

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
              ? 'กรุณากรอกอีเมลที่ถูกต้อง'
              : ''
          : '';
      passwordError = passwordController.text.isNotEmpty
          ? passwordController.text.isEmpty
              ? 'กรุณากรอกรหัสผ่าน'
              : ''
          : '';
      confirmPasswordError = confirmPasswordController.text.isNotEmpty
          ? confirmPasswordController.text != passwordController.text
              ? 'รหัสผ่านไม่ตรงกัน'
              : ''
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
                  onPressed: () {
                    // ตรวจสอบข้อมูลทั้งหมดเมื่อกดปุ่ม
                    if (nameError.isEmpty &&
                        surnameError.isEmpty &&
                        phoneError.isEmpty &&
                        emailError.isEmpty &&
                        passwordError.isEmpty &&
                        confirmPasswordError.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("สมัครสมาชิกสำเร็จ")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("กรุณากรอกข้อมูลให้ถูกต้อง")),
                      );
                    }
                  },
                  child: const Text('สมัครสมาชิก'),
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFD6CFC7), // สีของปุ่ม
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
