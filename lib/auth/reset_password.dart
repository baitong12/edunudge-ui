// นำเข้าไลบรารีที่จำเป็นสำหรับการพัฒนาแอปพลิเคชัน Flutter
import 'dart:convert'; // สำหรับการเข้ารหัสและถอดรหัสข้อมูล JSON
import 'package:flutter/material.dart'; // แพ็คเกจหลักสำหรับการออกแบบตาม Material Design ของ Flutter
import 'package:http/http.dart' as http; // แพ็คเกจสำหรับการร้องขอ HTTP (การเชื่อมต่อ API)
import 'package:flutter_dotenv/flutter_dotenv.dart'; // แพ็คเกจสำหรับโหลดตัวแปรสภาพแวดล้อมจากไฟล์ .env

// กำหนดวิดเจ็ต ResetPassword เป็นวิดเจ็ตที่มีสถานะ (StatefulWidget) เนื่องจากมีการเปลี่ยนแปลงสถานะ
class ResetPassword extends StatefulWidget {
  // คอนสตรักเตอร์สำหรับวิดเจ็ตนี้ (super.key ใช้สำหรับระบุวิดเจ็ต)
  const ResetPassword({super.key});

  // แทนที่เมธอด createState เพื่อเชื่อมโยงวิดเจ็ตเข้ากับคลาส State ของมัน
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

// กำหนดคลาส State สำหรับวิดเจ็ต ResetPassword ซึ่งเก็บสถานะและตรรกะของหน้าจอ
class _ResetPasswordState extends State<ResetPassword> {
  // URL พื้นฐานสำหรับ API ซึ่งดึงมาจาก .env หรือใช้ค่าเริ่มต้นหากไม่พบ
  final String baseUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
  
  // ตัวควบคุมสำหรับการจัดการข้อมูลที่ป้อนในช่องรหัสผ่านใหม่
  final TextEditingController passwordController = TextEditingController();
  
  // ตัวควบคุมสำหรับการจัดการข้อมูลที่ป้อนในช่องยืนยันรหัสผ่าน
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // ตัวควบคุมสำหรับการจัดการข้อมูลที่ป้อนในช่องรหัส OTP (One-Time Password)
  final TextEditingController otpController = TextEditingController();

  // ตัวแปรสถานะ Boolean เพื่อติดตามว่ากำลังมีการโหลดคำขอ API อยู่หรือไม่
  bool _isLoading = false;

  // ฟังก์ชันแบบอะซิงโครนัสเพื่อจัดการขั้นตอนการบันทึกรหัสผ่านใหม่และการรีเซ็ต
  Future<void> _saveNewPassword() async {
    // ดึงและล้างช่องว่างรอบ ๆ ข้อความจากตัวควบคุมทั้งหมด
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final otp = otpController.text.trim();

    // --- การตรวจสอบความถูกต้องของข้อมูล (Input Validation) ---

    // ตรวจสอบว่ามีช่องที่จำเป็นช่องใดว่างเปล่าหรือไม่
    if (password.isEmpty || confirmPassword.isEmpty || otp.isEmpty) {
      _showMessage("กรุณากรอกข้อมูลให้ครบถ้วน"); // แสดงข้อความแจ้งเตือนข้อผิดพลาด
      return; // หยุดการทำงานหากการตรวจสอบความถูกต้องล้มเหลว
    }

    // ตรวจสอบว่ารหัสผ่านใหม่มีความยาวอย่างน้อย 8 ตัวอักษร
    if (password.length < 8) {
      _showMessage("รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร"); // แสดงข้อความแจ้งเตือนความยาว
      return; // หยุดการทำงาน
    }

    // ตรวจสอบว่ารหัสผ่านใหม่และการยืนยันรหัสผ่านตรงกันหรือไม่
    if (password != confirmPassword) {
      _showMessage("รหัสผ่านและการยืนยันรหัสผ่านไม่ตรงกัน"); // แสดงข้อความแจ้งเตือนว่าไม่ตรงกัน
      return; // หยุดการทำงาน
    }

    // --- การเตรียมเรียกใช้ API ---

    // อัปเดตสถานะเพื่อแสดงตัวบ่งชี้การโหลด (Loading Indicator)
    setState(() => _isLoading = true);

    try {
      // ดำเนินการร้องขอ HTTP POST ไปยัง endpoint reset-password
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"), // สร้าง URI แบบเต็ม
        headers: {"Content-Type": "application/json"}, // กำหนดส่วนหัว Content-Type
        body: jsonEncode({ // เข้ารหัสเนื้อหาคำขอเป็น JSON
          "otp": otp, // รวม OTP จากตัวควบคุม
          "password": password, // รวมรหัสผ่านใหม่
          "password_confirmation": confirmPassword, // รวมการยืนยันรหัสผ่าน
        }),
      );

      // ถอดรหัสเนื้อหาการตอบกลับ JSON
      final data = jsonDecode(response.body);

      // --- การจัดการกับการตอบกลับ ---

      // ตรวจสอบรหัสสถานะที่สำเร็จ (HTTP 200 OK)
      if (response.statusCode == 200) {
        // แสดงข้อความความสำเร็จ โดยใช้ข้อความจาก API หรือข้อความเริ่มต้น
        _showMessage(data["message"] ?? "เปลี่ยนรหัสผ่านสำเร็จ", success: true);
        // นำทางไปยังหน้าจอเข้าสู่ระบบและล้างเส้นทางอื่น ๆ ทั้งหมดออกจากกอง (stack)
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        // แสดงข้อความข้อผิดพลาด โดยใช้ข้อความจาก API หรือข้อความเริ่มต้น
        _showMessage(data["message"] ?? "เกิดข้อผิดพลาด");
      }
    } catch (e) {
      // จัดการข้อยกเว้นใด ๆ (เช่น ข้อผิดพลาดของเครือข่าย หรือการเชื่อมต่อล้มเหลว)
      _showMessage("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้");
    } finally {
      // ตรวจสอบให้แน่ใจว่าสถานะการโหลดถูกปิดลงเสมอ ไม่ว่าจะสำเร็จหรือล้มเหลว
      setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันสำหรับจัดการการยกเลิกกระบวนการรีเซ็ตรหัสผ่าน
  void _cancel() {
    // นำทางกลับไปยังหน้าจอเข้าสู่ระบบ โดยล้างกองการนำทาง
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false, // เงื่อนไขที่ทำให้ลบทุกเส้นทางก่อนหน้า
    );
  }

  // ฟังก์ชันเพื่อแสดงข้อความชั่วคราว (SnackBar) ให้ผู้ใช้เห็น
  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar( // เข้าถึง ScaffoldMessenger ที่ใกล้ที่สุด
      SnackBar(
        content: Text(msg), // เนื้อหาข้อความ
        // กำหนดสีพื้นหลังตามว่าเป็นข้อความสำเร็จ (เขียว) หรือข้อผิดพลาด (แดง)
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // แทนที่เมธอด dispose เพื่อล้างข้อมูลทรัพยากรเมื่อวิดเจ็ตถูกทำลาย
  @override
  void dispose() {
    // กำจัด TextEditingControllers ทั้งหมดเพื่อป้องกันหน่วยความจำรั่ว (Memory Leaks)
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose(); // เรียกเมธอด dispose ของคลาสแม่
  }

  // เมธอด build หลักของส่วนติดต่อผู้ใช้ (UI)
  @override
  Widget build(BuildContext context) {
    // ส่งกลับ Scaffold ซึ่งเป็นโครงสร้างพื้นฐานของหน้าจอ
    return Scaffold(
        // ใช้ Container สำหรับพื้นหลังและไล่ระดับสีหลัก
        body: Container(
        decoration: const BoxDecoration(
          // กำหนดไล่ระดับสีพื้นหลังเพื่อให้ดูสวยงาม
          gradient: LinearGradient(
            begin: Alignment.topCenter, // เริ่มไล่ระดับสีจากด้านบน
            end: Alignment.bottomCenter, // สิ้นสุดไล่ระดับสีที่ด้านล่าง
            // กำหนดสีสองสีสำหรับเอฟเฟกต์ไล่ระดับ
            colors: [Color(0xFF00B894), Color(0xFF91C8E4)],
          ),
        ),
        // จัดเนื้อหาให้อยู่ตรงกลางหน้าจอ
        child: Center(
          // ใช้ SingleChildScrollView เพื่อป้องกันปัญหาการล้น (Overflow) บนหน้าจอขนาดเล็กหรือเมื่อแป้นพิมพ์เปิดอยู่
          child: SingleChildScrollView(
            // คอนเทนเนอร์ด้านในสำหรับพื้นที่การ์ด/แบบฟอร์มหลัก
            child: Container(
              margin: const EdgeInsets.all(16), // เพิ่มระยะขอบรอบการ์ด
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), // ระยะห่างภายใน (Padding) การ์ด
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // ใช้มุมโค้งมน
                // กำหนดไล่ระดับสีอ่อนสำหรับการ์ดพื้นหลัง
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5E9), // สีเริ่มต้นโทนเขียวอ่อน
                    Color(0xFFE1F5FE), // สีสิ้นสุดโทนฟ้าอ่อน
                  ],
                ),
                // เพิ่มเงาเพื่อความลึกและการแยกภาพ
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38, // สีของเงา
                    offset: Offset(0, 8), // การเลื่อนของเงา (x, y)
                    blurRadius: 15, // ความเบลอของเงา
                    spreadRadius: 2, // ระยะการกระจายของเงา
                  ),
                ],
              ),
              // Column เพื่อจัดเรียงองค์ประกอบของแบบฟอร์มในแนวตั้ง
              child: Column(
                mainAxisSize: MainAxisSize.min, // ทำให้คอลัมน์ใช้พื้นที่แนวตั้งน้อยที่สุด
                children: [
                  // ข้อความส่วนหัวสำหรับหน้าจอ
                  const Text(
                    'ตั้งค่ารหัสผ่าน', // ข้อความส่วนหัว
                    style: TextStyle(
                      fontSize: 28, // ขนาดตัวอักษรใหญ่สำหรับส่วนหัว
                      fontWeight: FontWeight.bold, // ตัวหนา
                      color: Color(0xFF221B64), // สีครามเข้ม
                      // เพิ่มเงาข้อความเล็กน้อย
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 2),
                          blurRadius: 3,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // พื้นที่แนวตั้งหลังส่วนหัว
                  
                  // ป้ายกำกับสำหรับช่องป้อนรหัสผ่านใหม่
                  _buildLabel("รหัสผ่านใหม่"),
                  // วิดเจ็ตอินพุตที่กำหนดเองสำหรับรหัสผ่านใหม่
                  _buildInput(passwordController, obscure: true, hintText: 'รหัสผ่านใหม่'), 
                  
                  const SizedBox(height: 16), // พื้นที่แนวตั้งระหว่างช่อง
                  
                  // ป้ายกำกับสำหรับช่องป้อนยืนยันรหัสผ่านใหม่
                  _buildLabel("ยืนยันรหัสผ่านใหม่"),
                  // วิดเจ็ตอินพุตที่กำหนดเองสำหรับยืนยันรหัสผ่าน
                  _buildInput(confirmPasswordController, obscure: true, hintText: 'ยืนยันรหัสผ่านใหม่'), 
                  
                  const SizedBox(height: 16), // พื้นที่แนวตั้งระหว่างช่อง
                  
                  // ป้ายกำกับสำหรับช่องป้อนรหัส OTP
                  _buildLabel("รหัส OTP"),
                  // วิดเจ็ตอินพุตที่กำหนดเองสำหรับ OTP
                  _buildInput(otpController, hintText: 'รหัส OTP'), 
                  
                  const SizedBox(height: 24), // พื้นที่แนวตั้งก่อนปุ่ม
                  
                  // Row เพื่อจัดเก็บปุ่มการทำงานสองปุ่มเคียงข้างกัน
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // จัดระยะห่างระหว่างปุ่ม
                    children: [
                      // Expanded สำหรับปุ่มยกเลิกเพื่อให้ใช้พื้นที่เท่ากัน
                      Expanded(
                        child: _buildButton("ยกเลิก", Colors.red, _cancel), // สร้างปุ่มยกเลิก
                      ),
                      const SizedBox(width: 16), // พื้นที่แนวนอนระหว่างปุ่ม
                      // Expanded สำหรับปุ่มยืนยัน/ตัวบ่งชี้การโหลด
                      Expanded(
                        child: _isLoading
                            // หากกำลังโหลด ให้แสดงตัวบ่งชี้ความคืบหน้าแบบวงกลม
                            ? const Center(child: CircularProgressIndicator()) 
                            // มิฉะนั้น ให้แสดงปุ่มยืนยัน
                            : _buildButton("ยืนยัน", const Color(0xFF3F8FAF), _saveNewPassword),
                      ),
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

  // วิดเจ็ตตัวช่วยในการสร้างป้ายกำกับที่เป็นมาตรฐานสำหรับช่องป้อนข้อมูล
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft, // จัดข้อความไปทางซ้าย
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF221B64), // สีเข้มเพื่อความคมชัด
          fontWeight: FontWeight.bold, // ตัวหนา
        ),
      ),
    );
  }

  // วิดเจ็ตตัวช่วยในการสร้างปุ่มที่มีสไตล์และเป็นมาตรฐาน
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      height: 50, // ความสูงคงที่ของปุ่ม
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25), // มุมโค้งมนสำหรับคอนเทนเนอร์
        // เพิ่มเงากล่องให้กับคอนเทนเนอร์เพื่อเอฟเฟกต์ปุ่มยกขึ้น
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      // ElevatedButton สำหรับการโต้ตอบการแตะจริง
      child: ElevatedButton(
        onPressed: onPressed, // ฟังก์ชันที่จะดำเนินการเมื่อถูกกด
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // ใช้สีที่ให้มาเป็นพื้นหลัง
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // ให้ตรงกับมุมโค้งมนของคอนเทนเนอร์
          ),
          padding: EdgeInsets.zero, // ลบระยะห่างเริ่มต้น
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white, // สีข้อความขาว
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตตัวช่วยในการสร้างช่องป้อนข้อความที่มีสไตล์และเป็นมาตรฐาน
  Widget _buildInput(TextEditingController controller,
      {bool obscure = false, String? hintText}) {
    return TextField(
      controller: controller, // เชื่อมโยงตัวควบคุมกับช่องป้อนข้อความ
      obscureText: obscure, // ซ่อนข้อความหากเป็นช่องรหัสผ่าน
      style: const TextStyle(color: Colors.black), // สีข้อความภายในช่อง
      decoration: InputDecoration(
        hintText: hintText, // ข้อความตัวยึด (Placeholder)
        hintStyle: const TextStyle(color: Colors.grey), // สไตล์สำหรับข้อความตัวยึด
        filled: true, // เปิดใช้งานการเติมสีพื้นหลัง
        fillColor: Colors.white, // พื้นหลังสีขาวสำหรับช่องป้อนข้อมูล
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // ระยะห่างภายในช่อง
        // กำหนดรูปแบบเส้นขอบเริ่มต้น
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25), // มุมโค้งมนสำหรับขอบเขตอินพุต
          borderSide: BorderSide.none, // ไม่มีเส้นขอบที่มองเห็นได้ในตอนแรก
        ),
        // กำหนดรูปแบบเส้นขอบเมื่อช่องป้อนข้อมูลถูกเปิดใช้งานแต่ไม่ได้โฟกัส
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        // กำหนดรูปแบบเส้นขอบเมื่อช่องป้อนข้อมูลถูกโฟกัส (ใช้งานอยู่)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF221B64), width: 2), // เน้นด้วยเส้นขอบสีเข้ม
        ),
      ),
    );
  }
}