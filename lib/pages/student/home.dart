import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:edunudge/services/api_service.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          onLogoutTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getStudentHome(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('ไม่มีข้อมูล'));
          } else {
            final homeData = snapshot.data!;
            final double come =
                double.tryParse(homeData['present']?.toString() ?? '0') ?? 0.0;
            final double late =
                double.tryParse(homeData['late']?.toString() ?? '0') ?? 0.0;
            final double absent =
                double.tryParse(homeData['absent']?.toString() ?? '0') ?? 0.0;
            final double leave =
                double.tryParse(homeData['leave']?.toString() ?? '0') ?? 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'การเข้าเรียนเฉลี่ยทั้งหมด',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00B894), // ขอบสีเขียวมิ้นท์
                          width: 2,
                        ),
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
                          centerSpaceRadius: 50,
                          sections: [
                            _buildPieSection('มาเรียน', come, const Color(0xFF1DE9B6)),
                            _buildPieSection('มาสาย', late, const Color(0xFFFFAB40)),
                            _buildPieSection('ขาด', absent, const Color(0xFFFF4081)),
                            _buildPieSection(
                                'ลา', leave, const Color.fromARGB(255, 72, 188, 255)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00B894), // ขอบสีเขียวมิ้นท์
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressBar(context, 'มาเรียน', come, const Color(0xFF1DE9B6)),
                        const SizedBox(height: 16),
                        _buildProgressBar(context, 'มาสาย', late, const Color(0xFFFFAB40)),
                        const SizedBox(height: 16),
                        _buildProgressBar(context, 'ขาด', absent, const Color(0xFFFF4081)),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                            context, 'ลา', leave, const Color.fromARGB(255, 72, 188, 255)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEAA7),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          // ขอบปุ่มถูกลบออก
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/attendance');
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
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        context: context,
      ),
    );
  }

  PieChartSectionData _buildPieSection(String title, double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(2)}%',
      radius: 65,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double percent, Color color) {
    final width = MediaQuery.of(context).size.width * 0.8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            Text('${percent.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: width,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFF00B894), // ขอบสีเขียวมิ้นท์
                  width: 1,
                ),
              ),
            ),
            Container(
              height: 10,
              width: (percent / 100) * width,
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
