import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';

class ClassroomJoin extends StatefulWidget {
  const ClassroomJoin({Key? key}) : super(key: key);

  @override
  State<ClassroomJoin> createState() => _ClassroomJoinState();
}

class _ClassroomJoinState extends State<ClassroomJoin> {
  final TextEditingController _classCodeController = TextEditingController();

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853), 
        elevation: 0,
        automaticallyImplyLeading: false, 
        systemOverlayStyle: SystemUiOverlayStyle.light, 
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'เข้าร่วมห้องเรียน',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รหัสห้องเรียน',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ขอรหัสห้องเรียนจากอาจารย์ประจำวิชา นำมาใส่ที่นี่',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _classCodeController,
                      decoration: InputDecoration(
                        hintText: 'รหัสห้องเรียน',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'วิธีลงชื่อเข้าใช้ด้วยรหัสชั้นเรียน',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              _bulletPoint('ใช้บัญชีที่ได้รับอนุญาต'),
              _bulletPoint('ใช้รหัสห้องเรียนที่ได้รับจากอาจารย์ผู้สอนเท่านั้น'),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  if (_classCodeController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'กำลังเข้าร่วมห้องเรียน ${_classCodeController.text}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณากรอกรหัสห้องเรียน')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'เข้าร่วมห้องเรียน',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
