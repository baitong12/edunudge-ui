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

  final List<List<String>> attendanceData = [
    ['SA', '2', '0', '0', '0', '12.5%'],
    ['IOT', '1', '1', '0', '0', '6.25%'],
    ['Program', '0', '3', '0', '0', '0%'],
    ['Eng', '2', '0', '0', '0', '18.75%'],
    ['Calculus', '2', '0', '0', '0', '12.5%'],
    ['SW', '2', '4', '0', '0', '0%'],
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00C853),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                                        color: Colors.white))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text('มา',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text('มาสาย',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text('ขาด',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                                child: Text('ลา',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                                child: Text('รวมทั้งหมด',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ),
                        ],
                      ),
                    ),
                    ...attendanceData.asMap().entries.map((entry) {
                      int idx = entry.key;
                      List<String> val = entry.value;
                      final bool isLast = idx == attendanceData.length - 1;
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
                                flex: 2, child: Center(child: Text(val[0]))),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(val[1],
                                        style: const TextStyle(
                                            color: Colors.green)))),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(val[2],
                                        style: const TextStyle(
                                            color: Colors.orange)))),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(val[3],
                                        style: const TextStyle(
                                            color: Colors.red)))),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(val[4],
                                        style: const TextStyle(
                                            color: Colors.blue)))),
                            Expanded(
                                flex: 2, child: Center(child: Text(val[5]))),
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
                child: Text(
                  subjectDetails[selectedSubject] ?? 'ไม่มีข้อมูล',
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
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
    );
  }
}
