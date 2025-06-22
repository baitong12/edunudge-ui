import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:location/location.dart';

class Subject extends StatefulWidget {
  final String subject;
  final String room;
  final String teacher;

  const Subject({
    super.key,
    required this.subject,
    required this.room,
    required this.teacher,
  });

  @override
  State<Subject> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<Subject> {
  LocationData? userLocation;
  int currentWeek = 5; // 👈 ตั้งค่าสัปดาห์ปัจจุบัน

  final students = List.generate(
    10,
    (index) => {
      'name': 'ชื่อ-นามสกุล',
      'profile': null,
      'status': index % 3 == 0
          ? 'late'
          : index % 4 == 0
              ? 'absent'
              : 'present',
    },
  );

  Future<void> _getUserLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final currentLocation = await location.getLocation();
    setState(() => userLocation = currentLocation);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.red;
      case 'leave':
        return Colors.blue;
      case 'no_class':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF221B64),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          'รายละเอียดรายวิชา',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // แถบแสดงสีสถานะ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
             
             
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _LegendDot(color: Colors.green, label: 'มาเรียน' ),
                _LegendDot(color: Colors.red, label: 'ยังไม่มา'),
                _LegendDot(color: Colors.blue, label: 'ลา'),
                _LegendDot(color: Colors.grey, label: 'ไม่มีเรียน'),
              ],
            ),
          ),
           const SizedBox(height: 20),

          // กล่องคะแนน
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _ScoreCard(
                  icon: Icons.close,
                  count: 2,
                  label: 'ขาดเรียน',
                  color: Colors.red,
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                const _ScoreCard(
                  icon: Icons.access_time,
                  count: 1,
                  label: 'มาเรียนสาย',
                  color: Colors.orange,
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                const _ScoreCard(
                  icon: Icons.star,
                  count: 20,
                  label: 'คะแนนสะสม',
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ข้อมูลวิชา + สัปดาห์
          Column(
            children: [
              Center(
                child: Text(
                  widget.subject,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  widget.room,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  widget.teacher,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'สัปดาห์ที่: $currentWeek',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // รายชื่อนักศึกษา
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('รายชื่อนักศึกษา',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                ...students.map((student) => ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.black),
                      title: Text(student['name']!),
                      trailing: Icon(Icons.circle,
                          color: getStatusColor(student['status']!), size: 12),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ตำแหน่ง
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ตำแหน่ง',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                ElevatedButton(
                  onPressed: () {
                    // TODO: แสดงตำแหน่งห้องเรียน
                  },
                  child: const Text('แผนที่ห้องเรียน'),
                ),
                ElevatedButton(
                  onPressed: _getUserLocation,
                  child: const Text('แผนที่นักศึกษา'),
                ),
                if (userLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        'ตำแหน่งของคุณ: (${userLocation!.latitude}, ${userLocation!.longitude})'),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2, context: context),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(label),
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
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),  // <-- เพิ่มสีขาวตรงนี้
        ),
      ],
    );
  }
}
