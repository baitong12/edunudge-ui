// location_notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import './shared/constants.dart';

// Task name
const _kTaskSendLastLocation = 'sendLastLocation';

// =============== Workmanager dispatcher ===============
@pragma('vm:entry-point')
void lastLocationWorkmanagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _kTaskSendLastLocation) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final lat = prefs.getString(kLastLat);
        final lng = prefs.getString(kLastLng);
        final ts = prefs.getString(kLastTs);
        final token = prefs.getString(kAuthToken);

        if (lat != null && lng != null) {
          const url = "http://52.63.155.211/api/student/location";
          final headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          };
          final body = jsonEncode({
            "latitude": lat,
            "longitude": lng,
            "timestamp": ts ?? DateTime.now().toIso8601String(),
          });

          final res = await http.post(
            Uri.parse(url),
            headers: headers,
            body: body,
          );
          if (res.statusCode >= 200 && res.statusCode < 300) {
            print("✅ WorkManager sent last location");
          } else {
            print("❌ WorkManager send failed: ${res.statusCode} ${res.body}");
          }
        } else {
          print("⚠️ No cached location found");
        }
      } catch (e) {
        print("❌ WorkManager error: $e");
      }
    }
    return Future.value(true);
  });
}

// =============== Core Service ===============
class LocationNotificationService with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionStream;
  Position? lastPosition;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _initLocation();
    await _initNotification();
  }

  // --------- Location ----------
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) await Geolocator.openLocationSettings();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
    print("📍 Location permission: $permission");

    try {
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lastPosition = current;
      await _cacheLastPosition(current);
      print("📍 Initial position: ${current.latitude}, ${current.longitude}");
    } catch (e) {
      print("❌ Error getting current position: $e");
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((pos) async {
          lastPosition = pos;
          await _cacheLastPosition(pos);
          print("🔄 Cached position: ${pos.latitude}, ${pos.longitude}");
        });
  }

  Future<void> _cacheLastPosition(Position pos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLastLat, pos.latitude.toStringAsFixed(6));
    await prefs.setString(kLastLng, pos.longitude.toStringAsFixed(6));
    await prefs.setString(kLastTs, DateTime.now().toIso8601String());
  }

  Future<void> sendLastLocationBeforeClose() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kAuthToken);
    final lat = prefs.getString(kLastLat);
    final lng = prefs.getString(kLastLng);
    final ts = prefs.getString(kLastTs);

    if (lat == null || lng == null) {
      print("❌ ไม่มีข้อมูล location ล่าสุด");
      return;
    }

    try {
      const url = "http://52.63.155.211/api/student/location";
      final res = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": lat,
          "longitude": lng,
          "timestamp": ts ?? DateTime.now().toIso8601String(),
        }),
      );

      if (res.statusCode == 200) {
        print("✅ Last location sent: ${res.body}");
      } else {
        print("❌ Failed: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      print("❌ Error sending last location: $e");
    }
  }

  // --------- Notification bootstrap (FCM token only) ----------
  Future<void> _initNotification() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    final token = await _fcm.getToken();
    print("📱 FCM Token: $token");
    // *อย่าสมัคร onMessage ที่นี่* — ให้ NotificationService เป็นคนดูแล
  }

  // --------- App lifecycle ----------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _scheduleSendLastLocationOnce();
    }
  }

  Future<void> _scheduleSendLastLocationOnce() async {
    try {
      await Workmanager().registerOneOffTask(
        _kTaskSendLastLocation,
        _kTaskSendLastLocation,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      print("📌 WorkManager scheduled");
    } catch (e) {
      print("⚠️ WorkManager failed, fallback direct send");
      await sendLastLocationBeforeClose();
    }
  }

  Future<void> stop() async {
    await _positionStream?.cancel();
    _positionStream = null;
    WidgetsBinding.instance.removeObserver(this);
  }
}
