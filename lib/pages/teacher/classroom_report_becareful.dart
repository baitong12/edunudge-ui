import 'package:flutter/material.dart';
import 'package:edunudge/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportBecarefulPage extends StatefulWidget {
  final int classroomId;

  const ReportBecarefulPage({super.key, required this.classroomId});

  @override
  State<ReportBecarefulPage> createState() => _ReportBecarefulPageState();
}

class _ReportBecarefulPageState extends State<ReportBecarefulPage> {
  final Color primaryColor = const Color(0xFF3F8FAF);

  List<dynamic> students = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAtRiskStudents();
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

  Future<void> _fetchAtRiskStudents() async {
    try {
      final data = await ApiService.getAtRiskStudents(widget.classroomId);
      setState(() {
        students = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("โหลดข้อมูลล้มเหลว: $e")));
    }
  }

  List<dynamic> get filteredStudents {
    if (searchQuery.isEmpty) {
      return students;
    } else {
      return students
          .where(
            (student) => "${student['name']} ${student['lastname']}"
                .toLowerCase()
                .contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 4),
                const Text(
                  'รายงานนักศึกษาที่เฝ้าระวัง',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
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
                                    ),
                                    const SizedBox(width: 8),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text:
                                                'รายชื่อนักศึกษาที่เฝ้าระวัง จำนวน ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${filteredStudents.length}',
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

                                /// ---- หัวตาราง ----
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

                                /// ---- รายการนักศึกษา ----
                                filteredStudents.isEmpty
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
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
                                        children: filteredStudents.asMap().entries.map((
                                          entry,
                                        ) {
                                          int idx = entry.key;
                                          var student = entry.value;
                                          final bool isLast =
                                              idx ==
                                              filteredStudents.length - 1;

                                          final Color rowColor = idx % 2 == 0
                                              ? const Color(0x336D6D6D)
                                              : const Color(0x6E3F8FAF);

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
                                                      bottomLeft:
                                                          Radius.circular(12),
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
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFFF0000,
                                                        ),
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
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFF18D00,
                                                        ),
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
                                                      style: TextStyle(
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),

                                const SizedBox(height: 16),

                                /// ปุ่มดาวน์โหลด PDF
                                Center(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        final token =
                                            await ApiService.getToken();
                                        final url =
                                            'http://52.63.155.211/classrooms/${widget.classroomId}/student-atrisk-pdf/$token';

                                        // เรียกฟังก์ชัน downloadAndOpenPDF แทน url_launcher
                                        await downloadAndOpenPDF(
                                          url,
                                          fileName:
                                              'ReportBecareful_${widget.classroomId}.pdf',
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('เกิดข้อผิดพลาด: $e'),
                                          ),
                                        );
                                      }
                                    },

                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.white,
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
                              ],
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
}
