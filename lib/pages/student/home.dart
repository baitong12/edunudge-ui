import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  final double come = 50.0;
  final double late = 10.25;
  final double absent = 31.25;
  final double leave = 6.25;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หัวข้อ + ปุ่มตรวจสอบ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'การเข้าเรียนเฉลี่ยทั้งหมด',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/attendance');
                      },
                      child: const Text(
                        'ตรวจสอบข้อมูลการเข้าเรียน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Pie chart
              Center(
                child: SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        _buildPieSection('มาเรียน', come, Colors.greenAccent),
                        _buildPieSection('มาสาย', late, Colors.purpleAccent),
                        _buildPieSection('ขาด', absent, Colors.pinkAccent),
                        _buildPieSection('ลา', leave, Colors.orange),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Progress bars
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressBar('มาเรียน', come, Colors.greenAccent),
                    const SizedBox(height: 16),
                    _buildProgressBar('มาสาย', late, Colors.purpleAccent),
                    const SizedBox(height: 16),
                    _buildProgressBar('ขาด', absent, Colors.pinkAccent),
                    const SizedBox(height: 16),
                    _buildProgressBar('ลา', leave, Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
    );
  }

  // Pie chart slice
  PieChartSectionData _buildPieSection(
      String title, double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(1)}%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // Progress bar item
  Widget _buildProgressBar(String label, double percent, Color color) {
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
                color: Colors.black,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(2)}%',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              height: 10,
              width: (percent / 100) * 300,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
