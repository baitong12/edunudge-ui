import 'package:flutter/material.dart';
import 'package:edunudge/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}


class _AttendanceState extends State<Attendance> {
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoadingTable = true;

  String selectedSubject = '';
  Map<String, int> subjectIds = {}; // name_subject => classroomId

  Map<String, dynamic> selectedSubjectDetail = {};
  bool isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoadingTable = true;
      isLoadingDetail = false;
      selectedSubjectDetail = {};
    });

    try {
      final data = await ApiService.homeAttendanceSummary();
      final classrooms = List<Map<String, dynamic>>.from(data['classrooms']);

      subjectIds = {
        for (var cls in classrooms)
          cls['name_subject'] as String: cls['classroom_id'] as int
      };

      setState(() {
        attendanceData = classrooms;
        // ตั้งค่า selectedSubject เป็นวิชาแรกเสมอ
        selectedSubject = subjectIds.isNotEmpty ? subjectIds.keys.first : '';
        isLoadingTable = false;
      });

      // โหลดรายละเอียดวิชาแรกทันทีถ้ามี
      if (selectedSubject.isNotEmpty) {
        await fetchSubjectDetail(selectedSubject);
      } else {
        setState(() {
          selectedSubjectDetail = {};
          isLoadingDetail = false;
        });
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      setState(() {
        isLoadingTable = false;
        isLoadingDetail = false;
      });
    }
  }

  Future<void> fetchSubjectDetail(String subjectName) async {
    final classroomId = subjectIds[subjectName];
    if (classroomId == null) return;

    setState(() {
      isLoadingDetail = true;
      selectedSubjectDetail = {};
    });

    try {
      final data = await ApiService.homeSubjectDetail(classroomId);

      setState(() {
        selectedSubjectDetail = data;
        isLoadingDetail = false;
      });
    } catch (e) {
      print('Error fetching subject detail: $e');
      setState(() {
        isLoadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              isLoadingTable
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
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
                          ...attendanceData.asMap().entries.map((entry) {
                            int idx = entry.key;
                            final val = entry.value;
                            final bool isLast =
                                idx == attendanceData.length - 1;
                            final Color rowColor = idx % 2 == 0
                                ? const Color(0x336D6D6D)
                                : const Color(0x6E3F8FAF);

                            return Container(
                              decoration: BoxDecoration(
                                color: rowColor,
                                border: const Border(
                                  left: BorderSide(color: Colors.black),
                                  right: BorderSide(color: Colors.black),
                                  bottom: BorderSide(color: Colors.black),
                                ),
                                borderRadius: isLast
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      )
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        val['name_subject'] ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        val['present']?.toString() ?? '0',
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        val['late']?.toString() ?? '0',
                                        style: const TextStyle(
                                            color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        val['absent']?.toString() ?? '0',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        val['leave_count']?.toString() ?? '0',
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        '${val['percent']?.toString() ?? '0'}%',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
              const SizedBox(height: 16),
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
                    child: DropdownButton<String>(
                      value:
                          selectedSubject.isNotEmpty ? selectedSubject : null,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          selectedSubject = newValue;
                        });
                        fetchSubjectDetail(newValue);
                      },
                      items: subjectIds.keys.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoadingDetail
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        'ชื่อวิชา: ${selectedSubjectDetail['name_subject'] ?? '-'}\n'
                        'อาคารเรียน: ${selectedSubjectDetail['room_number'] ?? '-'}\n'
                        'อาจารย์ผู้สอน: ${selectedSubjectDetail['teacher_name'] ?? '-'}\n'
                        'คณะ: ${selectedSubjectDetail['department'] ?? '-'}\n'
                        'เบอร์ติดต่อ: ${selectedSubjectDetail['contact'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F8FAF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () async {
                    try {
                      final token =
                          await ApiService.getToken();
                      final url =
                          'http://127.0.0.1:8000/student/home-attendance-pdf/$token';
                      Uri uri = Uri.parse(url);

                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('ไม่สามารถเปิดลิงก์ได้')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'ดาวน์โหลดเอกสาร (pdf.)',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}