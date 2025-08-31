import 'package:flutter/material.dart';

class ReportMenuPage extends StatelessWidget {
  final int classroomId;

  const ReportMenuPage({Key? key, required this.classroomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF00C853),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'ข้อมูลการเข้าชั้นเรียน',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 1,
                            mainAxisSpacing: 20,
                            childAspectRatio: 3.0,
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
                  ],
                ),
              ),
            ),
          ),
        ),
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
        Navigator.pushNamed(context, route, arguments: classroomId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
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
