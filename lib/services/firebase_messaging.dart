import 'dart:math'; // ใช้สำหรับการคำนวณทางคณิตศาสตร์ เช่น sqrt, atan2, sin, cos
import 'package:flutter/material.dart'; // ใช้สำหรับ UI และ Colors
import 'package:firebase_messaging/firebase_messaging.dart'; // ใช้เชื่อมกับ Firebase Cloud Messaging (FCM)
import 'package:overlay_support/overlay_support.dart'; // ใช้แสดง notification overlay ในแอป
import 'package:geolocator/geolocator.dart'; // ใช้ดึงตำแหน่งพิกัดปัจจุบันของผู้ใช้
import '../services/api_service.dart'; // เรียกใช้ API ภายนอก (ไปดึงพิกัดห้องเรียน)
import '../main.dart';  // import main.dart เพื่อเข้าถึง navigatorKey สำหรับเปลี่ยนหน้า

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance; // สร้าง instance สำหรับ FCM

  String? classroomLatStr; // เก็บค่าละติจูดของห้องเรียนในรูป String
  String? classroomLngStr; // เก็บค่าลองจิจูดของห้องเรียนในรูป String
  String? _classroomName;  // เก็บชื่อวิชา

  double? _classroomLatDouble; // เก็บละติจูดในรูป double
  double? _classroomLngDouble; // เก็บลองจิจูดในรูป double


  // โหลดพิกัดของห้องเรียนจาก API (ถ้าเคยโหลดแล้วจะไม่โหลดซ้ำ ยกเว้น forceRefresh = true)
  Future<void> _ensureClassroomLocationLoaded({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && classroomLatStr != null && classroomLngStr != null)
      return; // ถ้าเคยโหลดแล้ว และไม่บังคับ refresh ก็ไม่ต้องโหลดใหม่

    try { 
      final res = await ApiService.getLocationClassroom(); // ดึงข้อมูลห้องเรียนจาก API
      if (res['status'] != 'success') return; // ถ้า status != success ออกทันที

      final lat = res['latitude']?.toString(); // ดึง latitude
      final lng = res['longitude']?.toString(); // ดึง longitude
      final name = res['name_subject']?.toString(); // ดึงชื่อวิชา

      if (lat != null && lng != null) { // ถ้ามีค่าพิกัด
        classroomLatStr = lat;
        classroomLngStr = lng;
        _classroomLatDouble = double.tryParse(lat); // แปลงเป็น double
        _classroomLngDouble = double.tryParse(lng);
        _classroomName = name; // เก็บชื่อวิชา
      }
    } catch (e) {
      print("getClassroom Error : $e"); // ถ้ามี error ให้ print
    }
  }


  // ฟังก์ชันเริ่มต้นการตั้งค่า FCM
  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true); // ขอสิทธิ์การแจ้งเตือน

    FirebaseMessaging.onMessage.listen(_handleMessage); // ฟัง event เมื่อแอปเปิดอยู่ foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigatorKey.currentState?.pushNamed('/home_student'); // ถ้าเปิดจากการกด noti ให้เด้งไปหน้า home_student
    });

    final initial = await _fcm.getInitialMessage(); // กรณีเปิดแอปจาก noti (หลังปิดแอป)
    if (initial != null) {
      navigatorKey.currentState?.pushNamed('/home_student');
    }
  }

  // ฟังก์ชันจัดการข้อความแจ้งเตือนเมื่อได้รับ
  void _handleMessage(RemoteMessage message) async {
    await _ensureClassroomLocationLoaded(forceRefresh: true); // โหลดข้อมูลพิกัดห้องเรียนใหม่

    String distanceText = ""; // เก็บข้อความระยะทาง
    String subjectName = _classroomName ?? "ไม่ทราบชื่อวิชา"; // ถ้าไม่มีชื่อวิชาให้แสดง default

    String studentPositionText = ""; // เก็บข้อความตำแหน่งนักเรียน

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // ขอพิกัดแบบละเอียดสูง
      );

      studentPositionText = "Student: ${pos.latitude}, ${pos.longitude}"; // เก็บตำแหน่งผู้ใช้

      if (_classroomLatDouble != null && _classroomLngDouble != null) {
        final d = _calculateDistance( // คำนวณระยะทางนักเรียน -> ห้องเรียน
          _classroomLatDouble!,
          _classroomLngDouble!,
          pos.latitude,
          pos.longitude,
        );
        distanceText = _formatDistance(d); // แปลงตัวเลขเป็นข้อความ
      } else {
        distanceText = "ไม่มีพิกัดห้องเรียน";
      }
    } catch (_) {
      distanceText = "ไม่สามารถคำนวณระยะทางได้"; // ถ้า error ในการหาพิกัด
    }

    // กำหนดประเภท noti ว่าเป็น green, yellow, red
    final type = (message.data['type'] ?? 'green').toString().toLowerCase();
    final color = type == 'red'
        ? (Colors.red[700] ?? Colors.red)
        : type == 'yellow'
        ? (Colors.orange[700] ?? Colors.orange)
        : (Colors.green[700] ?? Colors.green);

    // ข้อความตามประเภท
    String contentText;
    if (type == 'green') {
      contentText = "อีกไม่นานจะเริ่มเรียนวิชา $subjectName ($distanceText)";
    } else if (type == 'yellow') {
      contentText = "วิชา $subjectName เริ่มแล้ว ($distanceText)";
    } else {
      contentText = "คุณยังไม่ได้เช็คชื่อในวิชา $subjectName ($distanceText)";
    }

    // กำหนด title ของ noti (เอามาจาก data หรือ notification ถ้าไม่มีให้ใช้ "แจ้งเตือน")
    final title =
        (message.data['title'] as String?) ??
        message.notification?.title ??
        "แจ้งเตือน";

    // แสดง Notification แบบ OverlaySupport
    showSimpleNotification(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            contentText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (classroomLatStr != null && classroomLngStr != null)
            Text(
              "Classroom: $classroomLatStr, $classroomLngStr",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          if (studentPositionText.isNotEmpty)
            Text(
              studentPositionText,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
      background: color, // สีตาม type
      duration: const Duration(seconds: 10), // แสดง 10 วินาที
    );
  }

  // ฟังก์ชันคำนวณระยะทางด้วยสูตร Haversine
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0; // รัศมีโลก (เมตร)
    final dLat = _deg2rad(lat2 - lat1); // ความต่างละติจูด (rad)
    final dLng = _deg2rad(lng2 - lng1); // ความต่างลองจิจูด (rad)

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLng / 2) * sin(dLng / 2)); // สูตร Haversine
    final c = 2 * atan2(sqrt(a), sqrt(1 - a)); // มุมโค้งกลางระหว่าง 2 จุด

    return earthRadius * c; // ระยะทาง = รัศมีโลก * มุมโค้ง
  }

  // แปลงองศาเป็นเรเดียน
  double _deg2rad(double deg) => deg * (pi / 180.0);

  // ฟังก์ชันจัดรูปแบบระยะทางเป็นข้อความ
  String _formatDistance(double meters) {
    if (meters < 1000) return "ระยะทาง:${meters.toStringAsFixed(0)} ม."; // ถ้าน้อยกว่า 1 กม. ใช้หน่วยเมตร
    return "ระยะทาง:${(meters / 1000).toStringAsFixed(2)} กม."; // ถ้าเกิน 1 กม. แสดงหน่วยกิโลเมตร
  }
}
