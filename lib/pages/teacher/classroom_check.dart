import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edunudge/services/api_service.dart';

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
  bool isSubmitting = false;

  List<Map<String, dynamic>> students = [];
  List<Map<String, String>> statusList = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final classroomDetail =
          await ApiService.getTeacherClassroomDetail(widget.classroomId);
      final studentData = classroomDetail['students'] as List<dynamic>? ?? [];

      setState(() {
        students = studentData
            .where((s) => s['user_id'] != null)
            .map((s) {
              int? userId;
              if (s['user_id'] is int) {
                userId = s['user_id'];
              } else if (s['user_id'] is String) {
                userId = int.tryParse(s['user_id']);
              }
              if (userId == null) {
                print('พบ user_id ที่แปลงเป็น int ไม่ได้: ${s['user_id']}');
              }
              return {
                'id': userId,
                'name': s['name'],
                'lastname': s['lastname'],
              };
            })
            .where((s) => s['id'] != null)
            .toList();

        // statusList เก็บเป็น object {value: "", label: ""}
        statusList =
            List.filled(students.length, {"value": "", "label": ""}, growable: true);

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลนักเรียนได้: $e')),
      );
    }
  }

  String getInitials(String name, String? lastname) {
    String initials = '';
    if (name.isNotEmpty) initials += name[0];
    if (lastname != null && lastname.isNotEmpty) initials += lastname[0];
    return initials.toUpperCase();
  }

  Future<void> markAllAttendance() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      await Future.wait(List.generate(students.length, (i) async {
        final userId = students[i]['id'];
        if (userId == null) {
          print('พบ student ที่ user_id เป็น null: ${students[i]}');
          return;
        }

        await ApiService.markAttendance(
          userId: userId,
          classroomId: widget.classroomId,
          status: statusList[i]["value"] ?? "", // ส่ง value อังกฤษ
        );
      }));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เช็คชื่อเสร็จสิ้น ${students.length} คน')),
      );

      Navigator.pushReplacementNamed(context, '/classroom_subject');
    } finally {
      setState(() => isSubmitting = false);
    }
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
          onPressed: () => Navigator.of(context).pop(),
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
                    Container(
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) => _buildStudentRow(
                                index,
                                avatarRadius,
                                initialFontSize,
                                buttonFontSize,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/classroom_subject',
                                      arguments: widget.classroomId,
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text('ยกเลิก',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: markAllAttendance,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2),
                                          )
                                        : const Text('เสร็จสิ้น',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStudentRow(
    int index,
    double avatarRadius,
    double initialFontSize,
    double buttonFontSize,
  ) {
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
          Expanded(child: _buildStatusButton(index, "absent", "ขาด", "FF1800", buttonFontSize)),
          const SizedBox(width: 4),
          Expanded(child: _buildStatusButton(index, "late", "สาย", "FFAB40", buttonFontSize)),
          const SizedBox(width: 4),
          Expanded(child: _buildStatusButton(index, "present", "มา", "00C853", buttonFontSize)),
          const SizedBox(width: 4),
          Expanded(child: _buildStatusButton(index, "leave", "ลา", "2979FF", buttonFontSize)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
      int index, String value, String label, String hexColor, double fontSize) {
    final isSelected = statusList[index]["value"] == value;
    return GestureDetector(
      onTap: () => setState(() {
        statusList[index] = {"value": value, "label": label};
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(int.parse('0xFF$hexColor')) : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
