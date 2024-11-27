import 'package:flutter/material.dart';
import 'settings_page.dart'; // นำเข้าไฟล์ SettingsPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6E4),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // เมื่อคลิกที่ปุ่มตั้งค่า จะไปยังหน้า Settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF6E4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Home Page',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFECE4D6),
                        child: Icon(Icons.pets, size: 40),
                      ),
                      const Text('ประเมินผลลัพธ์'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFECE4D6),
                        child: Icon(Icons.edit, size: 40),
                      ),
                      const Text('ฝึกเขียน'),
                    ],
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
