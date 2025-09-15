import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edunudge/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportBsummarizePage extends StatefulWidget {
  final int classroomId;
  final List<String> atRiskList; // เปลี่ยนจาก int เป็น List<String>
  // ต้องส่ง classroomId
  const ReportBsummarizePage({
    super.key,
    required this.classroomId,
    required this.atRiskList,
  });

  @override
  State<ReportBsummarizePage> createState() => _ReportBsummarizePageState();
}

class _ReportBsummarizePageState extends State<ReportBsummarizePage>
    with SingleTickerProviderStateMixin {
  List<double> weeklyData = [];
  List<Map<String, dynamic>> studentData = [];
  Set<int> selectedWeeks = {};
  final ScrollController _chipScrollController = ScrollController();

  late AnimationController _controller;
  late Animation<double> _animation;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    _loadData();
  }

  Future<void> downloadAndOpenPDF(String url, {String? fileName}) async {
    try {
      final dir = await getTemporaryDirectory(); // โฟลเดอร์ชั่วคราวของมือถือ
      final name =
          fileName ?? 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$name';

      // ดาวน์โหลดไฟล์ PDF ลงเครื่อง
      await Dio().download(url, filePath);

      // เปิดไฟล์ PDF ด้วย default viewer ของเครื่อง
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดาวน์โหลด PDF: $e')),
      );
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // เรียก API
      final weeklySummary = await ApiService.getWeeklyAttendanceSummary(
        classroomId: widget.classroomId,
      );

      setState(() {
        // แปลง weeklySummary ให้เป็น weeklyData สำหรับกราฟ
        weeklyData = weeklySummary
            .map<double>((e) => (e['percent_present'] ?? 0).toDouble())
            .toList();

        // studentData สำหรับตาราง
        studentData = weeklySummary
            .map<Map<String, dynamic>>(
              (e) => {
                "week": e['week_number'] ?? 0,
                "present": e['present'] ?? 0,
                "absent": e['absent'] ?? 0,
                "late": e['late'] ?? 0,
                "leave": e['leave_count'] ?? 0,
                "watchful": widget.atRiskList.length,
              },
            )
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('โหลดข้อมูลล้มเหลว: $e')));
    }
  }

  void _scrollToCenter(int index) {
    const chipWidth = 100.0;
    const spacing = 8.0;
    final totalChipWidth = chipWidth + spacing;
    final containerWidth = 950.0 - 16.0;
    final targetOffset =
        (index * totalChipWidth) - (containerWidth / 2) + (chipWidth / 2);
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
    _controller.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91C8E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const Text(
              'รายงานสรุปรวมรายสัปดาห์',
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
          : _buildContent(),
    );
  }

  Widget _buildContent() {
  return Container(
    width: double.infinity,
    height: double.infinity, // ล็อคความสูงเต็มหน้าจอ
    decoration: const BoxDecoration(
      color: Color(0xFF91C8E4), // สีพื้นเรียบ
    ),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final displayWeeks =
                selectedWeeks.isEmpty
                      ? List.generate(weeklyData.length, (i) => i)
                      : selectedWeeks.toList()
                  ..sort();

            final Map<int, int> weekXMap = {};
            for (int i = 0; i < displayWeeks.length; i++) {
              weekXMap[displayWeeks[i]] = i;
            }

            final chartWidth = displayWeeks.length * 40.0;
            final availableWidthForChips = constraints.maxWidth - 32;

            // กรอง studentData ตามสัปดาห์ที่เลือก
            final filteredStudentData = selectedWeeks.isEmpty
                ? studentData
                : studentData
                      .where(
                        (student) =>
                            selectedWeeks.contains(student["week"] - 1),
                      )
                      .toList();

            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // กราฟแท่ง
                      SizedBox(
                        height: 320,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                final barGroups = displayWeeks.map((weekIndex) {
                                  final xPos = weekXMap[weekIndex]!;
                                  return BarChartGroupData(
                                    x: xPos,
                                    barRods: [
                                      BarChartRodData(
                                        toY:
                                            weeklyData[weekIndex] *
                                            _animation.value,
                                        width: 28,
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFEAA7),
                                            Color(0xFF62B7C7),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                              show: true,
                                              toY: 100,
                                              color: Colors.grey.shade200,
                                            ),
                                      ),
                                    ],
                                  );
                                }).toList();

                                return Container(
                                  width: chartWidth.clamp(
                                    constraints.maxWidth - 32,
                                    double.infinity,
                                  ),
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
                                    BarChartData(
                                      maxY: 100,
                                      barGroups: barGroups,
                                      alignment: BarChartAlignment.center,
                                      groupsSpace: 6,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem:
                                              (
                                                group,
                                                groupIndex,
                                                rod,
                                                rodIndex,
                                              ) {
                                                final week =
                                                    displayWeeks[group.x];
                                                return BarTooltipItem(
                                                  'สัปดาห์ ${week + 1}\n${rod.toY.toInt()}%',
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
                                        drawHorizontalLine: true,
                                        horizontalInterval: 20,
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                              color: Colors.grey.shade300,
                                              strokeWidth: 1,
                                            ),
                                      ),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              int i = value.toInt();
                                              if (i >= displayWeeks.length)
                                                return const SizedBox();
                                              final week = displayWeeks[i];
                                              return Transform.rotate(
                                                angle: -1.57,
                                                child: Text(
                                                  'สัปดาห์ ${week + 1}',
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
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) =>
                                                Text('${value.toInt()}%'),
                                            interval: 20,
                                            reservedSize: 40,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // FilterChip
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: SizedBox(
                            height: 40,
                            width: availableWidthForChips,
                            child: ListView.separated(
                              controller: _chipScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: weeklyData.length + 1,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                if (index == 0) {
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
                                    selectedColor: const Color(0xFFFFEAA7),
                                    backgroundColor: Colors.grey.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: selectedWeeks.isEmpty
                                            ? const Color(0xFFFFEAA7)
                                            : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    elevation: selectedWeeks.isEmpty ? 4 : 1,
                                    showCheckmark: false,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                  );
                                } else {
                                  final weekIndex = index - 1;
                                  return FilterChip(
                                    label: Text(
                                      'สัปดาห์ ${weekIndex + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: selectedWeeks.contains(weekIndex)
                                            ? Colors.white
                                            : const Color(0xFFFFEAA7),
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
                                    selectedColor: const Color(0xFFFFEAA7),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: selectedWeeks.contains(weekIndex)
                                            ? const Color(0xFFFFEAA7)
                                            : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    elevation: selectedWeeks.contains(weekIndex)
                                        ? 4
                                        : 1,
                                    showCheckmark: false,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ตารางสรุปนักศึกษา
                      Container(
                        width: double.infinity,
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
                            // header ตาราง
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 8,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFEAA7),
                                    Color(0xFF62B7C7),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "สัปดาห์ที่",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "มา",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "ลา",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "สาย",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "ขาด",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "เฝ้าระวัง",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // แถวข้อมูลนักศึกษา
                            ...filteredStudentData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var student = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? Colors.white
                                      : const Color(0xFFF4F9FA),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text("${student["week"]}"),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          "${student["present"]}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          "${student["leave"]}",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          "${student["late"]}",
                                          style: const TextStyle(
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          "${student["absent"]}",
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          "${student["watchful"]}",
                                          style: const TextStyle(
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ ปุ่มดาวน์โหลด PDF ย้ายมาที่นี่ (ตรงกลางล่างหลังตาราง)
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEAA7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            elevation: 3,
                          ),
                          onPressed: () async {
                            try {
                              final token = await ApiService.getToken();
                              final url =
                                  'http://52.63.155.211/classrooms/${widget.classroomId}/weekly-pdf/$token';

                              await downloadAndOpenPDF(
                                url,
                                fileName:
                                    'WeeklyReport_${widget.classroomId}.pdf',
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                              );
                            }
                          },

                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: const Text(
                            'ดาวน์โหลดเอกสาร (pdf.)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
