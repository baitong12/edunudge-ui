import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';

class ClassroomJoin extends StatefulWidget {
  const ClassroomJoin({Key? key}) : super(key: key);

  @override
  State<ClassroomJoin> createState() => _ClassroomJoin();
}

class _ClassroomJoin extends State<ClassroomJoin> {
  final TextEditingController _classCodeController = TextEditingController();

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF221B64),
          appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          onLogoutTap: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'เข้าร่วมห้องเรียน',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'รหัสห้องเรียน',
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  // ),
                  Text(
                    'ขอรหัสห้องเรียนจากอาจารย์ประจำวิชา นำมาใส่ที่นี่',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _classCodeController,
                    decoration: InputDecoration(
                      hintText: 'รหัสห้องเรียน',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ขั้นตอนการเข้าร่วมห้องเรียน',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bulletPoint('ป้อนรหัสห้องเรียน'),
                  _bulletPoint('เลือกยืนยันการเข้าร่วม'),
                  _bulletPoint('ระบบจะทำการเชื่อมต่อไปยังหน้าห้องเรียน'),
                  
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_classCodeController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('กำลังเข้าร่วมห้องเรียน ${_classCodeController.text}')),
                  );
                  // Navigator.pushNamed(context, '/classroom', arguments: _classCodeController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกรหัสห้องเรียน')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 25, 120, 197),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('เข้าร่วมห้องเรียน', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF000000),
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('ยกเลิก', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }

Widget _bulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 14, color: Colors.white)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.white), 
          ),
        ),
      ],
    ),
  );
}
}