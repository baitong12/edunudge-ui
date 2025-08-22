import 'package:flutter/material.dart';

class Register02 extends StatefulWidget {
  @override
  State<Register02> createState() => _Register02State();
}

class _Register02State extends State<Register02> {
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedRole;

  // รายการคณะ
  final List<String> faculties = [
    'คณะเทคโนโลยีการจัดการ',
    'คณะเกษตรศาสตร์และเทคโนโลยี',
  ];

  // รายการสาขาวิชา
  final List<String> departments = [
    'สาขาวิชาพืชศาสตร์',
    'สาขาวิชาการออกแบบภูมิทัศน์และการจัดสวน',
    'สาขาวิชาเทคโนโลยีสิ่งทอและการออกแบบแฟชั่น',
    'สาขาอุตสาหกรรมอาหาร',
    'สาขาวิชาเทคโนโลยีการอาหาร',
    'สาขาวิชาเทคโนโลยีชีวภาพการเกษตร',
    'สาขาวิชาเทคโนโลยีเครื่องจักรกลเกษตร',
  ];


  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'name': 'student'},
    {'id': 2, 'name': 'teacher'},
  ];

  
  void _registerUser() {

    if (_selectedRole == 'teacher') {
      Navigator.of(context).pushNamedAndRemoveUntil('/home_teacher', (route) => false);
    } else if (_selectedRole == 'student') {
      Navigator.of(context).pushNamedAndRemoveUntil('/home_student', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกสถานะของคุณ (นักศึกษา/อาจารย์)')),
      );
    }
  }

  void _cancel() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // รับค่า arguments ที่ส่งมาจาก Register01 (ถ้ามี)
    // final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      body: Container(
        // ใช้ LinearGradient สำหรับพื้นหลังทั้งหมด ให้ตรงกับรูปภาพ
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00C853), // สีเขียวสดใส (ด้านบน)
              Color(0xFF00BCD4), // สีฟ้าสดใส (ด้านล่าง)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black38)
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown สำหรับคณะ
                  _buildDropdown(
                    value: _selectedFaculty,
                    hint: 'คณะ',
                    items: faculties,
                    onChanged: (value) {
                      setState(() {
                        _selectedFaculty = value;
                      });
                    },
                  ),
                  // Dropdown สำหรับสาขาวิชา
                  _buildDropdown(
                    value: _selectedDepartment,
                    hint: 'สาขา', // เปลี่ยนเป็น 'สาขา' ตามรูปภาพ
                    items: departments,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                  ),
                  // Dropdown สำหรับสถานะ
                  _buildDropdown(
                    value: _selectedRole,
                    hint: 'สถานะ',
                    items: _roles.map<String>((role) => role['name'].toString()).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    // เพิ่ม builder สำหรับแสดงข้อความที่เหมาะสม (นักศึกษา/อาจารย์)
                    itemBuilder: (context, item) {
                      return Text(item == 'student' ? 'นักศึกษา' : 'อาจารย์');
                    },
                  ),
                  const SizedBox(height: 20),
                  // ปุ่ม "ลงทะเบียน"
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25), // ขอบโค้งมนตามรูปภาพ
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // ปุ่มสีดำตามรูปภาพ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // ขอบโค้งมนตามรูปภาพ
                        ),
                      ),
                      onPressed: _registerUser, // เรียกใช้ฟังก์ชันลงทะเบียน
                      child: const Text(
                        'ลงทะเบียน',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ปุ่ม "ยกเลิก"
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25), // ขอบโค้งมนตามรูปภาพ
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // ปุ่มสีแดงตามรูปภาพ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // ขอบโค้งมนตามรูปภาพ
                        ),
                      ),
                      onPressed: _cancel, // เรียกใช้ฟังก์ชันยกเลิก
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget สำหรับสร้าง DropdownButtonFormField ที่มีสไตล์เหมือนกัน
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Widget Function(BuildContext, String)? itemBuilder, // เพิ่ม itemBuilder
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25), // ขอบโค้งมนตามรูปภาพ
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, // เงาเล็กน้อยเพื่อให้ดูมีมิติ
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF221B64)), // ไอคอนลูกศร
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none, // ไม่มีเส้นขอบ
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
          ),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: itemBuilder != null ? itemBuilder(context, item) : Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
