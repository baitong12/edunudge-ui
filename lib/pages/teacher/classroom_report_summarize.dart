import 'package:flutter/material.dart';
// นำเข้าไลบรารีหลักของ Flutter สำหรับการสร้าง UI ด้วย Material Design

import 'package:fl_chart/fl_chart.dart';
// นำเข้าไลบรารี fl_chart เพื่อใช้สร้างกราฟชนิดต่างๆ (ในที่นี้คือ BarChart)

import 'package:edunudge/services/api_service.dart';
// นำเข้าคลาส ApiService ที่ใช้สำหรับการเรียก API จาก backend

import 'package:dio/dio.dart';
// นำเข้าไลบรารี Dio สำหรับการทำงานกับ HTTP requests รวมถึงการดาวน์โหลดไฟล์

import 'package:path_provider/path_provider.dart';
// นำเข้าไลบรารี path_provider เพื่อใช้หาตำแหน่งไดเรกทอรีบนเครื่อง (เช่น temporary directory)

import 'package:open_file/open_file.dart';
// นำเข้าไลบรารี open_file เพื่อใช้เปิดไฟล์ที่ดาวน์โหลดมา (เช่น PDF)

import 'package:flutter_dotenv/flutter_dotenv.dart';
// นำเข้าไลบรารี dotenv เพื่ออ่านค่า environment variables

class ReportBsummarizePage extends StatefulWidget {
  // คลาส ReportBsummarizePage เป็น Stateful Widget เนื่องจากมีการเปลี่ยนแปลงสถานะข้อมูล (เช่น ข้อมูลที่โหลดมา)
  final int
  classroomId; // ตัวแปร final สำหรับเก็บ ID ของห้องเรียน (รับมาจากหน้าก่อนหน้า)

  final List<String> atRiskList;
  // ตัวแปร final สำหรับเก็บรายชื่อนักเรียนที่ถูกจัดว่า "เฝ้าระวัง" (รับมาจากหน้าก่อนหน้า)

  const ReportBsummarizePage({
    super.key,
    required this.classroomId,
    required this.atRiskList,
  });
  // Constructor ของ Widget ที่กำหนดให้ต้องส่ง key, classroomId และ atRiskList เข้ามา

  @override
  State<ReportBsummarizePage> createState() => _ReportBsummarizePageState();
  // สร้างและคืนค่า State object สำหรับ Widget นี้
}

class _ReportBsummarizePageState extends State<ReportBsummarizePage>
    with SingleTickerProviderStateMixin {
  // คลาส State ของ ReportBsummarizePage
  // 'with SingleTickerProviderStateMixin' ใช้เพื่อให้สามารถสร้าง AnimationController ได้

  Map<int, double> weeklyDataMap = {};
  // Map สำหรับเก็บข้อมูล % การมาเรียนรายสัปดาห์ (week_number เป็น key (int) และ percent_present เป็น value (double))

  List<Map<String, dynamic>> studentData = [];
  // List สำหรับเก็บข้อมูลดิบ/สรุปผลของแต่ละสัปดาห์ (มา/ลา/ขาด/สาย/เฝ้าระวัง)

  Set<int> selectedWeeks = {};
  // Set สำหรับเก็บหมายเลขสัปดาห์ที่ผู้ใช้เลือกเพื่อใช้ในการกรองข้อมูล (filter)

  final ScrollController _chipScrollController = ScrollController();
  // Controller สำหรับควบคุมการ scroll ของ ListView ที่แสดง FilterChip เลือกสัปดาห์

  late AnimationController _controller;
  // Controller สำหรับควบคุม Animation (เช่น อัตราการเติบโตของแท่งกราฟ)

  late Animation<double> _animation;
  // Object Animation ที่ใช้ควบคุมค่า 0.0 ถึง 1.0 สำหรับทำ effect animation ของกราฟ

  bool isLoading = true;
  // flag เพื่อเช็คสถานะการโหลดข้อมูล (true ขณะโหลด, false เมื่อโหลดเสร็จ)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ), // กำหนดระยะเวลา Animation เป็น 0.8 วินาที
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    // สร้าง Animation ที่ค่อยๆ เปลี่ยนจาก 0.0 ไป 1.0 ด้วย Curve ที่นุ่มนวล
    _controller.forward(); // เริ่ม Animation เพื่อให้กราฟแสดงผลแบบมีชีวิตชีวา

    _loadData(); // เรียกเมธอดโหลดข้อมูลจาก API
  }

  Future<void> downloadAndOpenPDF(String url, {String? fileName}) async {
    // เมธอดสำหรับดาวน์โหลดไฟล์ PDF จาก URL และเปิดไฟล์
    try {
      final dir = await getTemporaryDirectory();
      // ดึง Temporary directory ของแอพพลิเคชันบนอุปกรณ์

      final name =
          fileName ?? 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      // กำหนดชื่อไฟล์ ถ้าไม่ได้ระบุจะใช้ 'pdf_' ตามด้วย timestamp

      final filePath = '${dir.path}/$name';
      // สร้าง path แบบเต็มของไฟล์ที่จะดาวน์โหลด

      await Dio().download(
        url,
        filePath,
      ); // ใช้ Dio ดาวน์โหลดไฟล์จาก URL ไปยัง filePath
      await OpenFile.open(filePath); // ใช้ OpenFile เปิดไฟล์ PDF ที่ดาวน์โหลดมา
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดาวน์โหลด PDF: $e')),
      );
      // แสดง SnackBar หากเกิดข้อผิดพลาดในการดาวน์โหลดหรือเปิดไฟล์
    }
  }

  Future<void> _loadData() async {
    // เมธอดสำหรับโหลดข้อมูลสรุปการเข้าเรียนรายสัปดาห์จาก API
    setState(() => isLoading = true);
    // ตั้งค่า isLoading เป็น true เพื่อแสดง Loading Indicator
    try {
      final weeklySummary = await ApiService.getWeeklyAttendanceSummary(
        classroomId: widget.classroomId,
      );
      // เรียก API เพื่อดึงข้อมูลสรุปการเข้าเรียนรายสัปดาห์ของห้องเรียนนั้นๆ

      setState(() {
        weeklyDataMap = {
          for (var e in weeklySummary)
            (e['week_number'] as int): (e['percent_present'] ?? 0).toDouble(),
        };
        // แปลงข้อมูลที่ได้จาก API ให้อยู่ในรูปแบบ Map: week_number -> % การมาเรียน (สำหรับใช้ในกราฟ)

        studentData = weeklySummary
            .map<Map<String, dynamic>>(
              (e) => {
                "week": e['week_number'] ?? 0,
                "present": e['present'] ?? 0,
                "absent": e['absent'] ?? 0,
                "late": e['late'] ?? 0,
                "leave": e['leave_count'] ?? 0,
                "watchful": widget
                    .atRiskList
                    .length, // ใช้จำนวนนักเรียนที่ "เฝ้าระวัง" จาก Widget property
              },
            )
            .toList();
        // แปลงข้อมูลให้อยู่ในรูปแบบ List ของ Map สำหรับแสดงในตารางสรุป

        isLoading = false;
        // ตั้งค่า isLoading เป็น false เมื่อโหลดข้อมูลเสร็จ
      });
    } catch (e) {
      setState(() => isLoading = false);
      // ตั้งค่า isLoading เป็น false แม้โหลดข้อมูลล้มเหลว
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('โหลดข้อมูลล้มเหลว: $e')));
      // แสดง SnackBar แจ้งข้อผิดพลาด
    }
  }

  void _scrollToCenter(int index) {
    // เมธอดสำหรับเลื่อน FilterChip ไปตรงกลางเมื่อถูกเลือก
    const chipWidth = 100.0;
    const spacing = 8.0;
    final totalChipWidth = chipWidth + spacing;
    final containerWidth = 950.0 - 16.0;
    // กำหนดความกว้างของ chip และพื้นที่ว่าง (สมมติความกว้างคอนเทนเนอร์)
    final targetOffset =
        (index * totalChipWidth) - (containerWidth / 2) + (chipWidth / 2);
    // คำนวณตำแหน่งที่ต้องการเลื่อนเพื่อให้ chip อยู่กึ่งกลาง
    final totalWidth = (16 * totalChipWidth);
    // (16 * totalChipWidth) เป็นค่าสมมติของความกว้างทั้งหมด
    if (totalWidth > containerWidth) {
      // ตรวจสอบว่าความกว้างทั้งหมดของ chip เกินความกว้างของหน้าจอหรือไม่ (ถ้าเกินถึงจะเลื่อนได้)
      _chipScrollController.animateTo(
        targetOffset.clamp(
          _chipScrollController.position.minScrollExtent,
          _chipScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      // สั่ง animate การ scroll ไปยังตำแหน่งที่คำนวณไว้
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // ปล่อยทรัพยากรของ AnimationController
    _chipScrollController.dispose();
    // ปล่อยทรัพยากรของ ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91C8E4),
      // กำหนดสีพื้นหลังของ Scaffold เป็นสีฟ้าอ่อน
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // กำหนดสีพื้นหลัง AppBar เป็นโปร่งใส
        elevation: 0,
        // ลบเงาของ AppBar
        automaticallyImplyLeading: false,
        // ปิดการสร้างปุ่มย้อนกลับอัตโนมัติ
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              // ปุ่มย้อนกลับ
              onPressed: () => Navigator.pop(context),
              // เมื่อกดให้กลับไปยังหน้าก่อนหน้า
            ),
            const SizedBox(width: 4),
            const Text(
              'รายงานสรุปรวมรายสัปดาห์',
              // ข้อความชื่อหน้ารายงาน
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          // หากกำลังโหลด ให้แสดง Loading Indicator สีขาวตรงกลางจอ
          : _buildContent(),
      // หากโหลดเสร็จแล้ว ให้แสดงเนื้อหาของหน้า (_buildContent)
    );
  }

  Widget _buildContent() {
    // เมธอดสำหรับสร้างเนื้อหาหลักของหน้าเมื่อโหลดข้อมูลเสร็จแล้ว
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF91C8E4)),
      // กำหนดสีพื้นหลังให้ตรงกับ Scaffold body
      child: Padding(
        padding: const EdgeInsets.all(16),
        // กำหนด padding 16 รอบคอนเทนเนอร์หลัก
        child: LayoutBuilder(
          // ใช้ LayoutBuilder เพื่อให้ทราบขนาดของพื้นที่ที่มีอยู่ (constraints)
          builder: (context, constraints) {
            final allWeeks = weeklyDataMap.keys.toList()..sort();
            // ดึงหมายเลขสัปดาห์ทั้งหมดจากข้อมูลที่โหลดมาและจัดเรียง

            final displayWeeks =
                selectedWeeks.isEmpty ? allWeeks : selectedWeeks.toList()
                  ..sort();
            // กำหนดสัปดาห์ที่จะแสดง: ถ้าไม่ได้เลือกอะไรเลยให้แสดงทั้งหมด, ถ้าเลือกให้แสดงเฉพาะที่เลือกและจัดเรียง
            //ถ้า selectedWeeks ว่าง (ไม่ได้เลือกอะไรเลย) ให้ใช้ allWeeks แทน
            final chartWidth = displayWeeks.length * 50.0;
            // คำนวณความกว้างที่ต้องการสำหรับกราฟ (กว้าง 50 ต่อแท่ง)
            final availableWidthForChips = constraints.maxWidth - 32;
            // คำนวณความกว้างที่เหลือสำหรับ FilterChip (ความกว้างหน้าจอ - padding ซ้ายขวา)
            final filteredStudentData = selectedWeeks.isEmpty
                ? studentData
                : studentData
                      .where(
                        (student) => selectedWeeks.contains(student["week"]),
                      )
                      .toList();
            // กรองข้อมูลตารางสรุป: ถ้าไม่ได้เลือกสัปดาห์ให้แสดงทั้งหมด, ถ้าเลือกให้แสดงเฉพาะสัปดาห์ที่เลือก

            return SingleChildScrollView(
              // ทำให้เนื้อหาทั้งหมดสามารถ scroll ได้
              child: Container(
                width: double.infinity,
                // กำหนดความกว้างเต็มพื้นที่
                decoration: BoxDecoration(
                  color: Colors.white,
                  // สีพื้นหลังเป็นสีขาว
                  borderRadius: BorderRadius.circular(16),
                  // ขอบโค้งมน
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                  // เพิ่มเงา
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  // กำหนด padding ภายในคอนเทนเนอร์
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // ช่องว่าง 12
                      SizedBox(
                        height: 320,
                        // กำหนดความสูงสำหรับพื้นที่กราฟ
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            // ทำให้กราฟสามารถ scroll แนวนอนได้
                            child: AnimatedBuilder(
                              animation: _animation,
                              // ใช้ AnimatedBuilder เพื่อ rebuild กราฟทุกครั้งที่ค่า _animation เปลี่ยนแปลง
                              builder: (context, child) {
                                final barGroups = displayWeeks.map((week) {
                                  final value = weeklyDataMap[week] ?? 0;
                                  // สร้าง BarChartGroupData สำหรับแต่ละสัปดาห์ที่ต้องการแสดง
                                  return BarChartGroupData(
                                    x: week,
                                    barRods: [
                                      BarChartRodData(
                                        toY: value * _animation.value,
                                        // ใช้ค่า _animation.value เพื่อควบคุมความสูงของแท่งกราฟในช่วง animation
                                        width: 28,
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF3F8FAF),
                                            Color(0xFF62B7C7),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        // กำหนด gradient สีให้กับแท่งกราฟ
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                              show: true,
                                              toY: 100,
                                              color: Colors.grey.shade200,
                                            ),
                                        // กำหนดแท่งกราฟพื้นหลังสีเทาอ่อนเต็ม 100
                                      ),
                                    ],
                                  );
                                }).toList();
                                // สร้าง List ของ BarChartGroupData สำหรับ BarChart

                                return Container(
                                  width: chartWidth < constraints.maxWidth
                                      ? constraints.maxWidth
                                      : chartWidth,
                                  // กำหนดความกว้างของกราฟ: ถ้าความกว้างที่ต้องการน้อยกว่าพื้นที่ที่มีอยู่ ให้ใช้พื้นที่ทั้งหมด มิฉะนั้นให้ใช้ความกว้างที่คำนวณไว้
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: BarChart(
                                    // วาด BarChart
                                    BarChartData(
                                      maxY: 100,
                                      // แกน Y สูงสุด 100%
                                      barGroups: barGroups,
                                      // ใช้ barGroups ที่สร้างไว้
                                      alignment: BarChartAlignment.center,
                                      groupsSpace: 6,
                                      // กำหนดระยะห่างระหว่างกลุ่มแท่งกราฟ
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        // เปิดใช้งาน touch (เมื่อแตะ)
                                        touchTooltipData: BarTouchTooltipData(
                                          // กำหนดรูปแบบของ Tooltip เมื่อแตะ
                                          getTooltipItem:
                                              (
                                                group,
                                                groupIndex,
                                                rod,
                                                rodIndex,
                                              ) {
                                                final week = group.x;
                                                return BarTooltipItem(
                                                  'สัปดาห์ $week\n${rod.toY.toInt()}%',
                                                  // แสดงหมายเลขสัปดาห์และเปอร์เซ็นต์
                                                  const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        // แสดงเส้นกริด
                                        drawHorizontalLine: true,
                                        horizontalInterval: 20,
                                        // กำหนดระยะห่างของเส้นกริดแนวนอนทุก 20 หน่วย
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                              color: Colors.grey.shade300,
                                              strokeWidth: 1,
                                            ),
                                        // กำหนดสีและความหนาของเส้นกริดแนวนอน
                                      ),
                                      titlesData: FlTitlesData(
                                        // กำหนดข้อมูลของ Title บนแกนต่างๆ
                                        bottomTitles: AxisTitles(
                                          // Title แกน X (ด้านล่าง)
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Transform.rotate(
                                                angle: -1.57,
                                                // หมุนข้อความประมาณ 90 องศา (1.57 เรเดียน)
                                                child: Text(
                                                  'สัปดาห์ ${value.toInt()}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                            reservedSize: 60,
                                            interval: 1,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          // Title แกน Y (ด้านซ้าย)
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) =>
                                                Text('${value.toInt()}%'),
                                            // แสดงค่าเปอร์เซ็นต์
                                            interval: 20,
                                            reservedSize: 40,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          // Title แกน X (ด้านบน)
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                          // ไม่แสดง Title ด้านบน
                                        ),
                                        rightTitles: AxisTitles(
                                          // Title แกน Y (ด้านขวา)
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                          // ไม่แสดง Title ด้านขวา
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      // ไม่แสดงเส้นขอบ
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      // ช่องว่าง 8
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: SizedBox(
                            height: 40,
                            width: availableWidthForChips,
                            // กำหนดความสูงและความกว้างสำหรับแถบ FilterChip
                            child: ListView.separated(
                              controller: _chipScrollController,
                              // ใช้ ScrollController ที่สร้างไว้
                              scrollDirection: Axis.horizontal,
                              // แสดงแบบแนวนอน
                              itemCount: allWeeks.length + 1,
                              // จำนวนรายการทั้งหมด (สัปดาห์ทั้งหมด + 1 สำหรับ "ทั้งหมด")
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              // ตัวคั่นระหว่าง chip
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // รายการแรกคือปุ่ม "ทั้งหมด"
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
                                    // ถูกเลือกถ้าไม่มีสัปดาห์ใดถูกเลือกเลย
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedWeeks.clear();
                                        // ล้างการเลือกทั้งหมด
                                        _scrollToCenter(0);
                                        // เลื่อนกลับไปที่ปุ่ม "ทั้งหมด"
                                      });
                                    },
                                    selectedColor: const Color(0xFF3F8FAF),
                                    backgroundColor: Colors.grey.shade400,
                                  );
                                } else {
                                  // รายการอื่นๆ คือปุ่มเลือกสัปดาห์
                                  final weekNumber = allWeeks[index - 1];
                                  return FilterChip(
                                    label: Text(
                                      'สัปดาห์ $weekNumber',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            selectedWeeks.contains(weekNumber)
                                            ? Colors.white
                                            : const Color(0xFF3F8FAF),
                                      ),
                                    ),
                                    selected: selectedWeeks.contains(
                                      weekNumber,
                                    ),
                                    // ถูกเลือกถ้าสัปดาห์นั้นอยู่ใน selectedWeeks
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedWeeks.add(weekNumber);
                                          // เพิ่มสัปดาห์ที่เลือก
                                          _scrollToCenter(index);
                                          // เลื่อนไปยัง chip ที่เลือก
                                        } else {
                                          selectedWeeks.remove(weekNumber);
                                          // ลบสัปดาห์ออกจากที่เลือก
                                        }
                                      });
                                    },
                                    selectedColor: const Color(0xFF3F8FAF),
                                    backgroundColor: Colors.white,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // ช่องว่าง 16
                      Container(
                        width: double.infinity,
                        // กำหนดความกว้างเต็มพื้นที่สำหรับตาราง
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
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                              // Header ของตาราง
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF3F8FAF),
                                    Color(0xFF62B7C7),
                                  ],
                                ),
                                // กำหนด gradient สีพื้นหลัง
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "สัปดาห์ที่",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "มา",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "ลา",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "สาย",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "ขาด",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "เฝ้าระวัง",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                                // แสดงหัวข้อของตาราง
                              ),
                            ),
                            // สร้างแถวข้อมูลตารางจาก filteredStudentData
                            ...filteredStudentData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var student = entry.value;
                              return Container(
                                color: index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF4F9FA),
                                // สลับสีพื้นหลังของแถว (Zebra striping)
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text("${student["week"]}"),
                                      ),
                                    ), // สัปดาห์
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "${student["present"]}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ), // มา (สีเขียว)
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "${student["leave"]}",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ), // ลา (สีน้ำเงิน)
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "${student["late"]}",
                                          style: const TextStyle(
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ), // สาย (สีส้ม)
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "${student["absent"]}",
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ), // ขาด (สีแดง)
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "${student["watchful"]}",
                                          style: const TextStyle(
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ), // เฝ้าระวัง (สีม่วง)
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      // ช่องว่าง 20
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          // ปุ่มสำหรับดาวน์โหลดเอกสาร PDF
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEAA7),
                            // สีพื้นหลังปุ่ม
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              final token = await ApiService.getToken();
                              // ดึง Token สำหรับใช้ในการเข้าถึง
                              final apiUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
                              final baseUrl = apiUrl.replaceAll('/api', '');
                              final url =
                                  '$baseUrl/classrooms/${widget.classroomId}/weekly-pdf/$token';
                              // สร้าง URL สำหรับดาวน์โหลด PDF (ใช้ classroomId และ token)
                              await downloadAndOpenPDF(
                                url,
                                fileName:
                                    'WeeklyReport_${widget.classroomId}.pdf',
                              );
                              // เรียกเมธอดดาวน์โหลดและเปิดไฟล์ PDF
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                              );
                              // แสดง SnackBar หากเกิดข้อผิดพลาดในการทำงาน
                            }
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'ดาวน์โหลดเอกสาร (pdf.)',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      // ช่องว่าง 20
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
