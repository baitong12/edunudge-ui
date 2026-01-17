// นำเข้า Flutter material library สำหรับสร้าง UI และใช้ widget ต่าง ๆ
import 'package:flutter/material.dart'; 
// นำเข้า SharedPreferences สำหรับเก็บค่าบนเครื่อง เช่น token, role_id
import 'package:shared_preferences/shared_preferences.dart'; 
// นำเข้า ApiService สำหรับเรียก API login
import 'package:edunudge/services/api_service.dart'; 

// สร้าง StatefulWidget สำหรับหน้าล็อกอิน
class Login extends StatefulWidget { 
  // Constructor ของ widget นี้ ใช้ super.key เพื่อเชื่อม key ของ widget
  const Login({super.key}); 

  // สร้าง state ของ widget
  @override
  State<Login> createState() => _LoginState(); 
}

// State class ของ Login เก็บ logic และสถานะต่าง ๆ
class _LoginState extends State<Login> { 
  // Controller สำหรับ TextField กรอกอีเมล
  final _emailController = TextEditingController(); 

  // Controller สำหรับ TextField กรอกรหัสผ่าน
  final _passwordController = TextEditingController(); 

  // ตัวแปร boolean สำหรับตรวจสอบสถานะ loading ของปุ่ม
  bool _isLoading = false; 

  // เก็บข้อความ error ถ้ามี
  String? _errorMessage; 


  // เรียกครั้งแรกตอน widget สร้างเสร็จ
  @override
  void initState() { 
    super.initState(); 
    _checkToken(); // ตรวจสอบว่าเคยล็อกอินแล้วหรือไม่
  } 


  // ฟังก์ชันตรวจสอบ token และ role_id บนเครื่อง
  Future<void> _checkToken() async { 
    final prefs = await SharedPreferences.getInstance(); // ดึง instance ของ SharedPreferences
    final token = prefs.getString('api_token'); // ดึง token
    final roleId = prefs.getInt('role_id') ?? -1; // ดึง role_id ถ้าไม่มีใช้ -1

    // ถ้ามี token และ roleId ถูกต้อง
    if (token != null && roleId != -1) { 
      // รอให้ frame ปัจจุบันเสร็จเพื่อทำ navigation
      WidgetsBinding.instance.addPostFrameCallback((_) { 
        if (roleId == 1) { 
          Navigator.pushReplacementNamed(context, '/home_student'); // นักเรียน
        } else if (roleId == 2) { 
          Navigator.pushReplacementNamed(context, '/home_teacher'); // ครู
        } 
      }); 
    } 
  } 


  // ฟังก์ชัน login
  Future<void> _login() async { 
    // เริ่มโหลดและล้าง error message
    setState(() { 
      _isLoading = true; 
      _errorMessage = null; 
    }); 

    // ดึงค่าจาก TextField
    final email = _emailController.text.trim(); 
    final password = _passwordController.text.trim(); 

    // ตรวจสอบว่ากรอกครบหรือไม่
    if (email.isEmpty || password.isEmpty) { 
      setState(() { 
        _errorMessage = 'กรุณากรอกอีเมลและรหัสผ่าน'; // แสดงข้อความ error
        _isLoading = false; 
      }); 
      return; // ออกจากฟังก์ชัน
    } 

    try { 
      final data = await ApiService.login(email, password); // เรียก API login
      final token = data['token']; // ดึง token
      final user = data['user']; // ดึงข้อมูล user
      final roleId = int.tryParse(user['role_id'].toString()) ?? -1; // แปลง role_id เป็น int

      final prefs = await SharedPreferences.getInstance(); // ดึง instance SharedPreferences
      await prefs.setString('api_token', token ?? ''); // เก็บ token
      await prefs.setInt('role_id', roleId); // เก็บ role_id
      await prefs.setInt('user_id', user['id'] ?? -1); // เก็บ user id
      await prefs.setString('user_name', user['name'] ?? ''); // เก็บชื่อ
      await prefs.setString('user_lastname', user['lastname'] ?? ''); // เก็บนามสกุล
      await prefs.setString('user_email', user['email'] ?? ''); // เก็บอีเมล
      await prefs.setString('user_phone', user['phone'] ?? ''); // เก็บเบอร์โทร
      await prefs.setInt('department_id', user['department_id'] ?? -1); // เก็บ department id

      // ตรวจสอบ role_id และนำทางไปหน้าหลัก
      if (roleId == 1) { 
        Navigator.pushReplacementNamed(context, '/home_student'); // นักเรียน
      } else if (roleId == 2) { 
        Navigator.pushReplacementNamed(context, '/home_teacher'); // ครู
      } else { 
        setState(() { 
          _errorMessage = 'ไม่สามารถระบุสถานะผู้ใช้ได้ (Role ID: $roleId)'; 
        }); 
      } 
    } catch (e) { // เก็บข้อผิดพลาดที่เกิดขึ้น
      setState(() { 
        _errorMessage = 'เกิดข้อผิดพลาด: $e'; 
      }); 
    } finally { // จะถูกเรียกใช้เสมอ ไม่ว่าจะเกิดข้อผิดพลาดหรือไม่
      setState(() { 
        _isLoading = false; // ปิด loading
      }); 
    } 
  } 


  // Dispose controllers ป้องกัน memory leak
  @override
  void dispose() { 
    _emailController.dispose(); 
    _passwordController.dispose(); 
    super.dispose(); 
  } 

  // Build UIเ
  @override
  Widget build(BuildContext context) { 
    return Scaffold( 
      body: Container( 
        decoration: const BoxDecoration( 
          gradient: LinearGradient( 
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter, 
            colors: [Color(0xFF00B894),  Color(0xFF91C8E4)], 
          ), 
        ), 
        child: Center( 
          child: Padding( 
            padding: const EdgeInsets.all(30.0), //ระยะห่าง
            child: SingleChildScrollView( 
              child: Column( 
                mainAxisAlignment: MainAxisAlignment.center,  
                children: [ 
                  Image.asset('images/logo_notname.png', height: 200), // โลโก้
                  const SizedBox(height: 30), 
                  TextField( 
                    controller: _emailController, 
                    decoration: InputDecoration( 
                      hintText: 'อีเมล', 
                      filled: true, 
                      fillColor: Colors.white, 
                      border: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(25), 
                        borderSide: BorderSide.none, 
                      ), 
                    ), 
                  ), 
                  const SizedBox(height: 10), 
                  TextField( 
                    controller: _passwordController, 
                    obscureText: true, // ซ่อนรหัสผ่าน
                    decoration: InputDecoration( 
                      hintText: 'รหัสผ่าน', 
                      filled: true, 
                      fillColor: Colors.white, 
                      border: OutlineInputBorder( 
                        borderRadius: BorderRadius.circular(25), 
                        borderSide: BorderSide.none, 
                      ), 
                    ), 
                  ), 
                  const SizedBox(height: 20), 
                  if (_errorMessage != null) // ถ้ามี error แสดงข้อความ
                    Padding( 
                      padding: const EdgeInsets.only(bottom: 15), 
                      child: Text( 
                        _errorMessage!, 
                        style: const TextStyle( 
                          color: Colors.redAccent, 
                          fontWeight: FontWeight.bold, 
                        ), 
                        textAlign: TextAlign.center, 
                      ), 
                    ), 
                  ElevatedButton( 
                    onPressed: _isLoading ? null : _login, // ถ้า loading ปุ่ม disable
                    style: ElevatedButton.styleFrom( 
                      backgroundColor: const Color(0xFF3F8FAF), 
                      foregroundColor: Colors.white, 
                      minimumSize: const Size(double.infinity, 50), 
                      shape: RoundedRectangleBorder( 
                        borderRadius: BorderRadius.circular(25), 
                      ), 
                    ), 
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) //ถ้าเป็น true แสดง loading
                        : const Text( 
                            'เข้าสู่ระบบ', 
                            style: TextStyle( 
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                            ), 
                          ), 
                  ), 
                  const SizedBox(height: 20), 
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [ 
                      TextButton( 
                        onPressed: () { 
                          Navigator.pushNamed(context, '/forgot_password'); // ไปหน้าลืมรหัสผ่าน
                        }, 
                        child: const Text( 
                          'ลืมรหัสผ่าน ?', 
                          style: TextStyle(color: Colors.white), 
                        ), 
                      ), 
                      TextButton( 
                        onPressed: () { 
                          Navigator.pushReplacementNamed(context, '/register01'); // ไปหน้าลงทะเบียน
                        }, 
                        child: const Text( 
                          'ลงทะเบียน', 
                          style: TextStyle( 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                          ), 
                        ), 
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
} 
