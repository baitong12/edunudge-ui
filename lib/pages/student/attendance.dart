import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  String selectedSubject = 'SA';

  final List<String> subjects = [
    'SA',
    'IOT',
    'Program',
    'Eng',
    'Calculus',
    'SW'
  ];

  final Map<String, String> subjectDetails = {
    'SA':
        'ชื่อวิชา: SA\nอาคารเรียน: อาคารเรียนรวม\nอาจารย์ผู้สอน: อ.สมชาย\nเบอร์ติดต่อ: 0812345678',
    'IOT':
        'ชื่อวิชา: IOT\nอาคารเรียน: อาคารวิศวกรรม\nอาจารย์ผู้สอน: อ.สมหญิง\nเบอร์ติดต่อ: 0812345679',
    'Program':
        'ชื่อวิชา: Program\nอาคารเรียน: อาคารคอมฯ\nอาจารย์ผู้สอน: อ.จิตราภรณ์\nเบอร์ติดต่อ: 0812345680',
    'Eng':
        'ชื่อวิชา: Eng\nอาคารเรียน: อาคารมนุษย์ฯ\nอาจารย์ผู้สอน: Mr. Smith\nเบอร์ติดต่อ: 0812345681',
    'Calculus':
        'ชื่อวิชา: Calculus\nอาคารเรียน: อาคารวิทยาศาสตร์\nอาจารย์ผู้สอน: อ.วิทวัส\nเบอร์ติดต่อ: 0812345682',
    'SW':
        'ชื่อวิชา: SW\nอาคารเรียน: อาคารนวัตกรรม\nอาจารย์ผู้สอน: อ.กุลธิดา\nเบอร์ติดต่อ: 0812345683',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF221B64),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          onLogoutTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้ายทั้งหมด
          children: [
            Container(
              color: Colors.white,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ชื่อวิชา')),
                  DataColumn(label: Text('มา')),
                  DataColumn(label: Text('มาสาย')),
                  DataColumn(label: Text('ขาด')),
                  DataColumn(label: Text('ลา')),
                  DataColumn(label: Text('รวมทั้งหมด')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('SA')),
                    DataCell(Text('2')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('12.5%')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('IOT')),
                    DataCell(Text('1')),
                    DataCell(Text('1')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('6.25%')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Program')),
                    DataCell(Text('0')),
                    DataCell(Text('3')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('0%')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Eng')),
                    DataCell(Text('2')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('18.75%')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Calculus')),
                    DataCell(Text('2')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('12.5%')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('SW')),
                    DataCell(Text('2')),
                    DataCell(Text('4')),
                    DataCell(Text('0')),
                    DataCell(Text('0')),
                    DataCell(Text('0%')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// ปุ่ม Dropdown ด้านซ้าย แบบปุ่ม
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSubject,
                    icon: const Icon(Icons.arrow_drop_down),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    onChanged: (String? newSubject) {
                      setState(() {
                        selectedSubject = newSubject!;
                      });
                    },
                    items: subjects.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            /// กล่องแสดงรายละเอียดวิชา
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subjectDetails[selectedSubject] ?? 'ไม่มีข้อมูล',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            /// ปุ่มดาวน์โหลด PDF
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement PDF download
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('ดาวน์โหลดเอกสาร (pdf.)'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
    );
  }
}
