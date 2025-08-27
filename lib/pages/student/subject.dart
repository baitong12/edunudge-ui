import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:edunudge/services/api_service.dart';

class Subject extends StatefulWidget {
  final int classroomId;

  const Subject({super.key, required this.classroomId});

  @override
  State<Subject> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<Subject> {
  Map<String, dynamic>? classroomDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchClassroomDetail();
  }

  Future<void> fetchClassroomDetail() async {
    try {
      final data = await ApiService.getClassroomDetail(widget.classroomId);
      setState(() {
        classroomDetail = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'green':
      case 'present':
        return Colors.green;
      case 'yellow':
      case 'late':
        return Colors.orange;
      case 'red':
      case 'absent':
        return Colors.red;
      case 'blue':
      case 'leave':
        return Colors.blue;
      case 'grey':
      case 'no_class':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String getInitials(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00C853),
              Color(0xFF00BCD4)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            title: const Text(
              'รายละเอียดรายวิชา',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    final students = classroomDetail!['students'] as List<dynamic>;
    final classroom = classroomDetail!['classroom'];
    final summary = classroomDetail!['summary'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ================== Legend ==================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LegendDot(color: getStatusColor('present'), label: 'มาเรียน'),
            _LegendDot(color: getStatusColor('late'), label: 'สาย'),
            _LegendDot(color: getStatusColor('absent'), label: 'ขาด'),
            _LegendDot(color: getStatusColor('leave'), label: 'ลา'),
            _LegendDot(color: getStatusColor('no_class'), label: 'ไม่มีเรียน'),
          ],
        ),
        const SizedBox(height: 20),

        // ================== Score Card ==================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreCard(
                icon: Icons.close,
                count: summary['absent'] ?? 0,
                label: 'ขาดเรียน',
                color: Colors.red,
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              _ScoreCard(
                icon: Icons.access_time,
                count: summary['late'] ?? 0,
                label: 'มาเรียนสาย',
                color: Colors.orange,
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              _ScoreCard(
                icon: Icons.star,
                count: summary['earned_points'] ?? 0,
                label: 'คะแนนสะสม',
                color: Colors.amber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ================== Subject Info ==================
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              classroom['name_subject'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              classroom['room_number'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              classroom['teacher'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              'สัปดาห์ที่: ${classroom['week']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ================== Grade Criteria ==================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เกณฑ์การให้คะแนน',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(color: Colors.grey, thickness: 0.5, height: 20),
              ...?classroom['rules']?.map((rule) => _buildGradeCriteriaRow(
                    context,
                    'มาเรียนคิดเป็น:',
                    '${rule['point_percent']}%',
                    'คะแนนพิเศษ:',
                    '${rule['point_extra']} คะแนน',
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ================== Students ==================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('รายชื่อนักศึกษา',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  )),
              const Divider(color: Colors.grey, thickness: 0.5, height: 20),
              ...students.map((student) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00C853),
                        radius: 20,
                        child: Text(
                          getInitials(student['name']),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      title: Text(
                        student['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Icon(Icons.circle,
                          color: getStatusColor(student['status']), size: 12),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGradeCriteriaRow(
      BuildContext context, String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '$label1 $value1',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            '$label2 $value2',
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _ScoreCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}