// นำเข้าไลบรารีหลักของ Flutter สำหรับสร้าง UI
import 'package:flutter/material.dart';
// นำเข้าหน้าของ Bottom Navigation ของนักเรียน
import 'package:edunudge/pages/student/custombottomnav.dart';
// นำเข้า Service สำหรับเรียก API
import 'package:edunudge/services/api_service.dart';
// นำเข้าคัสตอม AppBar ของแอป
import 'package:edunudge/shared/customappbar.dart';

// ประกาศ StatefulWidget สำหรับหน้าการเข้าร่วมห้องเรียน
class ClassroomJoin extends StatefulWidget {
  const ClassroomJoin({Key? key}) : super(key: key);

  @override
  State<ClassroomJoin> createState() => _ClassroomJoinState();
}

// สร้าง State สำหรับ ClassroomJoin
class _ClassroomJoinState extends State<ClassroomJoin> {
  // ตัวควบคุม TextField สำหรับเก็บรหัสห้องเรียน
  final TextEditingController _classCodeController = TextEditingController();
  // ตัวแปรบอกสถานะการโหลด (กำลังส่งข้อมูล)
  bool _isLoading = false;

  @override
  void dispose() {
    // ล้างตัวควบคุม TextField เพื่อป้องกัน memory leak
    _classCodeController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับเข้าร่วมห้องเรียน
  Future<void> _joinClassroom() async {
    // ดึงค่ารหัสห้องเรียนจาก TextField และตัดช่องว่าง
    final code = _classCodeController.text.trim();
    // เช็คว่าผู้ใช้ไม่ได้กรอกรหัสห้องเรียน
    if (code.isEmpty) {
      // แสดง SnackBar แจ้งเตือนให้กรอกข้อมูล
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกรหัสห้องเรียน')),
      );
      return; // ออกจากฟังก์ชัน
    }

    // ตั้งสถานะเป็นกำลังโหลด
    setState(() => _isLoading = true);

    try {
      // ดึง token ของผู้ใช้จาก ApiService
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

      // เรียก API เพื่อเข้าร่วมห้องเรียน
      final response = await ApiService.joinClassroom(code);

      // เช็คว่าการเข้าร่วมสำเร็จหรือไม่
      if (response.containsKey('classroom')) {
        // แสดง SnackBar แจ้งว่าสำเร็จ พร้อมชื่อวิชา
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'เข้าร่วมห้องเรียนสำเร็จ: ${response['classroom']['name_subject']}'),
          ),
        );
        // ไปหน้าห้องเรียนและลบหน้าปัจจุบันออกจาก stack
        Navigator.pushReplacementNamed(context, '/classroom');
      } else {
        // ถ้าเข้าร่วมไม่สำเร็จ แสดงข้อความแจ้งเตือน
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'เข้าร่วมห้องเรียนไม่สำเร็จ: ${response['message'] ?? 'ไม่ทราบสาเหตุ'}'),
          ),
        );
      }
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาดใด ๆ แสดง SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      // ตั้งสถานะโหลดเป็น false ไม่ว่าผลลัพธ์จะสำเร็จหรือไม่
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงขนาดหน้าจอเพื่อปรับ UI ให้ responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // ตั้งพื้นหลังเป็นสีขาว
      backgroundColor: Colors.white,
      // กำหนด AppBar แบบกำหนดเอง
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: Colors.white,
          child: CustomAppBar(
            onProfileTap: () {
              // กดที่โปรไฟล์ → ไปหน้าประวัติผู้ใช้
              Navigator.pushNamed(context, '/profile');
            },
            onLogoutTap: () {
              // กด logout → ไปหน้าล็อกอินและลบทุกหน้าก่อนหน้า
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ),
      ),
      // ส่วนเนื้อหาหลักของหน้าจอ
      body: Container(
        width: double.infinity,
        height: screenHeight, // ใช้เต็มความสูงหน้าจอ
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, // เว้นขอบซ้ายขวา 8% ของหน้าจอ
          vertical: screenHeight * 0.06, // เว้นขอบบนล่าง 6% ของหน้าจอ
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // หัวข้อหน้าจอ
            const Text(
              'เข้าร่วมห้องเรียน',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00B894),
                fontWeight: FontWeight.bold,
                fontSize: 30,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05), // เว้นวรรค 5%

            // กล่องใส่ข้อมูลรหัสห้องเรียน
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.06), // padding 6%
              decoration: BoxDecoration(
                color: Colors.white, // พื้นหลังสีขาว
                borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
                border: Border.all(
                  color: const Color(0xFF00B894), // ขอบสีเขียว
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, // เงาอ่อน
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อฟิลด์
                  const Text(
                    'รหัสห้องเรียน',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B894),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01), // เว้นวรรค 1%
                  // คำอธิบาย
                  const Text(
                    'ขอรหัสห้องเรียนจากอาจารย์ประจำวิชา นำมาใส่ที่นี่',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: screenHeight * 0.03), // เว้นวรรค 3%

                  // TextField สำหรับกรอกรหัสห้องเรียน
                  TextField(
                    controller: _classCodeController, // เชื่อมกับตัวควบคุม
                    decoration: InputDecoration(
                      hintText: 'รหัสห้องเรียน', // ข้อความแนะนำ
                      filled: true,
                      fillColor: Colors.grey.shade100, // พื้นหลังสีเทาอ่อน
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14), // ขอบโค้ง 14
                        borderSide: BorderSide.none, // ไม่มีขอบ
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF00B894), width: 2), // ขอบเมื่อโฟกัส
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02), // ระยะห่างด้านใน
                      prefixIcon:
                          const Icon(Icons.vpn_key, color: Color(0xFF00B894)), // ไอคอน
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // เว้นวรรค 2%

                  // ข้อความคำแนะนำเพิ่มเติม
                  const Text(
                    '- วิธีลงชื่อเข้าใช้ด้วยรหัส\n'
                    '- ใช้บัญชีที่ได้รับอนุญาต\n'
                    '- ใช้รหัสห้องเรียนที่ได้รับจากอาจารย์ผู้สอนเท่านั้น',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.06), // เว้นวรรค 6%

            // ปุ่มเข้าร่วมห้องเรียน
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinClassroom, // ถ้าโหลดอยู่กดไม่ได้
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEAA7), // สีปุ่ม
                  foregroundColor: Colors.black, // สีตัวอักษร
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // มุมโค้ง
                    side: BorderSide.none,
                  ),
                  elevation: 6, // ความสูงของเงา
                  shadowColor: Colors.black26,
                ),
                // ถ้าโหลดอยู่ แสดงวงกลมรอ, ไม่งั้นแสดงข้อความ
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const Text(
                        'เข้าร่วมห้องเรียน',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar แบบกำหนดเอง
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }
}
