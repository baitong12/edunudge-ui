import 'package:flutter/material.dart';
import 'package:edunudge/services/api_service.dart'; // import ApiService

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  int? selectedClassroomId;
  String selectedSubject = '';
  List<Map<String, dynamic>> subjects = [];
  Map<String, dynamic> selectedSubjectDetail = {};
  Map<String, dynamic> attendanceSummary = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudentHome();
  }

  // โหลดรายการห้องเรียนและสรุปการเข้าเรียน
  Future<void> loadStudentHome() async {
    setState(() {
      isLoading = true;
    });
    try {
      // ดึงรายการห้องเรียน
      final classroomList = await ApiService.getStudentClassrooms();
      subjects = classroomList
          .map((e) => {
                'id': e['id'], // classroom id
                'name': e['name_subject'],
              })
          .toList();

      if (subjects.isNotEmpty) {
        selectedClassroomId = subjects.first['id'];
        selectedSubject = subjects.first['name'];
        await loadSubjectDetail(selectedClassroomId!);
        await loadAttendanceSummary(selectedClassroomId!);
      }
    } catch (e) {
      print('Error loading student home: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // โหลดรายละเอียดรายวิชาที่เลือก
  Future<void> loadSubjectDetail(int classroomId) async {
    try {
      final detail = await ApiService.getSubjectDetail(classroomId);
      setState(() {
        selectedSubjectDetail = detail;
      });
    } catch (e) {
      print('Error loading subject detail: $e');
    }
  }

  // โหลดสรุปการเข้าเรียนของวิชาที่เลือก
  Future<void> loadAttendanceSummary(int classroomId) async {
    try {
      // สำหรับตัวอย่างนี้ใช้ API Home (อาจปรับเป็น API เฉพาะวิชาได้)
      final summary = await ApiService.getStudentHome();
      setState(() {
        attendanceSummary = summary;
      });
    } catch (e) {
      print('Error loading attendance summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อมูลการเข้าเรียน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ตารางสถิติการเข้าเรียน
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF3F8FAF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: const [
                          Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('ชื่อวิชา',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('มา',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('มาสาย',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('ขาด',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('ลา',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))),
                          Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('รวมทั้งหมด',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0x336D6D6D),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Center(child: Text(selectedSubject))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(
                                      attendanceSummary['present']?.toString() ??
                                          '0',
                                      style: const TextStyle(
                                          color: Colors.green)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(
                                      attendanceSummary['late']?.toString() ??
                                          '0',
                                      style: const TextStyle(
                                          color: Colors.orange)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(
                                      attendanceSummary['absent']?.toString() ??
                                          '0',
                                      style: const TextStyle(
                                          color: Colors.red)))),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(
                                      attendanceSummary['leave']?.toString() ??
                                          '0',
                                      style: const TextStyle(
                                          color: Colors.blue)))),
                          Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text(
                                      '${(attendanceSummary['present'] ?? 0)}%'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dropdown เลือกวิชา
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedClassroomId,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16),
                      onChanged: (int? newId) async {
                        if (newId != null) {
                          final newSubject = subjects
                              .firstWhere((e) => e['id'] == newId)['name'];
                          setState(() {
                            selectedClassroomId = newId;
                            selectedSubject = newSubject;
                            isLoading = true;
                          });

                          await loadSubjectDetail(newId);
                          await loadAttendanceSummary(newId);

                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      items: subjects.map((e) {
                        return DropdownMenuItem<int>(
                          value: e['id'],
                          child: Text(e['name']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // รายละเอียดรายวิชา
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  selectedSubjectDetail.isNotEmpty
                      ? 'ชื่อวิชา: ${selectedSubjectDetail['name_subject']}\n'
                          'อาคารเรียน: ${selectedSubjectDetail['room_number']}\n'
                          'อาจารย์ผู้สอน: ${selectedSubjectDetail['teacher_name']}\n'
                          'ภาควิชา: ${selectedSubjectDetail['department']}\n'
                          'เบอร์ติดต่อ: ${selectedSubjectDetail['contact']}'
                      : 'ไม่มีข้อมูล',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 150, 63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('ดาวน์โหลดเอกสาร (pdf.)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
