import 'package:flutter/material.dart'; // พื้นฐานสำหรับ UI ของ Flutter
import 'package:provider/provider.dart'; // ใช้สำหรับ state management (ProfileProvider)
import 'package:shared_preferences/shared_preferences.dart'; // ใช้เก็บข้อมูลบนเครื่อง เช่น token, ชื่อผู้ใช้
import 'package:http/http.dart' as http; // ใช้สำหรับเรียก API
import 'dart:convert'; // ใช้ jsonEncode / jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart'; // อ่านค่า environment variables เช่น API_URL
import '../providers/profile_provider.dart'; // นำ ProfileProvider มาใช้

class CustomAppBar extends StatefulWidget {
  // URL ของ API อ่านจาก .env ถ้าไม่มีใช้ default
  static final String baseUrl =
      dotenv.env['API_URL'] ?? "http://52.63.155.211/api";

  final VoidCallback onProfileTap; // callback กดโปรไฟล์
  final VoidCallback? onLogoutTap; // callback กด logout (optional)

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _initials = '--'; // ตัวอักษรย่อเริ่มต้น

  @override
  void initState() {
    super.initState();
    _loadInitials(); // โหลดตัวอักษรย่อจาก SharedPreferences ตอนเริ่ม
  }

  // โหลดตัวอักษรย่อจาก SharedPreferences
  Future<void> _loadInitials() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? ''; // ดึงชื่อ
    final lastname = prefs.getString('user_lastname') ?? ''; // ดึงนามสกุล
    setState(() {
      // สร้าง initials จากตัวแรกของชื่อและนามสกุล
      _initials =
          ((name.isNotEmpty ? name[0] : '-') + (lastname.isNotEmpty ? lastname[0] : '-'))
              .toUpperCase();
    });
  }

  // ฟังก์ชัน logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance(); // ดึง SharedPreferences
    final token = prefs.getString('api_token'); // ดึง token

    if (token != null) {
      try {
        // ส่ง POST request ไป logout API
        final response = await http.post(
          Uri.parse("${CustomAppBar.baseUrl}/logout"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        final data = jsonDecode(response.body);
        debugPrint("Logout Response: $data"); // แสดงผลลัพธ์ logout
      } catch (e) {
        debugPrint("Logout Error: $e"); // กรณีเกิด error
      }
    }
    await prefs.clear(); // ทำให้เครื่อง ไม่มีข้อมูลเก่าของผู้ใช้ เหลืออยู่หลัง logout
    if (widget.onLogoutTap != null) {
      widget.onLogoutTap!(); // เรียก callback ถ้ามี
    } else {
      // ถ้าไม่มี callback → ไปหน้า login และลบ stack
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // แสดง dialog ยืนยันก่อน logout
  Future<void> _confirmLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'ยืนยันการออกจากระบบ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ? การดำเนินการนี้จะต้องเข้าสู่ระบบใหม่เพื่อใช้งาน'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // มุมโค้ง dialog
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // กดยกเลิก → ปิด dialog
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Color(0xFF3F8FAF)), // สีข้อความ
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // ปุ่มสีแดง
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // มุมโค้ง
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              _logout(context); // เรียก logout
            },
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.white), // ข้อความสีขาว
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>( // ฟังค่า ProfileProvider สำหรับแสดงตัวอักษรย่อ
      builder: (context, profile, child) { // parameter: context, provider instance, child (ไม่ใช้)
        final initialsFromProvider = profile.initials.isNotEmpty ? profile.initials : _initials;
        // เลือก initials: ถ้า provider มีค่าใช้ provider, ถ้าไม่มีใช้ค่า _initials

        return Padding(
          padding: const EdgeInsets.all(10.0), // เว้นระยะรอบ ๆ container
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            // เว้นระยะภายใน container ซ้าย-ขวา 20, บน-ล่าง 12
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAA7), // สีพื้นหลังของ AppBar
              borderRadius: BorderRadius.circular(40), // มุมโค้ง container
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // ชิดซ้าย-ขวา
              children: [
                const Text(
                  'EduNudge', // ชื่อแอป
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onProfileTap, // เมื่อกดที่ avatar จะเรียกฟังก์ชัน onProfileTap
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // เป็นวงกลม
                          gradient: LinearGradient(
                            colors: [Color(0xFF00B894), Color(0xFF91C8E4)], // สีไล่ gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initialsFromProvider, // แสดงตัวอักษรย่อ
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // เว้นระยะระหว่าง avatar กับปุ่ม power
                    GestureDetector(
                      onTap: () => _confirmLogout(context), // กดปุ่ม power → ยืนยัน logout
                      child: const Icon(
                        Icons.power_settings_new,
                        color: Colors.red, // ไอคอนสีแดง
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
