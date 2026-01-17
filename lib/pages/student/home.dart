import 'package:flutter/material.dart'; // นำเข้า Flutter Material Design สำหรับ widget และ UI พื้นฐาน
import 'package:fl_chart/fl_chart.dart'; // นำเข้าไลบรารีสำหรับสร้างกราฟ เช่น PieChart, LineChart
import 'package:edunudge/shared/customappbar.dart'; // นำเข้า Custom AppBar ของโปรเจกต์
import 'package:edunudge/pages/student/custombottomnav.dart'; // นำเข้า Custom Bottom Navigation ของนักเรียน
import 'package:edunudge/services/api_service.dart'; // นำเข้า service สำหรับเรียก API

class Home extends StatelessWidget { // สร้าง class Home ซึ่งเป็น StatelessWidget เพราะหน้าจอไม่ต้องการ state
  const Home({super.key}); // constructor ของ widget พร้อม key สำหรับระบุ widget

  @override
  Widget build(BuildContext context) { // ฟังก์ชัน build สำหรับสร้าง UI ของ widget
    return Scaffold( // Scaffold คือโครงสร้างหลักของหน้า UI มี AppBar, Body, BottomNavigationBar
      backgroundColor: Colors.white, // ตั้งพื้นหลังของหน้าเป็นสีขาว
      appBar: PreferredSize( // ใช้ PreferredSize เพื่อกำหนดความสูงของ AppBar
        preferredSize: const Size.fromHeight(80), // กำหนดความสูงของ AppBar เป็น 80
        child: CustomAppBar( // ใช้ CustomAppBar ที่นำเข้ามา
          onProfileTap: () { // กำหนดฟังก์ชันเมื่อกดปุ่มโปรไฟล์
            Navigator.pushNamed(context, '/profile'); // ไปหน้าสำหรับโปรไฟล์
          },
          onLogoutTap: () { // กำหนดฟังก์ชันเมื่อกดปุ่มออกจากระบบ
            Navigator.pushNamedAndRemoveUntil( // ลบ stack ของหน้าเก่าแล้วไปหน้า login
              context,
              '/login',
              (route) => false, // เงื่อนไขให้ลบ route ทั้งหมด
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>( // ใช้ FutureBuilder เพื่อรอผลลัพธ์จาก API
        future: ApiService.getStudentHome(), // เรียก API getStudentHome()
        builder: (context, snapshot) { // builder สำหรับสร้าง UI ตามสถานะของ snapshot
          if (snapshot.connectionState == ConnectionState.waiting) { // ถ้า API ยังโหลดอยู่
            return const Center(child: CircularProgressIndicator()); // แสดงวงกลมโหลด
          } else if (snapshot.hasError) { // ถ้าเกิดข้อผิดพลาด
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}')); // แสดงข้อความ error
          } else if (!snapshot.hasData) { // ถ้าไม่มีข้อมูล
            return const Center(child: Text('ไม่มีข้อมูล')); // แสดงข้อความว่าไม่มีข้อมูล
          } else { // ถ้ามีข้อมูลเรียบร้อย
            final homeData = snapshot.data!; // ดึงข้อมูลออกจาก snapshot
            final double come =
                double.tryParse(homeData['present']?.toString() ?? '0') ?? 0.0; // แปลงค่า present เป็น double
            final double late =
                double.tryParse(homeData['late']?.toString() ?? '0') ?? 0.0; // แปลงค่า late เป็น double
            final double absent =
                double.tryParse(homeData['absent']?.toString() ?? '0') ?? 0.0; // แปลงค่า absent เป็น double
            final double leave =
                double.tryParse(homeData['leave']?.toString() ?? '0') ?? 0.0; // แปลงค่า leave เป็น double

            return SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อให้เลื่อนหน้าจอได้
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // กำหนด padding รอบๆ
              child: Column( // วาง widget เป็นแนวตั้ง
                crossAxisAlignment: CrossAxisAlignment.start, // จัด widget เริ่มจากซ้าย
                children: [
                  const Text( // แสดงข้อความหัวข้อ
                    'การเข้าเรียนเฉลี่ยทั้งหมด',
                    style: TextStyle( // กำหนด style ของข้อความ
                      color: Colors.black87, // สีข้อความดำเข้ม
                      fontSize: 16, // ขนาดฟอนต์ 16
                      fontWeight: FontWeight.bold, // ตัวหนา
                    ),
                  ),
                  const SizedBox(height: 20), // เว้นระยะห่างแนวตั้ง 20
                  Center( // จัด widget ให้อยู่ตรงกลาง
                    child: Container( // กล่องสำหรับกราฟ
                      padding: const EdgeInsets.all(16.0), // กำหนด padding รอบกล่อง
                      decoration: BoxDecoration( // ตกแต่งกล่อง
                        color: const Color(0xFF00B894).withOpacity(0.1), // พื้นหลังสีเขียวอ่อนใส
                        borderRadius: BorderRadius.circular(20), // มุมกล่องโค้ง 20
                        border: Border.all( // เส้นขอบกล่อง
                          color: const Color(0xFF00B894), // สีเส้นขอบ
                          width: 2, // ความหนาเส้นขอบ 2
                        ),
                        boxShadow: [ // เงากล่อง
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // สีเงา
                            spreadRadius: 2, // ระยะเงากระจาย
                            blurRadius: 8, // ความฟุ้งของเงา
                            offset: const Offset(0, 4), // ตำแหน่งเงา
                          ),
                        ],
                      ),
                      height: 250, // ความสูงของกล่อง
                      child: PieChart( // ใช้ PieChart จาก fl_chart
                        PieChartData( // กำหนดข้อมูล PieChart
                          sectionsSpace: 4, // ช่องว่างระหว่าง section
                          centerSpaceRadius: 50, // ขนาดวงกลมตรงกลาง
                          sections: [ // section ของกราฟ
                            _buildPieSection('มาเรียน', come, const Color(0xFF1DE9B6)), // section มาเรียน
                            _buildPieSection('มาสาย', late, const Color(0xFFFFAB40)), // section มาสาย
                            _buildPieSection('ขาด', absent, const Color(0xFFFF4081)), // section ขาด
                            _buildPieSection(
                                'ลา', leave, const Color.fromARGB(255, 72, 188, 255)), // section ลา
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // เว้นระยะห่างแนวตั้ง 20
                  Container( // กล่องแสดง progress bar
                    decoration: BoxDecoration( // ตกแต่งกล่อง
                      color: const Color(0xFF00B894).withOpacity(0.1), // พื้นหลังสีเขียวอ่อนใส
                      borderRadius: BorderRadius.circular(20), // มุมกล่องโค้ง
                      border: Border.all( // เส้นขอบกล่อง
                        color: const Color(0xFF00B894),
                        width: 2,
                      ),
                      boxShadow: [ // เงากล่อง
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20), // กำหนด padding ภายในกล่อง
                    child: Column( // วาง progress bar เป็นแนวตั้ง
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressBar(context, 'มาเรียน', come, const Color(0xFF1DE9B6)), // progress bar มาเรียน
                        const SizedBox(height: 16),
                        _buildProgressBar(context, 'มาสาย', late, const Color(0xFFFFAB40)), // progress bar มาสาย
                        const SizedBox(height: 16),
                        _buildProgressBar(context, 'ขาด', absent, const Color(0xFFFF4081)), // progress bar ขาด
                        const SizedBox(height: 16),
                        _buildProgressBar(
                            context, 'ลา', leave, const Color.fromARGB(255, 72, 188, 255)), // progress bar ลา
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), // เว้นระยะห่าง 30
                  Center( // จัดปุ่มตรงกลาง
                    child: ElevatedButton( // ปุ่ม ElevatedButton
                      style: ElevatedButton.styleFrom( // กำหนด style ของปุ่ม
                        backgroundColor: const Color(0xFFFFEAA7), // สีพื้นหลังปุ่ม
                        foregroundColor: Colors.black, // สีข้อความปุ่ม
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14), // padding ของปุ่ม
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // มุมโค้งของปุ่ม
                        ),
                        elevation: 4, // ความสูงเงาของปุ่ม
                        shadowColor: Colors.black.withOpacity(0.2), // สีเงาปุ่ม
                      ),
                      onPressed: () { // เมื่อกดปุ่ม
                        Navigator.pushNamed(context, '/attendance'); // ไปหน้าตรวจสอบข้อมูลการเข้าเรียน
                      },
                      child: const Text(
                        'ตรวจสอบข้อมูลการเข้าเรียน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNav( // ใช้ Custom Bottom Navigation
        currentIndex: 0, // ตั้งค่า index ปัจจุบัน
        context: context, // ส่ง context ให้ navigation
      ),
    );
  }

  PieChartSectionData _buildPieSection(String title, double value, Color color) { // ฟังก์ชันสร้าง section ของ PieChart
    return PieChartSectionData(
      color: color, // สีของ section
      value: value, // ค่าของ section
      title: '${value.toStringAsFixed(2)}%', // ข้อความแสดงค่า %
      radius: 65, // รัศมีของ section
      titleStyle: const TextStyle( // Style ของข้อความ
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)], // เงาของข้อความ
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double percent, Color color) { // ฟังก์ชันสร้าง progress bar
    final width = MediaQuery.of(context).size.width * 0.8; // กำหนดความกว้าง progress bar เป็น 80% ของหน้าจอ
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // จัด widget เริ่มจากซ้าย
      children: [
        Row( // แสดง label และค่าร้อยละ
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // จัดซ้ายขวา
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)), // ชื่อ label
            Text('${percent.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 16, color: Colors.white)), // ค่า %
          ],
        ),
        const SizedBox(height: 8), // เว้นระยะห่าง 8
        Stack( // ใช้ Stack วาง progress bar ซ้อนกัน
          children: [
            Container( // background bar
              height: 10, // ความสูง 10
              width: width, // ความกว้างตาม screen
              decoration: BoxDecoration(
                color: color.withOpacity(0.3), // สีอ่อน
                borderRadius: BorderRadius.circular(5), // มุมโค้ง
                border: Border.all(
                  color: const Color(0xFF00B894), // ขอบ bar
                  width: 1,
                ),
              ),
            ),
            Container( // foreground bar
              height: 10,
              width: (percent / 100) * width, // ความยาวตามค่า %
              decoration: BoxDecoration(
                color: color, // สีเต็ม
                borderRadius: BorderRadius.circular(5),
                boxShadow: [ // เงา bar
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
