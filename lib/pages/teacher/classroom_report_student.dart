import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';

class StudentReportPage extends StatefulWidget {
  const StudentReportPage({super.key});

  @override
  State<StudentReportPage> createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage> {
  final List<Map<String, String>> students = [
    {'name': 'สมชาย ใจดี', 'present': '20', 'absent': '2', 'late': '1', 'leave': '1'},
    {'name': 'สมหญิง แสนสุข', 'present': '18', 'absent': '4', 'late': '0', 'leave': '2'},
    {'name': 'สมปอง สมใจ', 'present': '22', 'absent': '0', 'late': '1', 'leave': '0'},
    {'name': 'สมทรง แก้วดี', 'present': '19', 'absent': '3', 'late': '2', 'leave': '1'},
    {'name': 'สมฤดี เพียรดี', 'present': '21', 'absent': '1', 'late': '1', 'leave': '0'},
    {'name': 'สมใจ วิเศษ', 'present': '23', 'absent': '0', 'late': '0', 'leave': '0'},
    {'name': 'สมหมาย มานะ', 'present': '20', 'absent': '1', 'late': '0', 'leave': '1'},
    {'name': 'สมคิด ตั้งใจ', 'present': '17', 'absent': '5', 'late': '2', 'leave': '0'},
    {'name': 'สมจิตต์ พอใจ', 'present': '22', 'absent': '0', 'late': '0', 'leave': '0'},
    {'name': 'สมลักษณ์ สบายดี', 'present': '18', 'absent': '2', 'late': '3', 'leave': '1'},
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
    return Scaffold(
      backgroundColor: const Color(0xFF00C853), 
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
      body: Container(
        
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, 
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16), 
                      boxShadow: const [ 
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'รายงานสรุปนักศึกษาเเต่ละคน',
                            style: TextStyle(
                                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Colors.grey, thickness: 1.0), 
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.people, color: Color(0xFF3F8FAF)), 
                              const SizedBox(width: 8),
                              const Text('รายชื่อนักศึกษา',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 220,
                            height: 36,
                            child: TextField(
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                hintText: 'ค้นหา',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF3F8FAF), width: 2), 
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
                          Align(
                            alignment: Alignment.centerLeft, 
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F8FAF), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () {
                                
                              },
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                              label: const Text(
                                'ดาวน์โหลดเอกสาร (pdf.)',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
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
                                Expanded(flex: 3, child: Center(child: Text('ชื่อ - นามสกุล', style: TextStyle(fontWeight: FontWeight.bold)))),
                                VerticalDivider(width: 1, color: Colors.black, thickness: 1),
                                Expanded(flex: 1, child: Center(child: Text('มา', style: TextStyle(fontWeight: FontWeight.bold)))),
                                VerticalDivider(width: 1, color: Colors.black, thickness: 1),
                                Expanded(flex: 1, child: Center(child: Text('ขาด', style: TextStyle(fontWeight: FontWeight.bold)))),
                                VerticalDivider(width: 1, color: Colors.black, thickness: 1),
                                Expanded(flex: 1, child: Center(child: Text('สาย', style: TextStyle(fontWeight: FontWeight.bold)))),
                                VerticalDivider(width: 1, color: Colors.black, thickness: 1),
                                Expanded(flex: 1, child: Center(child: Text('ลา', style: TextStyle(fontWeight: FontWeight.bold)))),
                              ],
                            ),
                          ),
                        
                          if (filteredStudents.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text('ไม่พบข้อมูล',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                              ),
                            )
                          else
                            Column(
                              children: filteredStudents.asMap().entries.map((entry) {
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
                                      Expanded(flex: 3, child: Center(child: Text(student['name']!, style: const TextStyle(color: Colors.black)))),
                                      Container(width: 1, height: 20, color: Colors.black),
                                      Expanded(flex: 1, child: Center(child: Text(student['present']!, style: const TextStyle(color: Color(0xFF078230))))),
                                      Container(width: 1, height: 20, color: Colors.black),
                                      Expanded(flex: 1, child: Center(child: Text(student['absent']!, style: const TextStyle(color: Color(0xFFF18D00))))),
                                      Container(width: 1, height: 20, color: Colors.black),
                                      Expanded(flex: 1, child: Center(child: Text(student['late']!, style: const TextStyle(color: Color(0xFFFF0000))))),
                                      Container(width: 1, height: 20, color: Colors.black),
                                      Expanded(flex: 1, child: Center(child: Text(student['leave']!, style: const TextStyle(color: Color(0xFF8A2BE2))))),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 72), 
            ],
          ),
          bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
        ),
      ),
    );
  }
}
