import 'package:flutter/material.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:edunudge/services/api_service.dart';
import 'package:edunudge/shared/customappbar.dart'; // เพิ่ม import สำหรับ CustomAppBar

class ClassroomJoin extends StatefulWidget {
  const ClassroomJoin({Key? key}) : super(key: key);

  @override
  State<ClassroomJoin> createState() => _ClassroomJoinState();
}

class _ClassroomJoinState extends State<ClassroomJoin> {
  final TextEditingController _classCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinClassroom() async {
    final code = _classCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกรหัสห้องเรียน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

      final response = await ApiService.joinClassroom(code);

      if (response.containsKey('classroom')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'เข้าร่วมห้องเรียนสำเร็จ: ${response['classroom']['name_subject']}'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/classroom');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'เข้าร่วมห้องเรียนไม่สำเร็จ: ${response['message'] ?? 'ไม่ทราบสาเหตุ'}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: Colors.white, // พื้นหลัง AppBar สีขาว
          child: CustomAppBar(
            onProfileTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            onLogoutTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: screenHeight, // ล็อคหน้าไม่ให้เลื่อน
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.06,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // หัวข้อ
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
            SizedBox(height: screenHeight * 0.05),

            // กล่องรหัสห้องเรียน
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00B894),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'รหัสห้องเรียน',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B894),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const Text(
                    'ขอรหัสห้องเรียนจากอาจารย์ประจำวิชา นำมาใส่ที่นี่',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextField(
                    controller: _classCodeController,
                    decoration: InputDecoration(
                      hintText: 'รหัสห้องเรียน',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF00B894), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02),
                      prefixIcon:
                          const Icon(Icons.vpn_key, color: Color(0xFF00B894)),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    '- วิธีลงชื่อเข้าใช้ด้วยรหัส\n'
                    '- ใช้บัญชีที่ได้รับอนุญาต\n'
                    '- ใช้รหัสห้องเรียนที่ได้รับจากอาจารย์ผู้สอนเท่านั้น',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.06),

            // ปุ่มเข้าร่วม
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinClassroom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEAA7), // สีพื้นหลังใหม่
                  foregroundColor: Colors.black, // ตัวอักษรสีดำ
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide.none,
                  ),
                  elevation: 6,
                  shadowColor: Colors.black26,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.black, // สีวงกลมโหลด
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
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }
}
