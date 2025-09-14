import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPassword extends StatefulWidget {
  
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  static final String baseUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
  // Controller สำหรับ TextField ของอีเมล
  final TextEditingController _emailController = TextEditingController();
  // สถานะเพื่อแสดง CircularProgressIndicator เมื่อกำลังโหลด
  bool _isLoading = false;

  // ฟังก์ชันสำหรับส่งรหัส OTP ไปยังเซิร์ฟเวอร์
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    // ตรวจสอบว่าช่องอีเมลว่างเปล่าหรือไม่
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกอีเมล")),
      );
      return;
    }

    // ตรวจสอบรูปแบบอีเมลเบื้องต้น (Client-side validation)
    // ใช้ Regular Expression (regex) เพื่อตรวจสอบรูปแบบอีเมลมาตรฐาน
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกรูปแบบอีเมลที่ถูกต้อง")),
      );
      return;
    }

    // ตั้งค่าสถานะเป็นกำลังโหลดเพื่อแสดง Indicator
    setState(() => _isLoading = true);

    try {
      // ทำการเรียก API POST ไปยัง Laravel backend
      final response = await http.post(
        // URL ของ Laravel API สำหรับการลืมรหัสผ่าน (ควรเปลี่ยนเป็น Production URL เมื่อ Deploy)
        Uri.parse("$baseUrl/forgot-password"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        // ส่งข้อมูลอีเมลในรูปแบบ JSON
        body: jsonEncode({"email": email}),
      );
      
      // เมื่อได้รับ response แล้ว ให้ตั้งค่าสถานะเป็นไม่กำลังโหลด
      setState(() => _isLoading = false);

      // ตรวจสอบว่า Content-Type ของ response เป็น JSON หรือไม่
      if (response.headers['content-type'] != null &&
          response.headers['content-type']!.contains('application/json')) {
        final data = jsonDecode(response.body); // แปลง JSON string เป็น Map

        if (response.statusCode == 200) {
          // หากสำเร็จ (HTTP 200 OK) แสดงข้อความจากเซิร์ฟเวอร์
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'ส่ง OTP สำเร็จ')),
          );

          // นำทางไปยังหน้า ResetPassword พร้อมส่งอีเมลไปด้วย
          // หน้านี้ (ResetPassword) จะเป็นหน้าที่ให้กรอก OTP
          Navigator.pushNamed(
            context,
            '/reset_password',
            arguments: {"email": email},
          );
        } else {
          // หากมีข้อผิดพลาด (เช่น validation error จาก server) แสดงข้อความผิดพลาด
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'เกิดข้อผิดพลาดในการส่ง OTP')),
          );
        }
      } else {
        // กรณีที่เซิร์ฟเวอร์ไม่ได้ส่ง response เป็น JSON
        // เช่น อาจจะเป็น HTML error page หรือข้อความธรรมดาที่ไม่ใช่ JSON
        print("Non-JSON response from server: ${response.body}"); // สำหรับ Debug
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // จัดการข้อผิดพลาดที่เกิดจากการเชื่อมต่อ (เช่น ไม่มีอินเทอร์เน็ต, เซิร์ฟเวอร์ไม่ทำงาน)
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e")),
      );
    }
  }

  // ฟังก์ชันสำหรับยกเลิกและย้อนกลับไปยังหน้าก่อนหน้า
  void _cancel() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // ปิด controller เมื่อ widget ถูกทำลายเพื่อป้องกัน memory leaks
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B894),  Color(0xFF91C8E4),],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5E9), Color(0xFFE1F5FE)], // สีอ่อนด้านใน
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 8),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF221B64), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'ลืมรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF221B64),
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 3)],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('อีเมล', style: TextStyle(color: Color(0xFF221B64), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading, // ปิดการใช้งาน TextField เมื่อกำลังโหลด
                    decoration: InputDecoration(
                      hintText: 'กรุณากรอกอีเมล',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      // เพิ่ม icon สำหรับอีเมล
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildButton('ยกเลิก', Colors.red, _cancel)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildButton('ยืนยัน', const Color(0xFF221B64), _sendOtp, loading: _isLoading)), // เปลี่ยนสีปุ่มยืนยัน
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างปุ่มที่มีสไตล์สวยงาม
  Widget _buildButton(String text, Color color, VoidCallback onPressed, {bool loading = false}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6)],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed, // ปิดการใช้งานปุ่มเมื่อกำลังโหลด
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: EdgeInsets.zero,
        ),
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
