import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  // เรียกตอน init
  Future<void> init() async {
    // ขอ permission (สำหรับ iOS / Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // ✅ รับ token ของ device
    String? token = await _fcm.getToken();
    print("FCM Token: $token");

    // ✅ ฟังตอนเปิดแอพอยู่ foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Got a message in foreground!");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
    });

    // ✅ ฟังตอน user กด notification แล้วเปิดแอพ (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 Notification clicked!");
      print("Data: ${message.data}");
    });

    // ✅ ฟังตอนเปิดแอพจาก terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print("📩 Opened from terminated!");
      print("Data: ${initialMessage.data}");
    }
  }
}
