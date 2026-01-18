import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './shared/constants.dart';


const _kTaskSendLastLocation = 'sendLastLocation';

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
          final apiUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
          final url = "$apiUrl/student/location";
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
        }
      } catch (e) {
      }
    }
    return Future.value(true);
  });
}


class LocationNotificationService with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionStream;
  Position? lastPosition;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _initLocation();
    await _initNotification();
  }

 
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

    try {
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lastPosition = current;
      await _cacheLastPosition(current);
    } catch (e) {
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
      return;
    }

    try {
      final apiUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
      final url = "$apiUrl/student/location";
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
    } catch (e) {
    }
  }

  Future<void> _initNotification() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    final token = await _fcm.getToken();
  }


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
    } catch (e) {
      await sendLastLocationBeforeClose();
    }
  }

  Future<void> stop() async {
    await _positionStream?.cancel();
    _positionStream = null;
    WidgetsBinding.instance.removeObserver(this);
  }
}
