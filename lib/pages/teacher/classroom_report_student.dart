import 'package:flutter/material.dart';
import 'package:edunudge/services/api_service.dart'; // import ApiService
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class StudentReportPage extends StatefulWidget {
  final int classroomId;

  const StudentReportPage({super.key, required this.classroomId});

  @override
  State<StudentReportPage> createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage> {
  List<Map<String, dynamic>> students = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> downloadAndOpenPDF(String url, {String? fileName}) async {
    try {
      final dir = await getTemporaryDirectory(); // โฟลเดอร์ชั่วคราวของมือถือ
      final name =
          fileName ?? 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$name';

      // ดาวน์โหลดไฟล์ PDF ลงเครื่อง
      await Dio().download(url, filePath);

      // เปิดไฟล์ PDF ด้วย default viewer ของเครื่อง
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดาวน์โหลด PDF: $e')),
      );
    }
  }

  Future<void> fetchStudents() async {
    try {
      final data = await ApiService.studentAttendanceSummary(
        widget.classroomId,
      );
      setState(() {
        students = List<Map<String, dynamic>>.from(
          data.map((student) {
            return {
              'id': student['id'],
              'name': student['name'],
              'lastname': student['lastname'],
              'present': _toInt(student['present']),
              'absent': _toInt(student['absent']),
              'leave_count': _toInt(student['leave_count']),
              'late': _toInt(student['late']),
            };
          }),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลนักศึกษาได้: $e')),
      );
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  List<Map<String, dynamic>> get filteredStudents {
    if (searchQuery.isEmpty) return students;
    return students
        .where(
          (student) =>
              ('${student['name']} ${student['lastname']}'.toLowerCase())
                  .contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91C8E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF91C8E4),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // ปุ่มย้อนกลับเป็น "<"
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('รายงานสรุปนักศึกษาเเต่ละคน'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ส่วนเนื้อหาเลื่อนขึ้นลงได้
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people, color: Color(0xFF3F8FAF)),
                            const SizedBox(width: 8),
                            const Text(
                              'รายชื่อนักศึกษา',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 220,
                          height: 36,
                          child: TextField(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 12,
                              ),
                              hintText: 'ค้นหา',
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3F8FAF),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ตารางหัวคอลัมน์
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.black),
                              left: BorderSide(color: Colors.black),
                              right: BorderSide(color: Colors.black),
                              bottom: BorderSide(color: Colors.black),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    'ชื่อ - นามสกุล',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: Colors.black,
                                thickness: 1,
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'มา',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: Colors.black,
                                thickness: 1,
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'ขาด',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: Colors.black,
                                thickness: 1,
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'สาย',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: Colors.black,
                                thickness: 1,
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'ลา',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (filteredStudents.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'ไม่พบข้อมูล',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: filteredStudents.asMap().entries.map(
                              (entry) {
                                int idx = entry.key;
                                Map<String, dynamic> student = entry.value;
                                final bool isLast =
                                    idx == filteredStudents.length - 1;
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
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          )
                                        : null,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            '${student['name'] ?? ''} ${student['lastname'] ?? ''}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: Colors.black,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            student['present']?.toString() ?? '0',
                                            style: const TextStyle(
                                              color: Color(0xFF078230),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: Colors.black,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            student['absent']?.toString() ?? '0',
                                            style: const TextStyle(
                                              color: Color(0xFFFF0000),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: Colors.black,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            student['late']?.toString() ?? '0',
                                            style: const TextStyle(
                                              color: Color(0xFFF18D00),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: Colors.black,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            student['leave_count']?.toString() ?? '0',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                61,
                                                95,
                                                242,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ปุ่มดาวน์โหลดติดด้านล่าง
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F8FAF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final token = await ApiService.getToken();
                          final url =
                              'http://52.63.155.211/classrooms/${widget.classroomId}/attendance-pdf/$token';

                          await downloadAndOpenPDF(
                            url,
                            fileName:
                                'StudentReport_${widget.classroomId}.pdf',
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'ดาวน์โหลดเอกสาร (pdf.)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
