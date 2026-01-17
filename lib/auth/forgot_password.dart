// นำเข้าไลบรารี dart:convert สำหรับแปลง JSON <-> Map และ encode/decode ข้อมูล
import 'dart:convert'; 

// นำเข้า Flutter material library สำหรับสร้าง UI และใช้ widget ต่าง ๆ
import 'package:flutter/material.dart'; 

// นำเข้าแพ็กเกจ HTTP สำหรับส่ง request ไปยัง server
import 'package:http/http.dart' as http; 

// นำเข้า dotenv เพื่อใช้ environment variables เช่น URL API
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

// สร้าง StatefulWidget สำหรับหน้าลืมรหัสผ่าน
class ForgotPassword extends StatefulWidget { 
  // Constructor ของ widget นี้ ใช้ super.key เพื่อเชื่อมต่อ key ของ widget
  const ForgotPassword({super.key}); 

  // สร้าง state ของ widget นี้
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState(); 
} 

// State class ของ ForgotPassword เก็บ logic และสถานะต่าง ๆ
class _ForgotPasswordState extends State<ForgotPassword> { 
  // baseUrl ของ API ดึงจาก .env ถ้าไม่เจอให้ใช้ default URL
  static final String baseUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api"; 

  // Controller สำหรับ TextField ใช้ดึงค่าอีเมลที่ผู้ใช้กรอก
  final TextEditingController _emailController = TextEditingController(); 

  // ตัวแปร boolean สำหรับตรวจสอบสถานะ loading ของปุ่ม
  bool _isLoading = false; 

  // ฟังก์ชันส่ง OTP ไปยังอีเมล
  Future<void> _sendOtp() async { 
    // ดึงค่าอีเมลและตัดช่องว่างด้านหน้า-หลัง
    final email = _emailController.text.trim(); 

    // ตรวจสอบว่าอีเมลว่างหรือไม่
    if (email.isEmpty) { 
      // แสดง SnackBar แจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text("กรุณากรอกอีเมล")), 
      ); 
      return; // ออกจากฟังก์ชัน
    } 

    // สร้าง regex ตรวจสอบรูปแบบอีเมล
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); 
    // ตรวจสอบรูปแบบอีเมล
    if (!emailRegex.hasMatch(email)) { 
      // ถ้าไม่ถูกต้อง แสดง SnackBar แจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text("กรุณากรอกรูปแบบอีเมลที่ถูกต้อง")), 
      ); 
      return; // ออกจากฟังก์ชัน
    } 

    // เปลี่ยนสถานะเป็น loading เพื่อ disable ปุ่มและแสดง indicator
    setState(() => _isLoading = true); 

    try { 
      // ส่ง HTTP POST request ไปยัง API
      final response = await http.post( 
        Uri.parse("$baseUrl/forgot-password"), // แปลง string เป็น Uri
        headers: { 
          "Content-Type": "application/json", // ประเภทข้อมูลที่ส่ง
          "Accept": "application/json", // ประเภทข้อมูลที่รับ
        }, 
        body: jsonEncode({"email": email}), // แปลงข้อมูลเป็น JSON
      ); 

      // หลังส่ง request เสร็จ ปิด loading
      setState(() => _isLoading = false); 

      // ตรวจสอบว่า response เป็น JSON หรือไม่
      if (response.headers['content-type'] != null && 
          response.headers['content-type']!.contains('application/json')) { 
        // แปลง JSON response เป็น Map
        final data = jsonDecode(response.body); 

        // ตรวจสอบ status code 200 = success
        if (response.statusCode == 200) { 
          // แสดงข้อความสำเร็จจาก server
          ScaffoldMessenger.of(context).showSnackBar( 
            SnackBar(content: Text(data['message'] ?? 'ส่ง OTP สำเร็จ')), 
          ); 

          // นำผู้ใช้ไปหน้าตั้งรหัสผ่านใหม่ พร้อมส่ง email
          Navigator.pushNamed( 
            context, 
            '/reset_password', 
            arguments: {"email": email}, 
          ); 
        } else { 
          // ถ้า status code != 200 แสดงข้อความ error
          ScaffoldMessenger.of(context).showSnackBar( 
            SnackBar(content: Text(data['message'] ?? 'เกิดข้อผิดพลาดในการส่ง OTP')), 
          ); 
        } 
      } else { 
        // กรณี response ไม่ใช่ JSON
        print("Non-JSON response from server: ${response.body}"); 
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text("เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: ${response.statusCode}")), 
        ); 
      } 
    } catch (e) { 
      // ถ้าเกิด exception เช่น server down, no internet
      setState(() => _isLoading = false); // ปิด loading
      ScaffoldMessenger.of(context).showSnackBar( 
        SnackBar(content: Text("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e")), 
      ); 
    } 
  } 

  // ฟังก์ชันยกเลิก → กลับหน้าก่อนหน้า
  void _cancel() { 
    Navigator.pop(context); 
  } 

  // dispose controller เมื่อ widget ถูกทำลายเพื่อป้องกัน memory leak
  @override
  void dispose() { 
    _emailController.dispose(); 
    super.dispose(); 
  } 

  // ฟังก์ชัน build UI ของหน้าจอ
  @override
  Widget build(BuildContext context) { 
    return Scaffold( 
      // ใช้ Container เพื่อทำ background gradient
      body: Container( 
        decoration: const BoxDecoration( 
          gradient: LinearGradient( 
            begin: Alignment.topCenter, // เริ่ม gradient จากบน
            end: Alignment.bottomCenter, // จบ gradient ที่ล่าง
            colors: [Color(0xFF00B894),  Color(0xFF91C8E4)], // สี gradient
          ), 
        ), 
        child: Center( 
          child: SingleChildScrollView( 
            // ScrollView เผื่อ keyboard เปิดไม่ให้ overflow
            child: Container( 
              margin: const EdgeInsets.all(16), // ขอบรอบ container
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), // ขอบใน
              decoration: BoxDecoration( 
                borderRadius: BorderRadius.circular(20), // มุมโค้ง container
                gradient: const LinearGradient( 
                  begin: Alignment.topCenter, 
                  end: Alignment.bottomCenter, 
                  colors: [Color(0xFFE8F5E9), Color(0xFFE1F5FE)], // สี gradient ข้างใน
                ), 
                boxShadow: const [ 
                  BoxShadow( 
                    color: Colors.black38, 
                    offset: Offset(0, 8), // เงาเลื่อนลง
                    blurRadius: 15, 
                    spreadRadius: 2, 
                  ), 
                ], 
              ), 
              child: Column( 
                mainAxisSize: MainAxisSize.min, // column พอดีกับเนื้อหา
                children: [ 
                  const Icon(Icons.lock_outline, color: Color(0xFF221B64), size: 48), // ไอคอนล็อก
                  const SizedBox(height: 16), // เว้นระยะ
                  const Text( 
                    'ลืมรหัสผ่าน', 
                    style: TextStyle( 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF221B64), 
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 3)], // เงาข้อความ
                    ), 
                  ), 
                  const SizedBox(height: 24), 
                  const Align( 
                    alignment: Alignment.centerLeft, // ชิดซ้าย
                    child: Text('อีเมล', style: TextStyle(color: Color(0xFF221B64), fontWeight: FontWeight.bold)), 
                  ), 
                  const SizedBox(height: 8), 
                  TextField( 
                    controller: _emailController, // เชื่อม controller
                    keyboardType: TextInputType.emailAddress, // keyboard แบบอีเมล
                    enabled: !_isLoading, // ถ้ากำลังโหลด ปิดแก้ไข
                    decoration: InputDecoration( 
                      hintText: 'กรุณากรอกอีเมล', 
                      hintStyle: const TextStyle(color: Colors.grey), // สี placeholder
                      filled: true, 
                      fillColor: Colors.white, // สี background ของ field
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
                      border: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(25), // มุมโค้ง
                        borderSide: BorderSide.none, // ไม่มีเส้นขอบ
                      ), 
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]), // icon ก่อน text
                    ), 
                  ), 
                  const SizedBox(height: 24), 
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    children: [ 
                      Expanded(child: _buildButton('ยกเลิก', Colors.red, _cancel)), // ปุ่มยกเลิก
                      const SizedBox(width: 16), 
                      Expanded(child: _buildButton('ยืนยัน', const Color(0xFF3F8FAF), _sendOtp, loading: _isLoading)), // ปุ่มยืนยัน
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

  // ฟังก์ชันสร้างปุ่ม custom
  Widget _buildButton(String text, Color color, VoidCallback onPressed, {bool loading = false}) { 
    return Container( 
      height: 50, // ความสูงปุ่ม
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.circular(25), // มุมโค้งปุ่ม
        boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6)], // เงา
      ), 
      child: ElevatedButton( 
        onPressed: loading ? null : onPressed, // ถ้า loading ปุ่ม disable
        style: ElevatedButton.styleFrom( 
          backgroundColor: color, // สีปุ่ม
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // มุมปุ่ม
          padding: EdgeInsets.zero, // ไม่มี padding เพิ่ม
        ), 
        child: loading 
            ? const SizedBox( 
                height: 24, 
                width: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3), // แสดงวงกลม loading
              ) 
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)), // ข้อความปุ่ม
      ), 
    ); 
  } 
} 
