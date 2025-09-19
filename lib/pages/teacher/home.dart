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

  Future<void> _reloadTeacherHome() async {
    setState(() {
      _teacherHome = ApiService.getTeacherHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    double scaleWidth(double value) => value * screenWidth / 375;
    double scaleHeight(double value) => value * screenHeight / 812;

    final cardColors = [
      const Color(0xFF91C8E4),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(scaleHeight(70)),
        child: CustomAppBar(
          onProfileTap: () => Navigator.pushNamed(context, '/profile'),
          onLogoutTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (r) => false,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _teacherHome,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "เกิดข้อผิดพลาด: ${snapshot.error}",
                style: TextStyle(color: Colors.red, fontSize: scaleWidth(14)),
              ),
            );
          } else if (!snapshot.hasData ||
              (snapshot.data?['classrooms'] == null) ||
              (snapshot.data?['classrooms'] as List).isEmpty) {
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

          final classrooms = snapshot.data!['classrooms'] as List;

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: scaleWidth(12),
              vertical: scaleHeight(10),
            ),
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classroom = classrooms[index];
              final color = cardColors[index % cardColors.length];

              return Padding(
                padding: EdgeInsets.only(bottom: scaleHeight(12)),
                child: Hero(
                  tag: classroom['name_subject'] ?? 'subject_$index',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(scaleWidth(12)),
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/classroom_subject',
                        arguments: classroom['id'],
                      );
                      if (result == true) {
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
    );
  }
}
