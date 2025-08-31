import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:edunudge/services/api_service.dart';
import 'package:http/http.dart' as http;

class LocationService with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionStream;
  Position? lastPosition;

  double? classroomLat;
  double? classroomLng;

  LocationService();

  /// เริ่ม tracking
  void startTracking() async {
    WidgetsBinding.instance.addObserver(this);

    // ดึงตำแหน่งห้องเรียนจาก API
    final locationClassroom = await ApiService.getLocationClassroom();
    if (locationClassroom['status'] == 'error') {
      print("Token ไม่พบ กรุณาล็อกอินก่อน");
      return;
    }

    classroomLat = locationClassroom['latitude'];
    classroomLng = locationClassroom['longitude'];
    print("Location classroom: $locationClassroom");

    // ตรวจสอบ GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("กรุณาเปิด GPS");
      return;
    }

    // ตรวจสอบ permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("ไม่ได้รับสิทธิ์ใช้งาน GPS");
        return;
      }
    }

    // เริ่ม stream ตำแหน่งเรียลไทม์
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((pos) {
      lastPosition = pos;

      if (classroomLat != null && classroomLng != null) {
        double distance = Geolocator.distanceBetween(
          classroomLat!,
          classroomLng!,
          pos.latitude,
          pos.longitude,
        );

        print("Lat classroom: $classroomLat");
        print("Lng classroom: $classroomLng");
        print("📍 Lat: ${pos.latitude}, Lng: ${pos.longitude}");
        print("🏫 ระยะห่างจากห้องเรียน: ${distance.toStringAsFixed(2)} m");
      }
    });
  }

  /// หยุด tracking
  void stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// ตรวจจับ lifecycle ของแอป
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("AppLifecycleState changed: $state");
    if ((state == AppLifecycleState.paused || state == AppLifecycleState.detached) 
        && lastPosition != null 
        && classroomLat != null 
        && classroomLng != null) {
      sendLocationToServer(
        lastPosition!.latitude,
        lastPosition!.longitude,
        classroomLat!,
        classroomLng!,
      );
    }
  }

  /// ส่งตำแหน่งไป server
  Future<void> sendLocationToServer(
      double lat, double lng, double classroomLat, double classroomLng) async {
    double distance = Geolocator.distanceBetween(
      classroomLat,
      classroomLng,
      lat,
      lng,
    );

    try {
      const String url = "http://127.0.0.1:8000/api/student/location"; // เปลี่ยนเป็น URL จริง

      final response = await http.post(Uri.parse(url), body: {
        "latitude": lat.toString(),
        "longitude": lng.toString(),
        "distance": distance.toString(),
      });

      if (response.statusCode == 200) {
        print("ส่งตำแหน่งล่าสุดไป server สำเร็จ");
      } else {
        print("ส่งตำแหน่งล่าสุดไป server ล้มเหลว: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }
}
