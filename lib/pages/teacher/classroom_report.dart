import 'package:flutter/material.dart';                  // ใช้ widget UI พื้นฐานของ Flutter
import 'package:edunudge/services/api_service.dart';     // เรียกใช้งาน API ที่สร้างไว้ในโปรเจ็กต์

class ReportMenuPage extends StatelessWidget {           // สร้างหน้าเมนูรายงาน เป็น Stateless เพราะไม่มี state ภายใน
  final int classroomId;                                 // เก็บ id ห้องเรียนที่จะใช้สำหรับโหลดรายงาน

  const ReportMenuPage({Key? key, required this.classroomId}) : super(key: key); // constructor รับ classroomId

  @override
  Widget build(BuildContext context) {
    return WillPopScope(                                 // ควบคุมพฤติกรรมเมื่อกดปุ่มย้อนกลับ (Back)
      onWillPop: () async {                              // ฟังก์ชันทำงานเมื่อกดย้อนกลับ
        Navigator.pop(context);                          // กลับหน้าก่อนหน้า
        return false;                                    // ไม่ให้ระบบ pop ซ้ำอีก
      },
      child: Scaffold(                                   // Scaffold โครงสร้างหลักของหน้า
        backgroundColor: const Color(0xFF91C8E4),        // กำหนดสีพื้นหลัง
        appBar: AppBar(                                  // ส่วนหัว AppBar
          backgroundColor: const Color(0xFF91C8E4),      // สีพื้นหลัง AppBar
          elevation: 0,                                  // ยกเลิกเงา
          title: const Text(                             // ข้อความหัวเรื่อง
            'ข้อมูลการเข้าเรียน',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(                           // ปุ่มย้อนกลับทางซ้าย
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);                    // กลับไปหน้าก่อนหน้า
            },
          ),
        ),
        body: Container(                                 // ส่วนเนื้อหาของหน้า
          decoration: const BoxDecoration(               // ใส่พื้นหลังแบบ gradient
            gradient: LinearGradient(
              colors: [Color(0xFF91C8E4), Color(0xFF91C8E4)], // จริง ๆ ใช้สีเดียวทั้งสองฝั่ง
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(                               // ซ้อน Scaffold อีกชั้น (background โปร่งใส)
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(16),         // ระยะห่างรอบนอก
              child: Container(                          // กล่องเนื้อหา
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(               // ตกแต่งกล่อง
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(                           // ใส่เงา
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: Column(                           // จัดเรียง widget แบบ column
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),          // เว้นระยะห่าง
                    Expanded(                            // ขยายเต็มพื้นที่ที่เหลือ
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.count(         // ใช้ GridView สำหรับวางปุ่มรายงาน
                            shrinkWrap: true,            // ให้ GridView ใช้พื้นที่เท่าที่จำเป็น
                            crossAxisCount: 1,           // มีแค่ 1 คอลัมน์ (ปุ่มเรียงลงมา)
                            mainAxisSpacing: 20,         // ระยะห่างระหว่างปุ่ม
                            childAspectRatio: 3.0,       // อัตราส่วนความกว้าง:สูง ของปุ่ม
                            physics: const NeverScrollableScrollPhysics(), // ไม่ให้เลื่อน
                            children: [
                              _buildReportButton(        // ปุ่มรายงานสรุปรวมรายสัปดาห์
                                context,
                                label: 'รายงานสรุปรวมรายสัปดาห์',
                                icon: Icons.insert_chart_outlined_rounded,
                                color: Colors.green.shade700,
                                route: '/classroom_report_summarize',
                              ),
                              _buildReportButton(        // ปุ่มรายงานนักศึกษาที่เฝ้าระวัง
                                context,
                                label: 'รายงานนักศึกษาที่เฝ้าระวัง',
                                icon: Icons.warning_amber_rounded,
                                color: Colors.orange.shade600,
                                route: '/classroom_report_becareful',
                              ),
                              _buildReportButton(        // ปุ่มรายงานสรุปนักศึกษาแต่ละคน
                                context,
                                label: 'รายงานสรุปนักศึกษาเเต่ละคน',
                                icon: Icons.person_search_rounded,
                                color: Colors.blue.shade700,
                                route: '/classroom_report_student',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างปุ่มรายงานแต่ละอัน
  Widget _buildReportButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required String route}) {
    return GestureDetector(                              // ใช้ GestureDetector จับการแตะ
      onTap: () async {
        if (route == '/classroom_report_summarize') {    // ถ้าเป็นปุ่มรายงานสรุปรวม
          try {
            final atRiskData = await ApiService.getAtRiskStudents(classroomId); // เรียก API ดึงนักศึกษาที่เสี่ยง
            final atRiskList = atRiskData
                .map<String>((s) => "${s['name']} ${s['lastname']}") // รวมชื่อ-นามสกุล
                .toList();

            Navigator.pushNamed(                         // ไปยังหน้ารายงาน พร้อมส่ง arguments
              context,
              route,
              arguments: {
                'classroomId': classroomId,
                'atRiskList': atRiskList,
              },
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(  // ถ้า error แสดง SnackBar
              SnackBar(content: Text('โหลดข้อมูลล้มเหลว: $e')),
            );
          }
        } else {                                         // ถ้าเป็นปุ่มรายงานอื่น ๆ
          Navigator.pushNamed(context, route, arguments: classroomId);
        }
      },
      child: Container(                                  // กล่องปุ่ม
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),                // พื้นหลังโปร่งนิดหน่อยตามสีหลัก
          border: Border.all(color: color),              // เส้นขอบตามสีหลัก
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 40),          // ไอคอนปุ่ม
            const SizedBox(width: 20),                   // เว้นช่องว่าง
            Expanded(
              child: Text(                               // ข้อความปุ่ม
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
