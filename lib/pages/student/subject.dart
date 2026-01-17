// นำเข้าไลบรารี dart สำหรับจัดการ UI ขั้นพื้นฐาน
import 'dart:ui';
// นำเข้าไลบรารี Flutter Material สำหรับ widget ต่างๆ
import 'package:flutter/material.dart';
// นำเข้าไลบรารี Google Maps สำหรับใช้งาน GoogleMap widget
import 'package:google_maps_flutter/google_maps_flutter.dart';
// นำเข้า service สำหรับเรียก API ของแอป EduNudge
import 'package:edunudge/services/api_service.dart';

// สร้าง StatefulWidget สำหรับหน้ารายละเอียดวิชา
class Subject extends StatefulWidget {
  // ตัวแปรเก็บรหัสห้องเรียนที่ส่งมาจากหน้าก่อนหน้า
  final int classroomId;

  // คอนสตรัคเตอร์ สำหรับรับ classroomId
  const Subject({super.key, required this.classroomId});

  @override
  State<Subject> createState() => _SubjectPageState();
}

// State ของ Subject widget
class _SubjectPageState extends State<Subject> {
  // ตัวแปรเก็บรายละเอียดห้องเรียนที่ดึงจาก API
  Map<String, dynamic>? classroomDetail;
  // ตัวแปรตรวจสอบสถานะการโหลดข้อมูล
  bool isLoading = true;
  // ตัวแปรเก็บข้อความผิดพลาดถ้ามี
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันดึงข้อมูลห้องเรียนเมื่อสร้าง State
    fetchClassroomDetail();
  }

  // ฟังก์ชันดึงรายละเอียดห้องเรียนจาก API
  Future<void> fetchClassroomDetail() async {
    try {
      // เรียก API ผ่าน ApiService
      final data = await ApiService.getClassroomDetail(widget.classroomId);
      setState(() {
        // เก็บข้อมูลลงตัวแปร classroomDetail
        classroomDetail = data;
        // เปลี่ยนสถานะ isLoading เป็น false
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // เก็บข้อความผิดพลาด
        errorMessage = e.toString();
        // เปลี่ยนสถานะ isLoading เป็น false
        isLoading = false;
      });
    }
  }

  // ฟังก์ชันกำหนดสีตามสถานะนักเรียน
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'green':
      case 'present':
        return Colors.green; // มาเรียน
      case 'yellow':
      case 'late':
        return Colors.orange; // มาเรียนสาย
      case 'red':
      case 'absent':
        return Colors.red; // ขาดเรียน
      case 'blue':
      case 'leave':
        return Colors.blue; // ลา
      case 'grey':
      case 'no_class':
        return Colors.grey; // ไม่มีเรียน
      default:
        return Colors.grey; // ค่า default
    }
  }

  // ฟังก์ชันดึงตัวย่อจากชื่อเต็มนักเรียน
  String getInitials(String fullName) {
    final parts = fullName.split(' '); // แยกชื่อด้วยช่องว่าง
    if (parts.length >= 2) {
      // ถ้ามี 2 คำขึ้นไป เอาตัวอักษรตัวแรกของแต่ละคำ
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    // ถ้ามีคำเดียว เอาตัวแรก
    return fullName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังสีขาว
      body: Scaffold(
        backgroundColor: Colors.white,
        // AppBar ของหน้ารายละเอียดวิชา
        appBar: AppBar(
          backgroundColor: Colors.white, // พื้นหลังขาว
          elevation: 0, // ไม่ให้มีเงา
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context), // กดกลับไปหน้าก่อนหน้า
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // แสดงชื่อวิชา
              Text(
                classroomDetail?['classroom']['name_subject'] ?? '-', 
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // แสดงชื่ออาจารย์และเลขห้องเรียน
              Text(
                'อาจารย์: ${classroomDetail?['classroom']['teacher'] ?? '-'} | เลขห้องเรียน: ${classroomDetail?['classroom']['room_number'] ?? '-'}',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
          centerTitle: false, // ชื่อไม่อยู่ตรงกลาง
        ),
        // ส่วนเนื้อหาหลัก
        body: isLoading
            ? const Center(child: CircularProgressIndicator()) // กำลังโหลด
            : errorMessage != null
                ? Center(child: Text(errorMessage!)) // มีข้อผิดพลาด
                : buildContent(), // แสดงข้อมูลเมื่อโหลดเสร็จ
      ),
    );
  }

  // ฟังก์ชันสร้างเนื้อหาหลักของหน้ารายละเอียด
  Widget buildContent() {
    final students = classroomDetail!['students'] as List<dynamic>; // รายชื่อนักเรียน
    final classroom = classroomDetail!['classroom']; // ข้อมูลห้องเรียน
    final summary = classroomDetail!['summary']; // สรุปสถิติการเข้าเรียน

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // แสดงสัปดาห์ที่เรียน
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00B894).withOpacity(0.2), // สีพื้นอ่อน
            borderRadius: BorderRadius.circular(12), // มุมโค้ง
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
        const SizedBox(height: 20), // เว้นระยะ
        // สรุปสถิติการเข้าเรียนและคะแนนสะสม
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
              // การ์ดสถิติขาดเรียน
              _ScoreCard(
                icon: Icons.close,
                count: int.tryParse(summary['absent'].toString()) ?? 0,
                label: 'ขาดเรียน',
                color: const Color.fromARGB(255, 255, 48, 48),
              ),
              Container(height: 40, width: 1, color: Colors.white), // เส้นแบ่ง
              // การ์ดสถิติมาเรียนสาย
              _ScoreCard(
                icon: Icons.access_time,
                count: int.tryParse(summary['late'].toString()) ?? 0,
                label: 'มาเรียนสาย',
                color: const Color.fromARGB(255, 255, 206, 45),
              ),
              Container(height: 40, width: 1, color: Colors.white), // เส้นแบ่ง
              // การ์ดสถิติลา
              _ScoreCard(
                icon: Icons.event_busy,
                count: int.tryParse(summary['leave'].toString()) ?? 0,
                label: 'ลา',
                color: const Color.fromARGB(255, 69, 143, 255),
              ),
              Container(height: 40, width: 1, color: Colors.white), // เส้นแบ่ง
              // การ์ดคะแนนสะสม
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
        // แสดงเกณฑ์การให้คะแนน
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
              const Divider(color: Colors.white70, thickness: 0.5, height: 20), // เส้นแบ่ง
              // แสดงกฎการให้คะแนนหลัก
              Text(
                'มาเรียนติดกัน: ${classroomDetail!['required_days']} ครั้ง   '
                'ได้คะแนนสะสม: ${classroomDetail!['reward_points']} คะแนน',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // แสดงกฎการให้คะแนนพิเศษ
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
        // แสดงรายชื่อนักเรียน
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
              // แสดงสัญลักษณ์สถานะ
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
              // แสดงรายชื่อนักเรียนแต่ละคน
              ...students.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    // รูปวงกลมแสดงตัวย่อ
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
                    // สัญลักษณ์แสดงสถานะ
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
        // แสดงตำแหน่งห้องเรียนบนแผนที่
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
              // ขนาดของ GoogleMap
              SizedBox(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  // กำหนดตำแหน่งเริ่มต้น
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.tryParse(classroom['latitude']?.toString() ?? '13.736717') ?? 13.736717,
                      double.tryParse(classroom['longitude']?.toString() ?? '100.523186') ?? 100.523186,
                    ),
                    zoom: 16,
                  ),
                  // กำหนด Marker ของห้องเรียน
                  markers: {
                    Marker(
                      markerId: const MarkerId('classroom'),
                      position: LatLng(
                        double.tryParse(classroom['latitude']?.toString() ?? '13.736717') ?? 13.736717,
                        double.tryParse(classroom['longitude']?.toString() ?? '100.523186') ?? 100.523186,
                      ),
                    ),
                  },
                  zoomControlsEnabled: false, // ปิดปุ่มซูม
                  myLocationEnabled: false, // ปิดตำแหน่งผู้ใช้
                  myLocationButtonEnabled: false, // ปิดปุ่มหาตำแหน่ง
                  mapType: MapType.normal, // ประเภทแผนที่ปกติ
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

// Widget การ์ดแสดงสถิติ
class _ScoreCard extends StatelessWidget {
  final IconData icon; // ไอคอน
  final int count; // จำนวน
  final String label; // ชื่อสถิติ
  final Color color; // สีของไอคอนและตัวเลข

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
        Icon(icon, color: color, size: 30), // แสดงไอคอน
        const SizedBox(height: 4), // เว้นระยะ
        Text(
          '$count', // แสดงจำนวน
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        Text(
          label, // แสดงชื่อสถิติ
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

// Widget แสดงสัญลักษณ์สถานะนักเรียน
class _LegendDot extends StatelessWidget {
  final Color color; // สีของจุด
  final String label; // ชื่อสถานะ

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 12), // จุดสี
        const SizedBox(width: 6), // เว้นระยะ
        Text(
          label, // ชื่อสถานะ
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
