import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edunudge/services/api_service.dart';
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  final int classroomId;
  const AttendancePage({super.key, required this.classroomId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String formattedDate = DateFormat('dd MMMM yyyy', 'th')
      .format(DateTime.now())
      .replaceAllMapped(RegExp(r'\d{4}'), (match) {
    int year = int.parse(match.group(0)!);
    return (year + 543).toString();
  });

  bool isLoading = true;
  bool hasClassToday = true;
  String message = "";
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> statusList = [];
  Map<int, String> tempStatusMap = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final classroomDetail =
          await ApiService.getTeacherClassroomDetail(widget.classroomId);

      hasClassToday = classroomDetail['has_class_today'] ?? true;
      message = classroomDetail['message'] ?? "";

      final prefs = await SharedPreferences.getInstance();
      final studentData = (classroomDetail['students'] as List<dynamic>?) ?? [];

      final savedStatusJson =
          prefs.getString('attendance_${widget.classroomId}');
      Map<String, dynamic> savedStatus = {};
      if (savedStatusJson != null) savedStatus = jsonDecode(savedStatusJson);

      List<Map<String, dynamic>> loadedStudents = studentData.map((s) {
        int? userId;
        if (s['user_id'] is int) userId = s['user_id'];
        else if (s['user_id'] is String) userId = int.tryParse(s['user_id']);

        String status = '';
        if (userId != null) {
          status = savedStatus[userId.toString()] ?? (s['status'] ?? '');
          tempStatusMap[userId] = status;
        }

        return {
          'id': userId,
          'name': s['name'] ?? '',
          'lastname': s['lastname'] ?? '',
        };
      }).where((s) => s['id'] != null).toList();

      setState(() {
        students = loadedStudents;
        statusList = students.map((s) {
          int uid = s['id'];
          String val = tempStatusMap[uid] ?? "";
          return {
            "value": val,
            "label": getLabelFromValue(val),
            "disabled": !hasClassToday, // ปุ่มบล็อกถ้าไม่มีเรียน
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลนักเรียนได้: $e')),
      );
    }
  }

  String getLabelFromValue(String value) {
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
    String initials = '';
    if (name.isNotEmpty) initials += name[0];
    if (lastname != null && lastname.isNotEmpty) initials += lastname[0];
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth * 0.04;
    final initialFontSize = screenWidth * 0.035;
    final buttonFontSize = screenWidth * 0.025;

    return Scaffold(
      backgroundColor: const Color(0xFF00C853),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBackPressed,
        ),
        title: const Text(
          'การเช็คชื่อเข้าชั้นเรียน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
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
                                color: const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                formattedDate,
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
                                Icon(Icons.people, color: Color(0xFF3F8FAF)),
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
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
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
    final student = students[index];
    final initials = getInitials(student['name'], student['lastname']);

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
            backgroundColor: const Color(0xFF00C853),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
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
    final disabled = statusList[index]["disabled"] ?? false;

    return GestureDetector(
      onTap: disabled
          ? null
          : () async {
              int uid = students[index]['id'];

              tempStatusMap[uid] = value;
              final prefs = await SharedPreferences.getInstance();
              final savedMap =
                  tempStatusMap.map((key, val) => MapEntry(key.toString(), val));
              await prefs.setString(
                  'attendance_${widget.classroomId}', jsonEncode(savedMap));

              try {
                await ApiService.markAttendance(
                  userId: uid,
                  classroomId: widget.classroomId,
                  status: value,
                );
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
  }
}
