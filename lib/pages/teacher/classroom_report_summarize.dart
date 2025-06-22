import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:pie_chart/pie_chart.dart' as pc;

class ReportBsummarizePage extends StatefulWidget {
  const ReportBsummarizePage({super.key});

  @override
  State<ReportBsummarizePage> createState() => _ReportBsummarizePageState();
}

class _ReportBsummarizePageState extends State<ReportBsummarizePage> {
  final List<double> weeklyData = [
    4, 6, 5, 8, 7, 3, 9, 4, 6, 5, 7, 6, 5, 4, 6, 8
  ];
  Set<int> selectedWeeks = {};
  final ScrollController _chipScrollController = ScrollController();

  void _scrollToCenter(int index) {
    // ขนาดของแต่ละ chip + spacing
    const chipWidth = 80.0; // ปรับให้กระชับขึ้น
    const spacing = 8.0;
    final totalChipWidth = chipWidth + spacing;

    // ขนาดกรอบขาว (Container) ที่ห่อ ListView
    final containerWidth = 950.0 - 16.0; // กว้างกรอบขาว - padding

    // ตำแหน่งที่ต้องการเลื่อน
    final targetOffset = (index * totalChipWidth) - (containerWidth / 2) + (chipWidth / 2);

    // ตรวจสอบว่าขนาดรวมของ chip มากกว่ากรอบหรือไม่
    final totalWidth = (16 * totalChipWidth);
    if (totalWidth > containerWidth) {
      _chipScrollController.animateTo(
        targetOffset.clamp(
          _chipScrollController.position.minScrollExtent,
          _chipScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/classroom_report');
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonHeight = 64.0;
              final containerHeight = constraints.maxHeight - buttonHeight - 16;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: containerHeight,
                  ),
                  child: Container(
                    width: double.infinity,
                    // height: containerHeight, // ลบหรือคอมเมนต์บรรทัดนี้ออก
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'รายงานสรุปรวม',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Colors.grey, thickness: 1.0),
                          const SizedBox(height: 12),
                          // ปุ่มดาวน์โหลดชิดขวา อยู่บนกราฟ
                          Align(
                            alignment: Alignment.centerLeft, // เปลี่ยนจาก Alignment.centerRight เป็นซ้าย
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F8FAF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 2,
                              ),
                              onPressed: () {
                                // TODO: ใส่ฟังก์ชันดาวน์โหลด pdf ที่นี่
                              },
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                              label: const Text(
                                'ดาวน์โหลดเอกสาร (pdf.)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 320, // หรือกำหนดความสูงที่เหมาะสม
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width: (selectedWeeks.isEmpty ? 16 : selectedWeeks.length) * 70.0,
                                  height: 300, // ปรับความสูงตามต้องการ
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: BarChart(
                                    BarChartData(
                                      maxY: 12,
                                      barTouchData: BarTouchData(
                                        enabled: false,
                                      ),
                                      barGroups: selectedWeeks.isEmpty
                                          ? List.generate(16, (index) => BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: weeklyData[index],
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF3F8FAF), Color(0xFF62B7C7)],
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                  width: 38,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ],
                                            ))
                                          : selectedWeeks.map((week) => BarChartGroupData(
                                              x: week,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: weeklyData[week],
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF3F8FAF), Color(0xFF62B7C7)],
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                  width: 38,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ],
                                            )).toList(),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              if (selectedWeeks.isEmpty || selectedWeeks.contains(value.toInt())) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Transform.rotate(
                                                    angle: -1.57,
                                                    child: Text(
                                                      'สัปดาห์ ${value.toInt() + 1}',
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                            reservedSize: 60,
                                            interval: 1,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      gridData: FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      alignment: BarChartAlignment.center,
                                      groupsSpace: 16, // ปรับระยะห่างให้กราฟใกล้กันมากขึ้น
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ปุ่มเลือกสัปดาห์แบบเลื่อนได้
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: SizedBox(
                                height: 40,
                                width: 950 - 16, // ให้เท่ากับกรอบขาวด้านใน
                                child: ListView.separated(
                                  controller: _chipScrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 17, // 1 ปุ่ม "ทั้งหมด" + 16 สัปดาห์
                                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      // ปุ่ม "ทั้งหมด"
                                      return FilterChip(
                                        label: const Text(
                                          'ทั้งหมด',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        selected: selectedWeeks.isEmpty,
                                        onSelected: (selected) {
                                          setState(() {
                                            selectedWeeks.clear();
                                            _scrollToCenter(0);
                                          });
                                        },
                                        selectedColor: const Color(0xFF3F8FAF),
                                        backgroundColor: Colors.grey.shade400,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: selectedWeeks.isEmpty
                                                ? const Color(0xFF3F8FAF)
                                                : Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                        ),
                                        elevation: selectedWeeks.isEmpty ? 4 : 1,
                                        showCheckmark: false,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      );
                                    } else {
                                      final weekIndex = index - 1;
                                      return FilterChip(
                                        label: Text(
                                          'สัปดาห์ ${weekIndex + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: selectedWeeks.contains(weekIndex) ? Colors.white : const Color(0xFF3F8FAF),
                                          ),
                                        ),
                                        selected: selectedWeeks.contains(weekIndex),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedWeeks.add(weekIndex);
                                              _scrollToCenter(index);
                                            } else {
                                              selectedWeeks.remove(weekIndex);
                                            }
                                          });
                                        },
                                        selectedColor: const Color(0xFF3F8FAF),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: selectedWeeks.contains(weekIndex)
                                                ? const Color(0xFF3F8FAF)
                                                : Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                        ),
                                        elevation: selectedWeeks.contains(weekIndex) ? 4 : 1,
                                        showCheckmark: false,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          // วนลูปแสดงข้อมูลของทุกสัปดาห์ที่เลือก
                          if (selectedWeeks.isEmpty)
                            ...List.generate(16, (week) => Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: buildWeekReport(week),
                            ))
                          else
                            ...selectedWeeks.map((week) => Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: buildWeekReport(week),
                            ))
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
      ),
    );
  }

  Widget buildWeekReport(int week) {
    // สามารถปรับข้อมูลรายชื่อ/กราฟแต่ละสัปดาห์ได้ที่นี่
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'สัปดาห์ที่ ${week + 1}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3F8FAF),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'รายงานนักศึกษาที่เฝ้าระวัง',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // แถวไอคอนและจำนวนนักศึกษา (ตัวอย่าง)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'รายชื่อนักศึกษาที่เฝ้าระวัง จำนวน ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '10',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' คน',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ตารางรายชื่อ (ตัวอย่าง: ใช้ข้อมูลเดียวกันทุกสัปดาห์ หรือจะเปลี่ยนข้อมูลตาม week ก็ได้)
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black),
              left: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: const [
              Expanded(
                flex: 3,
                child: Center(
                  child: Text('ชื่อ - นามสกุล', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(
                width: 1,
                height: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text('ขาด',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(
                width: 1,
                height: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text('สาย',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        // ข้อมูลนักศึกษา (ตัวอย่าง: สามารถเปลี่ยนข้อมูลตามสัปดาห์ที่เลือกได้)
        ...[
          {'name': 'สมชาย ใจดี',  'absent': '2', 'late': '1'},
          {'name': 'สมหญิง แสนสุข', 'absent': '4', 'late': '0'},
          {'name': 'สมปอง สมใจ',  'absent': '0', 'late': '1'},
          {'name': 'สมทรง แก้วดี',  'absent': '3', 'late': '2'},
          {'name': 'สมฤดี เพียรดี',  'absent': '1', 'late': '1'},
          {'name': 'สมใจ วิเศษ',  'absent': '0', 'late': '0'},
          {'name': 'สมศักดิ์ ศรีสุข',  'absent': '2', 'late': '3'},
          {'name': 'สมบัติ รุ่งเรือง',  'absent': '1', 'late': '2'},
          {'name': 'สมจิตร ใจงาม',  'absent': '3', 'late': '1'},
          {'name': 'สมหมาย มั่งมี',  'absent': '2', 'late': '0'},
        ].asMap().entries.map((entry) {
          int idx = entry.key;
          Map<String, String> student = entry.value;
          final bool isLast = idx == 9;
          final Color rowColor = idx % 2 == 0
              ? const Color(0x336D6D6D)
              : const Color(0x6E3F8FAF);

          return Container(
            decoration: BoxDecoration(
              color: rowColor,
              border: const Border(
                left: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black),
              ),
              borderRadius: isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(student['name']!,
                        style: const TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(
                  width: 1,
                  height: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(student['absent']!,
                        style: const TextStyle(color: Color(0xFFF18D00))),
                  ),
                ),
                SizedBox(
                  width: 1,
                  height: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(student['late']!,
                        style: const TextStyle(color: Color(0xFFFF0000))),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        // เพิ่มข้อความ "รายชื่อนักศึกษา" ตัวหนา
        const Text(
          'รายชื่อนักศึกษา',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        // แสดงเฉพาะแผนภูมิวงกลม 4 สี (มาเรียน, ขาด, สาย, ลา) อันใหญ่
        pc.PieChart(
          dataMap: const {
            "มาเรียน": 50,
            "ขาด": 20,
            "สาย": 15,
            "ลา": 15,
          },
          animationDuration: const Duration(milliseconds: 1000),
          chartRadius: 180, // ขยายขนาดแผนภูมิ
          colorList: const [
            Color(0xFF81C784), // มาเรียน - เขียว
            Color(0xFFFFB74D), // ขาด - ส้ม/เหลือง
            Color(0xFFE57373), // สาย - แดง
            Color(0xFFBA68C8), // ลา - ม่วง
          ],
          chartType: pc.ChartType.disc,
          ringStrokeWidth: 32,
          chartValuesOptions: const pc.ChartValuesOptions(
            showChartValuesInPercentage: true,
            showChartValueBackground: false,
            chartValueStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          legendOptions: const pc.LegendOptions(
            showLegends: false, // ปิด legend ด้านล่าง
          ),
        ),
        const SizedBox(height: 16),
        // แถวสีและ label สำหรับ มาเรียน ขาด สาย ลา
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // มาเรียน
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF81C784), // เขียว
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('มาเรียน', style: TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(width: 18),
            // ขาด
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB74D), // ส้ม/เหลือง
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('ขาด', style: TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(width: 18),
            // สาย
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE57373), // แดง
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('สาย', style: TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(width: 18),
            // ลา
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA68C8), // ม่วง
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('ลา', style: TextStyle(fontSize: 15)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // เพิ่มส่วนนี้
        Row(
          children: [
            const Icon(Icons.people, color: Color(0xFF3F8FAF)),
            const SizedBox(width: 8),
            const Text(
              'รายชื่อนักศึกษา',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ตารางหัวตาราง
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black),
              left: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Center(child: Text('ชื่อ - นามสกุล', style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
              Expanded(flex: 1, child: Center(child: Text('มา', style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
              Expanded(flex: 1, child: Center(child: Text('ขาด', style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
              Expanded(flex: 1, child: Center(child: Text('สาย', style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
              Expanded(flex: 1, child: Center(child: Text('ลา', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
        // ข้อมูลนักศึกษา (ตัวอย่าง: สามารถเปลี่ยนข้อมูลตามสัปดาห์ที่เลือกได้)
        ...[
          {'name': 'สมชาย ใจดี', 'present': '20', 'absent': '2', 'late': '1', 'leave': '1'},
          {'name': 'สมหญิง แสนสุข', 'present': '18', 'absent': '4', 'late': '0', 'leave': '2'},
          {'name': 'สมปอง สมใจ', 'present': '22', 'absent': '0', 'late': '1', 'leave': '0'},
          {'name': 'สมทรง แก้วดี', 'present': '19', 'absent': '3', 'late': '2', 'leave': '1'},
          {'name': 'สมฤดี เพียรดี', 'present': '21', 'absent': '1', 'late': '1', 'leave': '0'},
          {'name': 'สมใจ วิเศษ', 'present': '23', 'absent': '0', 'late': '0', 'leave': '0'},
          {'name': 'สมหมาย มานะ', 'present': '20', 'absent': '1', 'late': '0', 'leave': '1'},
          {'name': 'สมคิด ตั้งใจ', 'present': '17', 'absent': '5', 'late': '2', 'leave': '0'},
          {'name': 'สมจิตต์ พอใจ', 'present': '22', 'absent': '0', 'late': '0', 'leave': '0'},
          {'name': 'สมลักษณ์ สบายดี', 'present': '18', 'absent': '2', 'late': '3', 'leave': '1'},
        ].asMap().entries.map((entry) {
          int idx = entry.key;
          Map<String, String> student = entry.value;
          final bool isLast = idx == 9;
          final Color rowColor = idx % 2 == 0
              ? const Color(0x336D6D6D)
              : const Color(0x6E3F8FAF);

          return Container(
            decoration: BoxDecoration(
              color: rowColor,
              border: const Border(
                left: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black),
              ),
              borderRadius: isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Center(child: Text(student['name']!, style: TextStyle(color: Colors.black)))),
                SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
                Expanded(flex: 1, child: Center(child: Text(student['present']!, style: TextStyle(color: Color(0xFF078230))))),
                SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
                Expanded(flex: 1, child: Center(child: Text(student['absent']!, style: TextStyle(color: Color(0xFFF18D00))))),
                SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
                Expanded(flex: 1, child: Center(child: Text(student['late']!, style: TextStyle(color: Color(0xFFFF0000))))),
                SizedBox(width: 1, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black))),
                Expanded(flex: 1, child: Center(child: Text(student['leave']!, style: TextStyle(color: Color(0xFF8A2BE2))))),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
