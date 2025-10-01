import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      backgroundColor: Colors.white,
      body: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classroomDetail?['classroom']['name_subject'] ?? '-',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'อาจารย์: ${classroomDetail?['classroom']['teacher'] ?? '-'} | เลขห้องเรียน: ${classroomDetail?['classroom']['room_number'] ?? '-'}',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : buildContent(),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00B894).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'สัปดาห์ที่: ${classroom['week']}',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00B894),
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
                count: int.tryParse(summary['absent'].toString()) ?? 0,
                label: 'ขาดเรียน',
                color: const Color.fromARGB(255, 255, 48, 48),
              ),
              Container(height: 40, width: 1, color: Colors.white),
              _ScoreCard(
                icon: Icons.access_time,
                count: int.tryParse(summary['late'].toString()) ?? 0,
                label: 'มาเรียนสาย',
                color: const Color.fromARGB(255, 255, 206, 45),
              ),
              Container(height: 40, width: 1, color: Colors.white),
              _ScoreCard(
                icon: Icons.event_busy,
                count: int.tryParse(summary['leave'].toString()) ?? 0,
                label: 'ลา',
                color: const Color.fromARGB(255, 69, 143, 255),
              ),
              Container(height: 40, width: 1, color: Colors.white),
              _ScoreCard(
                icon: Icons.star,
                count: int.tryParse(summary['earned_points'].toString()) ?? 0,
                label: 'คะแนนสะสม',
                color: const Color(0xFFFFEAA7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00B894),
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
                  color: Colors.white,
                ),
              ),
              const Divider(color: Colors.white70, thickness: 0.5, height: 20),
              Text(
                'มาเรียนติดกัน: ${classroomDetail!['required_days']} ครั้ง   '
                'ได้คะแนนสะสม: ${classroomDetail!['reward_points']} คะแนน',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...?classroom['rules']?.map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'คะแนนสะสม(ร้อยละ): ${rule['point_percent']}%, '
                    'ได้คะแนนพิเศษท้ายเทอม: ${rule['point_extra']} คะแนน',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00B894),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'รายชื่อนักศึกษา',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const Divider(color: Colors.white70, thickness: 0.5, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendDot(
                    color: getStatusColor('present'),
                    label: 'มาเรียน',
                  ),
                  _LegendDot(color: getStatusColor('late'), label: 'สาย'),
                  _LegendDot(color: getStatusColor('absent'), label: 'ขาด'),
                  _LegendDot(color: getStatusColor('leave'), label: 'ลา'),
                  _LegendDot(
                    color: getStatusColor('no_class'),
                    label: 'ไม่มีเรียน',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...students.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFEAA7),
                      radius: 20,
                      child: Text(
                        getInitials(student['name']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      student['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.circle,
                      color: getStatusColor(student['status']),
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF00B894),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_pin, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'ตำแหน่งห้องเรียน',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.tryParse(classroom['latitude']?.toString() ?? '13.736717') ?? 13.736717,
                      double.tryParse(classroom['longitude']?.toString() ?? '100.523186') ?? 100.523186,
                    ),
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('classroom'),
                      position: LatLng(
                        double.tryParse(classroom['latitude']?.toString() ?? '13.736717') ?? 13.736717,
                        double.tryParse(classroom['longitude']?.toString() ?? '100.523186') ?? 100.523186,
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
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
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
