import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:edunudge/services/api_service.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ข้อความเข้าร่วมห้องเรียนตรงกลาง
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'เข้าร่วมห้องเรียน',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // กล่องรหัสห้องเรียน
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รหัสห้องเรียน',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ขอรหัสห้องเรียนจากอาจารย์ประจำวิชา นำมาใส่ที่นี่',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        prefixIcon:
                            const Icon(Icons.vpn_key, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ข้อความแนะนำเพิ่มเติมด้านล่าง
                    const Text(
                      '- วิธีลงชื่อเข้าใช้ด้วยรหัส\n'
                      '- ใช้บัญชีที่ได้รับอนุญาต\n'
                      '- ใช้รหัสห้องเรียนที่ได้รับจากอาจารย์ผู้สอนเท่านั้น',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ปุ่มเข้าร่วม
              ElevatedButton(
                onPressed: _isLoading ? null : _joinClassroom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                  shadowColor: Colors.black45,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'เข้าร่วมห้องเรียน',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),

              // ปุ่มยกเลิก
              // ปุ่มยกเลิก
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home_student');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                  shadowColor: Colors.black38,
                ),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }
}
