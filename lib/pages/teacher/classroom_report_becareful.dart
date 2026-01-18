import 'package:flutter/material.dart';
import 'package:edunudge/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportBecarefulPage extends StatefulWidget {
  final int classroomId; 
  // classroomId ของห้องเรียน ใช้เพื่อดึงรายชื่อนักศึกษาที่เฝ้าระวัง

  const ReportBecarefulPage({super.key, required this.classroomId});
  // constructor รับ classroomId เป็น required

  @override
  State<ReportBecarefulPage> createState() => _ReportBecarefulPageState();
  // สร้าง state ของหน้า ReportBecarefulPage
}

class _ReportBecarefulPageState extends State<ReportBecarefulPage> {
  final Color primaryColor = const Color(0xFFFFEAA7); 
  // สีหลักสำหรับปุ่มดาวน์โหลด PDF

  List<dynamic> students = []; 
  // รายชื่อนักศึกษาที่เฝ้าระวัง
  String searchQuery = ''; 
  // ตัวแปรเก็บข้อความค้นหา
  bool isLoading = true; 
  // แสดง loading ขณะดึงข้อมูล

  @override
  void initState() {
    super.initState();
    _fetchAtRiskStudents(); 
    // โหลดข้อมูลนักศึกษาที่เฝ้าระวังทันทีเมื่อเริ่มหน้า
  }

  Future<void> downloadAndOpenPDF(String url, {String? fileName}) async {
    // ฟังก์ชันดาวน์โหลด PDF และเปิดไฟล์
    try {
      final dir = await getTemporaryDirectory(); 
      // ดึง path ของ temp directory
      final name =
          fileName ?? 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf'; 
      // กำหนดชื่อไฟล์ ถ้าไม่ได้ระบุใช้ timestamp
      final filePath = '${dir.path}/$name'; 
      // path เต็มของไฟล์ที่จะดาวน์โหลด

      await Dio().download(url, filePath); 
      // ดาวน์โหลดไฟล์จาก URL ไปยัง path
      await OpenFile.open(filePath); 
      // เปิดไฟล์ PDF
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดาวน์โหลด PDF: $e')), 
        // แสดง error ถ้าดาวน์โหลดหรือเปิดไฟล์ล้มเหลว
      );
    }
  }

  Future<void> _fetchAtRiskStudents() async {
    // ฟังก์ชันโหลดรายชื่อนักศึกษาที่เฝ้าระวังจาก API
    try {
      final data = await ApiService.getAtRiskStudents(widget.classroomId); 
      // เรียก API
      setState(() {
        students = data; 
        // เก็บข้อมูลนักศึกษา
        isLoading = false; 
        // ปิด loading
      });
    } catch (e) {
      setState(() => isLoading = false); 
      // ปิด loading ถ้าเกิด error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("โหลดข้อมูลล้มเหลว: $e"))); 
      // แสดงข้อความ error
    }
  }

  List<dynamic> get filteredStudents {
    // คืนค่ารายชื่อนักศึกษา หลังกรองด้วย searchQuery
    if (searchQuery.isEmpty) {
      return students; 
      // ถ้าไม่กรอก search คืนทั้งหมด
    } else {
      return students
          .where(
            (student) => "${student['name']} ${student['lastname']}"
                .toLowerCase()
                .contains(searchQuery.toLowerCase()), 
            // ตรวจสอบว่าชื่อหรือนามสกุลตรงกับ searchQuery หรือไม่
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91C8E4), 
      // สีพื้นหลังหลัก
      appBar: AppBar(
        backgroundColor: const Color(0xFF91C8E4), 
        // สี AppBar
        elevation: 0, 
        // ไม่มีเงา
        foregroundColor: Colors.white, 
        // สี icon และ text
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), 
          onPressed: () => Navigator.pop(context), 
          // กลับหน้าก่อนหน้า
        ),
        title: const Text('รายงานนักศึกษาที่เฝ้าระวัง'), 
        // ชื่อ AppBar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) 
          // ถ้า loading แสดง progress indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity, 
                // เต็มความกว้าง
                height:
                    MediaQuery.of(context).size.height - kToolbarHeight - 32, 
                // สูงไม่รวม AppBar และ padding
                decoration: BoxDecoration(
                  color: Colors.white, 
                  // สีพื้น container
                  borderRadius: BorderRadius.circular(16.0), 
                  // มุมโค้ง
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26, 
                      blurRadius: 4, 
                      offset: Offset(0, 2), 
                      // เงาเล็ก
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded, 
                            color: Colors.red, 
                            size: 28, 
                            // ไอคอนแจ้งเตือน
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'รายชื่อนักศึกษาที่เฝ้าระวัง จำนวน ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '${filteredStudents.length}', 
                                  // แสดงจำนวนคนที่ผ่าน filter
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' คน',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                // Header ของตาราง
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          'ชื่อ - นามสกุล',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              filteredStudents.isEmpty
                                  ? Container(
                                      // แสดงเมื่อไม่มีนักศึกษา
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: const Border(
                                          left: BorderSide(color: Colors.black),
                                          right: BorderSide(
                                            color: Colors.black,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'ไม่มีข้อมูลนักศึกษาที่เฝ้าระวัง',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      // แสดงข้อมูลนักศึกษา
                                      children: filteredStudents.asMap().entries.map((
                                        entry,
                                      ) {
                                        int idx = entry.key; 
                                        // ดัชนีนักศึกษา
                                        var student = entry.value; 
                                        // ข้อมูลนักศึกษา
                                        final bool isLast =
                                            idx == filteredStudents.length - 1; 
                                        // ตรวจสอบ row สุดท้าย

                                        final Color rowColor = idx % 2 == 0
                                            ? const Color(0x336D6D6D)
                                            : const Color(0x6E3F8FAF); 
                                        // สลับสี background table

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: const Border(
                                              left: BorderSide(
                                                color: Colors.black,
                                              ),
                                              right: BorderSide(
                                                color: Colors.black,
                                              ),
                                              bottom: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            borderRadius: isLast
                                                ? const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                      12,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(12),
                                                  )
                                                : null,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Center(
                                                  child: Text(
                                                    "${student['name']} ${student['lastname']}", 
                                                    // แสดงชื่อ-นามสกุล
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
                                                    "${student['absent'] ?? 0}", 
                                                    // แสดงจำนวนขาด
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
                                                    "${student['late'] ?? 0}", 
                                                    // แสดงจำนวนสาย
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
                                                    "${student['leave_count'] ?? 0}", 
                                                    // แสดงจำนวนลา
                                                    style: TextStyle(
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
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, 
                            // ใช้สีปุ่มหลัก
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () async {
                            // กดดาวน์โหลด PDF
                            try {
                              final token = await ApiService.getToken(); 
                              // ดึง token
                              final apiUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
                              final baseUrl = apiUrl.replaceAll('/api', '');
                              final url =
                                  '$baseUrl/classrooms/${widget.classroomId}/student-atrisk-pdf/$token'; 
                              // URL สำหรับดาวน์โหลด PDF
                              await downloadAndOpenPDF(
                                url,
                                fileName:
                                    'ReportBecareful_${widget.classroomId}.pdf', 
                                // ตั้งชื่อไฟล์
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('เกิดข้อผิดพลาด: $e')), 
                                // แสดง error ถ้าดาวน์โหลดล้มเหลว
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf, 
                            color: Color.fromARGB(255, 0, 0, 0), 
                          ),
                          label: const Text(
                            'ดาวน์โหลดเอกสาร (pdf.)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 14,
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
    );
  }
}