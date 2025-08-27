import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:edunudge/services/api_service.dart'; // import ApiService

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          body: FutureBuilder<Map<String, dynamic>>(
            future: ApiService.getStudentHome(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('ไม่มีข้อมูล'));
              } else {
                final homeData = snapshot.data!;

                // แปลงค่า String เป็น double
                final double come =
                    double.tryParse(homeData['present']?.toString() ?? '0') ??
                        0.0;
                final double late =
                    double.tryParse(homeData['late']?.toString() ?? '0') ??
                        0.0;
                final double absent =
                    double.tryParse(homeData['absent']?.toString() ?? '0') ??
                        0.0;
                final double leave =
                    double.tryParse(homeData['leave']?.toString() ?? '0') ??
                        0.0;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'การเข้าเรียนเฉลี่ยทั้งหมด',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 1, 150, 63),
                                    Color.fromARGB(255, 1, 150, 63)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/attendance');
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'ตรวจสอบข้อมูลการเข้าเรียน',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            height: 250,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 45,
                                sections: [
                                  _buildPieSection(
                                      'มาเรียน', come, const Color(0xFF1de9b6)),
                                  _buildPieSection(
                                      'มาสาย', late, const Color(0xFFe040fb)),
                                  _buildPieSection(
                                      'ขาด', absent, const Color(0xFFff4081)),
                                  _buildPieSection(
                                      'ลา', leave, const Color(0xFFffab40)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProgressBar(
                                  context, 'มาเรียน', come, const Color(0xFF1de9b6)),
                              const SizedBox(height: 16),
                              _buildProgressBar(
                                  context, 'มาสาย', late, const Color(0xFFe040fb)),
                              const SizedBox(height: 16),
                              _buildProgressBar(
                                  context, 'ขาด', absent, const Color(0xFFff4081)),
                              const SizedBox(height: 16),
                              _buildProgressBar(
                                  context, 'ลา', leave, const Color(0xFFffab40)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          bottomNavigationBar:
              CustomBottomNav(currentIndex: 0, context: context),
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(
      String title, double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(2)}%',
      radius: 65,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black,
            blurRadius: 2,
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(2)}%',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              height: 10,
              width: (percent / 100) * MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
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
