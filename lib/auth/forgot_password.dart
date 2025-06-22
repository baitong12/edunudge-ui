import 'package:flutter/material.dart';
import 'reset_password.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text(
        "ลืมรหัสผ่าน",
        textAlign: TextAlign.center, 
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("กรุณากรอกอีเมลที่ใช้ในการเข้าสู่ระบบ"),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "อีเมล"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // ปิด popup
          },
          child: const Text("ยกเลิก"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // ปิด popup
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ResetPassword();
              },
            );
          },
          child: const Text("ยืนยัน"),
        ),
      ],
    );
  }
}
