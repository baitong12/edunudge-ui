import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';

class ReportMenuPage extends StatelessWidget {
  const ReportMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/classroom_subject');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF221B64),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: CustomAppBar(
            onProfileTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            onLogoutTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20), // ✅ ไม่เปลี่ยนขนาด padding ของกรอบขาว
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลการเข้าชั้นเรียน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 24, color: Colors.grey, thickness: 1.0),
                const SizedBox(height: 16), // ✅ เพิ่มระยะห่างระหว่าง Divider กับปุ่ม
                Expanded( // ✅ ทำให้ช่องปุ่มขยายได้ และควบคุมระยะด้านล่าง
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4), // ✅ ลดช่องว่างด้านล่างสุด
                      child: SizedBox(
                        width: 320,
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 1,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3.5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildReportButton(
                              context,
                              label: 'รายงานสรุปรวม',
                              icon: Icons.insert_chart_outlined_rounded,
                              color: Colors.green.shade700,
                              route: '/classroom_report_summarize',
                            ),
                            _buildReportButton(
                              context,
                              label: 'นักเรียนที่เฝ้าระวัง',
                              icon: Icons.warning_amber_rounded,
                              color: Colors.orange.shade600,
                              route: '/classroom_report_becareful',
                            ),
                            _buildReportButton(
                              context,
                              label: 'สรุปนักเรียนแต่ละคน',
                              icon: Icons.person_search_rounded,
                              color: Colors.blue.shade700,
                              route: '/classroom_report_student',
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required String route}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
