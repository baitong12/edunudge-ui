import 'package:flutter/material.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

    @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    TextEditingController otpController = TextEditingController();

    return AlertDialog(
      title: const Text(
        "ตั้งค่ารหัสผ่าน",
        textAlign: TextAlign.center, 
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "รหัสผ่านใหม่"),
            obscureText: true,
          ),
          TextField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(labelText: "ยืนยันรหัสผ่าน"),
            obscureText: true,
          ),
          TextField(
            controller: otpController,
            decoration: const InputDecoration(labelText: "รหัส OTP"),
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
            Navigator.popUntil(context, ModalRoute.withName('/login')); // กลับไปหน้า Login
          },
          child: const Text("บันทึก"),
        ),
      ],
    );
  }
}
