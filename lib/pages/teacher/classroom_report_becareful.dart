import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';


class ReportBecarefulPage extends StatefulWidget {
  const ReportBecarefulPage({super.key});

  @override
  State<ReportBecarefulPage> createState() => _ReportBecarefulPage();
}

class _ReportBecarefulPage extends State<ReportBecarefulPage> {
  final List<Map<String, String>> students = [
    {'name': 'สมชาย ใจดี',  'absent': '2', 'late': '1'},
    {'name': 'สมหญิง แสนสุข', 'absent': '4', 'late': '0'},
    {'name': 'สมปอง สมใจ',  'absent': '0', 'late': '1'},
    {'name': 'สมทรง แก้วดี',  'absent': '3', 'late': '2'},
    {'name': 'สมฤดี เพียรดี',  'absent': '1', 'late': '1'},
    {'name': 'สมใจ วิเศษ',  'absent': '0', 'late': '0'},
    {'name': 'สมศักดิ์ ศรีสุข',  'absent': '2', 'late': '3'},
    {'name': 'สมบัติ รุ่งเรือง',  'absent': '1', 'late': '2'},
    {'name': 'สมจิตร ใจงาม',  'absent': '3', 'late': '1'},
    {'name': 'สมหมาย มั่งมี',  'absent': '2', 'late': '0'},
  ];

  String searchQuery = '';

  List<Map<String, String>> get filteredStudents {
    if (searchQuery.isEmpty) {
      return students;
    } else {
      return students
          .where((student) => student['name']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/classroom_report');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF221B64),
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          onLogoutTap: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รายงานนักศึกษาที่เฝ้าระวัง',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Colors.grey, thickness: 1.0),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 28),
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
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft, // เปลี่ยนจาก Alignment.centerRight เป็นซ้าย
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F8FAF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // PDF export
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
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
                    const SizedBox(height: 16),
                    // ตารางรายชื่อ
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
                                child: Text('ชื่อ - นามสกุล',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))),
                          ),
                          VerticalDivider(
                              width: 1, color: Colors.black, thickness: 1),
                          VerticalDivider(
                              width: 1, color: Colors.black, thickness: 1),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text('ขาด',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))),
                          ),
                          VerticalDivider(
                              width: 1, color: Colors.black, thickness: 1),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text('สาย',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))),
                          ),
                        ],
                      ),
                    ),
                    // ข้อมูลนักศึกษา
                    ...filteredStudents.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> student = entry.value;
                      final bool isLast = idx == filteredStudents.length - 1;
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text(student['name']!,
                                      style: const TextStyle(
                                          color: Colors.black))),
                            ),
                            Container(width: 1, height: 20, color: Colors.black),
                            Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(student['absent']!,
                                      style: const TextStyle(
                                          color: Color(0xFFF18D00)))),
                            ),
                            Container(width: 1, height: 20, color: Colors.black),
                            Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text(student['late']!,
                                      style: const TextStyle(
                                          color: Color(0xFFFF0000)))),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
      ),
    );
  }
}
