import 'package:flutter/material.dart';

class EvaluationPage extends StatelessWidget {
  final String character;
  final double score;
  final int stars;
  final String feedback;

  const EvaluationPage({
    Key? key,
    this.character = '', // กำหนดค่าเริ่มต้น
    this.score = 0.0, // กำหนดค่าเริ่มต้น
    this.stars = 0, // กำหนดค่าเริ่มต้น
    this.feedback = '', // กำหนดค่าเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6E4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ปุ่มย้อนกลับ
          },
        ),
      ),
      backgroundColor: const Color(0xFFFDF6E4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // คำว่าการประเมินผล
            const Text(
              'การประเมินผล',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE4D6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ตัวอักษรที่ฝึกเขียน
                      Text(
                        'ตัวอักษร: $character',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // คะแนนที่ได้
                      Text(
                        'คะแนน: ${score.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // จำนวนดาวที่ได้
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < stars
                                ? Icons.star
                                : Icons.star_border_outlined,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ข้อเสนอแนะ
                      Text(
                        'ข้อเสนอแนะ: $feedback',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // ปุ่มการกระทำ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // กดเพื่อฝึกเขียนใหม่
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[400],
                            ),
                            child: const Text('ลองใหม่'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // กลับไปหน้าแรก
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                            ),
                            child: const Text('กลับหน้าแรก'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
