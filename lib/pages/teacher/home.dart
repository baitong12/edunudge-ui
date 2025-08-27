import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _teacherHome;

  @override
  void initState() {
    super.initState();
    _teacherHome = ApiService.getTeacherHome();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardColors = [
      const Color(0xFF1de9b6),
      const Color(0xFFe040fb),
      const Color(0xFFff4081),
      const Color(0xFFffab40),
      const Color(0xFF2979ff),
      const Color(0xFF7c4dff),
      const Color(0xFF00c853),
      const Color(0xFFff1744),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF00C853),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () => Navigator.pushNamed(context, '/profile'),
          onLogoutTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (r) => false,
          ),
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: _teacherHome,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "เกิดข้อผิดพลาด: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData ||
                (snapshot.data?['classrooms'] == null) ||
                (snapshot.data?['classrooms'] is List && (snapshot.data?['classrooms'] as List).isEmpty)) {
              return const Center(
                child: Text(
                  "ไม่พบห้องเรียน กรุณาสร้างห้องเรียน",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final classrooms = snapshot.data!['classrooms'] as List;

            return ListView.builder(
              padding: EdgeInsets.only(
                top: screenHeight * 0.02,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                bottom: screenHeight * 0.12,
              ),
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                final classroom = classrooms[index];
                final color = cardColors[index % cardColors.length];

                return Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                  child: Hero(
                    tag: classroom['name_subject'] ?? 'subject_$index',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      onTap: () {
                        print('Go to classroom_subject id=${classroom['id']} (${classroom['id'].runtimeType})');
                        Navigator.pushNamed(
                          context,
                          '/classroom_subject',
                          arguments: classroom['id'],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(screenWidth * 0.06),
                          border: Border.all(color: Colors.white, width: 1.5), // เพิ่มบรรทัดนี้
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // หัวการ์ด (ชื่อวิชา)
                              Row(
                                children: [
                                  Icon(
                                    Icons.class_,
                                    color: Colors.white,
                                    size: screenWidth * 0.08,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Text(
                                      classroom['name_subject'] ??
                                          'ไม่ระบุชื่อวิชา',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.055,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.015),

                              // แทนที่ด้วยแบบ Row เหมือน classroom.dart
                              Row(
                                children: [
                                  Icon(Icons.meeting_room,
                                      size: screenWidth * 0.05,
                                      color: Colors.white),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    classroom['room_number'] ?? '-',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.05),
                                  Icon(Icons.vpn_key,
                                      size: screenWidth * 0.05,
                                      color: Colors.white),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    classroom['code'] ?? '-',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.015),

                              // ชื่อครู
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: Colors.white70, size: 20),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      classroom['teachers'] ?? 'อาจารย์ไม่ระบุ',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.white,
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
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
    );
  }
}
