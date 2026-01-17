import 'package:flutter/material.dart';
//  นำเข้า Flutter Material library สำหรับ UI พื้นฐาน เช่น Scaffold, Text, Icon, ListView

import 'package:edunudge/pages/teacher/custombottomnav.dart';
//  นำเข้าไฟล์ custombottomnav.dart (เมนูนำทางด้านล่างของอาจารย์)

import 'package:edunudge/shared/customappbar.dart';
//  นำเข้าไฟล์ customappbar.dart (AppBar แบบกำหนดเอง ใช้ปุ่มโปรไฟล์และ logout)

import 'package:edunudge/services/api_service.dart';
//  นำเข้า ApiService สำหรับเรียก API ไปดึงข้อมูลห้องเรียนของอาจารย์

// ====================== WIDGET หลัก ======================
class HomePage extends StatefulWidget {
  const HomePage({super.key}); 
  //  สร้าง StatefulWidget เพราะข้อมูลต้องดึงจาก API และสามารถเปลี่ยนได้ (reload)

  @override
  State<HomePage> createState() => _HomePageState();
}

// ====================== STATE ======================
class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _teacherHome;
  //  Future เก็บข้อมูล API ที่ดึงมาจาก getTeacherHome (เป็น Map มี key เช่น classrooms)

  @override
  void initState() {
    super.initState();
    _teacherHome = ApiService.getTeacherHome(); 
    //  ตอนเริ่มต้นหน้าจอ ให้โหลดข้อมูลห้องเรียนจาก API
  }

  Future<void> _reloadTeacherHome() async {
    //  ฟังก์ชันไว้ reload ข้อมูลใหม่ (ตอนกลับมาจากหน้ารายละเอียด)
    setState(() {
      _teacherHome = ApiService.getTeacherHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    //  ดึงขนาดจอเพื่อทำ responsive

    //  ฟังก์ชันแปลงขนาดให้ responsive ตามขนาดหน้าจอ
    double scaleWidth(double value) => value * screenWidth / 375;
    double scaleHeight(double value) => value * screenHeight / 812;

    final cardColors = [
      const Color(0xFF91C8E4), 
      //  สีพื้นหลังการ์ด (สามารถเพิ่มหลายสีได้)
    ];

    return Scaffold(
      backgroundColor: Colors.white, //  สีพื้นหลังของหน้าหลัก

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(scaleHeight(70)), 
        //  กำหนดความสูง AppBar ให้ responsive
        child: CustomAppBar(
          onProfileTap: () => Navigator.pushNamed(context, '/profile'), 
          //  กดที่ปุ่มโปรไฟล์ -> ไปหน้าโปรไฟล์

          onLogoutTap: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (r) => false,
          ), 
          //  กด logout -> ไปหน้า login และลบ stack ทั้งหมด
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _teacherHome, 
        //  ใช้ FutureBuilder เพื่อรอข้อมูลจาก API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //  ระหว่างโหลดข้อมูล แสดงวงกลมโหลด
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            //  ถ้ามี error จาก API แสดงข้อความ error
            return Center(
              child: Text(
                "เกิดข้อผิดพลาด: ${snapshot.error}",
                style: TextStyle(color: Colors.red, fontSize: scaleWidth(14)),
              ),
            );
          } else if (!snapshot.hasData ||
              (snapshot.data?['classrooms'] == null) ||
              (snapshot.data?['classrooms'] as List).isEmpty) {
            //  ถ้าไม่มีข้อมูล หรือ classrooms เป็น null / ว่าง
            return Center(
              child: Text(
                "ไม่พบห้องเรียน กรุณาสร้างห้องเรียน",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: scaleWidth(16),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          //  ดึงข้อมูล classrooms ออกมาใช้งาน
          final classrooms = snapshot.data!['classrooms'] as List;

          return ListView.builder(
            //  สร้าง ListView สำหรับแสดงห้องเรียนทั้งหมด
            padding: EdgeInsets.symmetric(
              horizontal: scaleWidth(12),
              vertical: scaleHeight(10),
            ),
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classroom = classrooms[index]; 
              final color = cardColors[index % cardColors.length];
              //  เลือกสีการ์ดจากลิสต์ (วนซ้ำถ้าสีไม่พอ)

              return Padding(
                padding: EdgeInsets.only(bottom: scaleHeight(12)),
                child: Hero(
                  tag: classroom['name_subject'] ?? 'subject_$index',
                  //  ใช้ Hero Animation เวลาเปลี่ยนหน้า

                  child: InkWell(
                    borderRadius: BorderRadius.circular(scaleWidth(12)),
                    onTap: () async {
                      //  เมื่อกดการ์ด -> ไปหน้า classroom_subject
                      final result = await Navigator.pushNamed(
                        context,
                        '/classroom_subject',
                        arguments: classroom['id'],
                      );
                      if (result == true) {
                        //  ถ้ากลับมาแล้วมีการแก้ไข -> reload ข้อมูลใหม่
                        _reloadTeacherHome();
                      }
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: color, 
                        borderRadius: BorderRadius.circular(scaleWidth(12)),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: EdgeInsets.all(scaleWidth(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ================== แถวที่ 1: ชื่อวิชา ==================
                            Row(
                              children: [
                                Icon(
                                  Icons.class_,
                                  color: Colors.white,
                                  size: scaleWidth(24),
                                ),
                                SizedBox(width: scaleWidth(8)),
                                Expanded(
                                  child: Text(
                                    classroom['name_subject'] ?? 'ไม่ระบุชื่อวิชา',
                                    style: TextStyle(
                                      fontSize: scaleWidth(16),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: scaleHeight(8)),

                            // ================== แถวที่ 2: ห้องเรียน + รหัสเข้าชั้นเรียน ==================
                            Row(
                              children: [
                                Icon(Icons.meeting_room, size: scaleWidth(18), color: Colors.white),
                                SizedBox(width: scaleWidth(4)),
                                Text(
                                  classroom['room_number'] ?? '-',
                                  style: TextStyle(
                                    fontSize: scaleWidth(12),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: scaleWidth(12)),
                                Icon(Icons.vpn_key, size: scaleWidth(18), color: Colors.white),
                                SizedBox(width: scaleWidth(4)),
                                Text(
                                  classroom['code'] ?? '-',
                                  style: TextStyle(
                                    fontSize: scaleWidth(12),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: scaleHeight(8)),

                            // ================== แถวที่ 3: ชื่ออาจารย์ ==================
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.white70, size: scaleWidth(16)),
                                SizedBox(width: scaleWidth(4)),
                                Expanded(
                                  child: Text(
                                    classroom['teachers'] ?? 'อาจารย์ไม่ระบุ',
                                    style: TextStyle(
                                      fontSize: scaleWidth(12),
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
      //  แสดง Bottom Navigation Bar ของอาจารย์ (currentIndex = 0 = หน้าแรก)
    );
  }
}
