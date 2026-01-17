import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edunudge/services/api_service.dart';
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  final int classroomId; 
  // classroomId ของห้องเรียนนี้ ใช้เพื่อดึงข้อมูลนักเรียนและเช็คชื่อ

  const AttendancePage({super.key, required this.classroomId});
  // constructor รับ classroomId เป็นค่า required

  @override
  State<AttendancePage> createState() => _AttendancePageState();
  // สร้าง state สำหรับหน้า AttendancePage
}

class _AttendancePageState extends State<AttendancePage> {
  // ตัวแปรสำหรับจัดการวันที่ในรูปแบบไทย
  String formattedDate = DateFormat('dd MMMM yyyy', 'th')
      .format(DateTime.now())
      .replaceAllMapped(RegExp(r'\d{4}'), (match) {
    int year = int.parse(match.group(0)!);
    return (year + 543).toString(); 
    // แปลงปี ค.ศ. เป็น พ.ศ.
  });

  bool isLoading = true; 
  // ใช้แสดง loading ขณะดึงข้อมูลนักเรียน
  bool hasClassToday = true; 
  // ตรวจสอบว่ามีเรียนวันนี้หรือไม่
  String message = ""; 
  // ข้อความแจ้งเตือนเมื่อไม่มีเรียนวันนี้
  List<Map<String, dynamic>> students = []; 
  // รายชื่อนักเรียน
  List<Map<String, dynamic>> statusList = []; 
  // สถานะเช็คชื่อของนักเรียน
  Map<int, String> tempStatusMap = {}; 
  // เก็บสถานะชั่วคราวก่อนบันทึกจริง

  @override
  void initState() {
    super.initState();
    _loadStudents(); 
    // เรียกโหลดรายชื่อนักเรียนทันทีเมื่อเริ่มหน้า
  }

  Future<void> _loadStudents() async {
    // ดึงข้อมูลนักเรียนจาก API และโหลดสถานะจาก SharedPreferences
    try {
      final classroomDetail =
          await ApiService.getTeacherClassroomDetail(widget.classroomId); 
          // เรียก API ดึงรายละเอียดห้องเรียน

      hasClassToday = classroomDetail['has_class_today'] ?? true; 
      // เช็คว่ามีเรียนวันนี้หรือไม่
      message = classroomDetail['message'] ?? ""; 
      // ข้อความแจ้งเตือนถ้าไม่มีเรียน

      final prefs = await SharedPreferences.getInstance(); 
      // ดึง instance ของ SharedPreferences
      final studentData = (classroomDetail['students'] as List<dynamic>?) ?? []; 
      // ดึงรายชื่อนักเรียนจาก API

      final savedStatusJson =
          prefs.getString('attendance_${widget.classroomId}'); 
          // โหลดสถานะเก่าที่บันทึกไว้
      Map<String, dynamic> savedStatus = {};
      if (savedStatusJson != null) savedStatus = jsonDecode(savedStatusJson); 
      // แปลง JSON เป็น Map

      List<Map<String, dynamic>> loadedStudents = studentData.map((s) {
        int? userId;
        if (s['user_id'] is int) userId = s['user_id']; 
        else if (s['user_id'] is String) userId = int.tryParse(s['user_id']); 
        // แปลง user_id ให้เป็น int เสมอ

        String status = '';
        if (userId != null) {
          status = savedStatus[userId.toString()] ?? (s['status'] ?? ''); 
          // ใช้สถานะเก่าที่บันทึกไว้ ถ้าไม่มีใช้ค่าจาก API
          tempStatusMap[userId] = status; 
          // เก็บชั่วคราวใน tempStatusMap
        }

        return {
          'id': userId, 
          'name': s['name'] ?? '', 
          'lastname': s['lastname'] ?? '',
        };
      }).where((s) => s['id'] != null).toList(); 
      // ลบนักเรียนที่ไม่มี userId

      setState(() {
        students = loadedStudents; 
        // อัพเดตรายชื่อนักเรียนใน state
        statusList = students.map((s) {
          int uid = s['id']; 
          String val = tempStatusMap[uid] ?? "";
          return {
            "value": val, 
            // ค่าที่เลือก
            "label": getLabelFromValue(val), 
            // แปลงเป็น label ภาษาไทย
            "disabled": !hasClassToday, 
            // ปิดปุ่มถ้าไม่มีเรียนวันนี้
          };
        }).toList();
        isLoading = false; 
        // ปิด loading
      });
    } catch (e) {
      setState(() => isLoading = false); 
      // ปิด loading ถ้าเกิด error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลนักเรียนได้: $e')), 
        // แสดง error
      );
    }
  }

  String getLabelFromValue(String value) {
    // แปลงค่า value เป็น label ภาษาไทย
    switch (value) {
      case "present":
        return "มา";
      case "late":
        return "สาย";
      case "leave":
        return "ลา";
      case "absent":
        return "ขาด";
      default:
        return "";
    }
  }

  String getInitials(String name, String? lastname) {
    // คืนค่าตัวย่อจากชื่อและนามสกุล
    String initials = '';
    if (name.isNotEmpty) initials += name[0];
    if (lastname != null && lastname.isNotEmpty) initials += lastname[0];
    return initials.toUpperCase(); 
    // แปลงเป็นตัวใหญ่
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; 
    // ความกว้างหน้าจอ
    final avatarRadius = screenWidth * 0.04; 
    // ขนาดวงกลม avatar
    final initialFontSize = screenWidth * 0.035; 
    // ขนาดตัวอักษรใน avatar
    final buttonFontSize = screenWidth * 0.025; 
    // ขนาดตัวอักษรในปุ่มเช็คชื่อ

    return Scaffold(
      backgroundColor: const Color(0xFF91C8E4), 
      // สีพื้นหลังหลัก
      appBar: AppBar(
        backgroundColor: const Color(0xFF91C8E4), 
        elevation: 0, 
        // ไม่มีเงา
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: onBackPressed, 
          // กลับหน้าก่อนหน้า
        ),
        title: const Text(
          'การเช็คชื่อเข้าเรียน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) 
          // แสดง loading ถ้ากำลังดึงข้อมูล
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF91C8E4), Color(0xFF00BCD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!hasClassToday)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          message, 
                          // ข้อความแจ้งเตือนเมื่อไม่มีเรียน
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF91C8E4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                formattedDate, 
                                // แสดงวันที่ปัจจุบัน
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Icon(Icons.people, color: const Color(0xFF3F8FAF)),
                                SizedBox(width: 8),
                                Text(
                                  'รายชื่อนักเรียน',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: students.isEmpty
                                  ? Center(
                                      child: Text(
                                        'ยังไม่มีนักเรียนในห้อง', 
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: students.length,
                                      itemBuilder: (context, index) =>
                                          _buildStudentRow(
                                        index,
                                        avatarRadius,
                                        initialFontSize,
                                        buttonFontSize,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStudentRow(
      int index, double avatarRadius, double initialFontSize, double buttonFontSize) {
    // สร้าง row ของนักเรียนแต่ละคน
    final student = students[index];
    final initials = getInitials(student['name'], student['lastname']); 
    // ตัวย่อ

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x336D6D6D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFFFFEAA7), 
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold,
                fontSize: initialFontSize,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '${student['name']} ${student['lastname']}',
              style: TextStyle(color: Colors.black, fontSize: buttonFontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
              child: _buildStatusButton(
                  index, "present", "มา", "00C853", buttonFontSize)),
          const SizedBox(width: 4),
          Expanded(
              child: _buildStatusButton(
                  index, "late", "สาย", "FFAB40", buttonFontSize)),
          const SizedBox(width: 4),
          Expanded(
              child: _buildStatusButton(
                  index, "leave", "ลา", "2979FF", buttonFontSize)),
          const SizedBox(width: 4),
          Expanded(
              child: _buildStatusButton(
                  index, "absent", "ขาด", "FF1800", buttonFontSize)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
      int index, String value, String label, String hexColor, double fontSize) {
    final isSelected = statusList[index]["value"] == value; 
    // ตรวจสอบว่านี่คือ status ที่เลือกอยู่หรือไม่
    final disabled = statusList[index]["disabled"] ?? false; 
    // ปิดปุ่มถ้าไม่มีเรียนวันนี้

    return GestureDetector(
      onTap: disabled
          ? null 
          : () async {
              int uid = students[index]['id'];

              tempStatusMap[uid] = value; 
              // เก็บสถานะชั่วคราว
              final prefs = await SharedPreferences.getInstance();
              final savedMap =
                  tempStatusMap.map((key, val) => MapEntry(key.toString(), val));
              await prefs.setString(
                  'attendance_${widget.classroomId}', jsonEncode(savedMap)); 
              // บันทึกสถานะใน local storage

              try {
                await ApiService.markAttendance(
                  userId: uid,
                  classroomId: widget.classroomId,
                  status: value,
                ); 
                // เรียก API บันทึกสถานะ
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'เช็คชื่อไม่สำเร็จสำหรับ ${students[index]['name']}: $e'),
                  ),
                );
              }

              setState(() {
                statusList[index]["value"] = value; 
                statusList[index]["label"] = getLabelFromValue(value);
                // อัพเดต UI ของปุ่ม
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.shade300
              : (isSelected ? Color(int.parse('0xFF$hexColor')) : Colors.white),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: disabled ? Colors.grey : (isSelected ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  void onBackPressed() {
    Navigator.pop(context); 
    // กลับหน้าก่อนหน้า
  }
}