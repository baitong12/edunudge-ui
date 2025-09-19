
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../main.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  String? classroomLatStr;
  String? classroomLngStr;
  String? _classroomName;

  double? _classroomLatDouble;
  double? _classroomLngDouble;


  Future<void> _ensureClassroomLocationLoaded({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && classroomLatStr != null && classroomLngStr != null)
      return;

 

    try {
      final res = await ApiService.getLocationClassroom();
      if (res['status'] != 'success') return;

      final lat = res['latitude']?.toString();
      final lng = res['longitude']?.toString();
      final name = res['name_subject']?.toString();

      if (lat != null && lng != null) {
        classroomLatStr = lat;
        classroomLngStr = lng;
        _classroomLatDouble = double.tryParse(lat);
        _classroomLngDouble = double.tryParse(lng);
        _classroomName = name;

        print("✅ Classroom loaded from API: $lat, $lng, name=$_classroomName");
      }
    } catch (e) {
      print("getClassroom Error : $e");
    }
  }


  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigatorKey.currentState?.pushNamed('/home_student');
    });

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      navigatorKey.currentState?.pushNamed('/home_student');
    }
    ;
  }

  void _handleMessage(RemoteMessage message) async {
    print("📩 FCM: ${message.data}");

    await _ensureClassroomLocationLoaded(forceRefresh: true);

    String distanceText = "";
    String subjectName = _classroomName ?? "ไม่ทราบชื่อวิชา";

    String studentPositionText = "";

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      studentPositionText = "Student: ${pos.latitude}, ${pos.longitude}";

      if (_classroomLatDouble != null && _classroomLngDouble != null) {
        final d = _calculateDistance(
          _classroomLatDouble!,
          _classroomLngDouble!,
          pos.latitude,
          pos.longitude,
        );
        distanceText = _formatDistance(d);
      } else {
        distanceText = "❌ ไม่มีพิกัดห้องเรียน";
      }
    } catch (_) {
      distanceText = "❌ ไม่สามารถคำนวณระยะทางได้";
    }

    final type = (message.data['type'] ?? 'green').toString().toLowerCase();
    final color = type == 'red'
        ? (Colors.red[700] ?? Colors.red)
        : type == 'yellow'
        ? (Colors.orange[700] ?? Colors.orange)
        : (Colors.green[700] ?? Colors.green);


    String contentText;
    if (type == 'green') {
      contentText = "อีกไม่นานจะเริ่มเรียนวิชา $subjectName ($distanceText)";
    } else if (type == 'yellow') {
      contentText = "วิชา $subjectName เริ่มแล้ว ($distanceText)";
    } else {
      contentText = "คุณยังไม่ได้เช็คชื่อในวิชา $subjectName ($distanceText)";
    }

    final title =
        (message.data['title'] as String?) ??
        message.notification?.title ??
        "แจ้งเตือน";

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
      background: color,
      duration: const Duration(seconds: 10),
    );
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0; 
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);


  String _formatDistance(double meters) {
    if (meters < 1000) return "ระยะทาง:${meters.toStringAsFixed(0)} ม.";
    return "ระยะทาง:${(meters / 1000).toStringAsFixed(2)} กม.";
  }
}
