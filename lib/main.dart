import 'dart:async';  
// ใช้สำหรับ Timer, Future, Stream

import 'package:flutter/material.dart';  
// ใช้สำหรับ UI หลักตาม Material Design

import 'package:flutter/services.dart';  
// ใช้ควบคุม system UI เช่น ซ่อน status bar

import 'package:intl/date_symbol_data_local.dart';  
// ใช้จัดการข้อมูลวันที่/เวลา (เช่น ภาษาไทย)

import 'package:flutter_localizations/flutter_localizations.dart';  
// ใช้รองรับหลายภาษา (localization)

import 'package:provider/provider.dart';  
// ใช้ state management (Provider pattern)

import 'package:edunudge/services/firebase_messaging.dart';  
// import ไฟล์บริการ firebase messaging (ที่เขียนเอง)

import 'package:shared_preferences/shared_preferences.dart';  
// ใช้เก็บค่า key-value แบบ local storage เช่น token, role_id

import 'package:flutter_dotenv/flutter_dotenv.dart';  
// ใช้โหลด environment variable จากไฟล์ .env

import 'package:firebase_core/firebase_core.dart';  
// ใช้ initialize Firebase

import 'package:firebase_auth/firebase_auth.dart';  
// ใช้ระบบ login/register ของ Firebase Authentication

import 'package:firebase_messaging/firebase_messaging.dart';  
// ใช้สำหรับ push notification (FCM)

import 'package:overlay_support/overlay_support.dart';  
// ใช้แสดง notification แบบ overlay (pop-up บนหน้าจอ)


// 🔹 import ไฟล์ภายในโปรเจค
import 'firebase_options.dart';  
import 'location_service.dart';  
import 'providers/profile_provider.dart';  
import 'shared/splash_screen.dart';  
import 'auth/login.dart';  
import 'auth/register01.dart';  
import 'auth/register02.dart';  
import 'auth/forgot_password.dart';  
import 'auth/reset_password.dart';  
import 'shared/profile.dart';  
import 'pages/student/home.dart';  
import 'pages/student/attendance.dart';  
import 'pages/student/classroom.dart';  
import 'pages/student/join_class.dart';  
import 'pages/student/subject.dart';  
import 'pages/teacher/home.dart';  
import 'pages/teacher/classroom_cerate01.dart';  
import 'pages/teacher/classroom_cerate02.dart';  
import 'pages/teacher/classroom_cerate03.dart';  
import 'pages/teacher/classroom_cerate04.dart';  
import 'pages/teacher/classroom_settings.dart';  
import 'pages/teacher/classroom_subject.dart';  
import 'pages/teacher/classroom_check.dart';  
import 'pages/teacher/classroom_report.dart';  
import 'pages/teacher/classroom_report_student.dart';  
import 'pages/teacher/classroom_report_becareful.dart';  
import 'pages/teacher/classroom_report_summarize.dart';  

import 'package:geolocator/geolocator.dart';  
// ใช้ดึงตำแหน่ง GPS

import 'package:workmanager/workmanager.dart';  
// ใช้ schedule งาน background เช่นส่ง location แม้ปิดแอป


// ตัวแปร global key ใช้ควบคุม Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// สร้าง instance ของ service ต่าง ๆ
final locationService = LocationNotificationService();
final notificationService = NotificationService();


// handler สำหรับ push notification ที่มาจาก background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}


// ฟังก์ชันขอ permission location ตอนเปิดแอป
Future<bool> requestLocationPermissionAtStartup() async {

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();  // ถ้าไม่เปิด GPS → เปิด settings
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission(); // ถ้า denied ขอใหม่
  }

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings(); // ถ้าโดนบล็อกถาวร → ไปเปิดใน app settings
    return false;
  }

  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;  
  // return true ถ้าได้สิทธิ์ใช้งาน
}


// ฟังก์ชัน main เริ่มต้นแอป
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  // ให้ Flutter รอการ initialize ทุกอย่างก่อน

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);  
  // ซ่อน status bar + navigation bar

  await initializeDateFormatting('th');  
  // ใช้ข้อมูลวันที่ภาษาไทย

  await dotenv.load(fileName: ".env");  
  // โหลดค่าจากไฟล์ .env

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  
  // initialize Firebase

  await requestLocationPermissionAtStartup();  
  // ขอสิทธิ์ GPS

  await Workmanager().initialize(
    lastLocationWorkmanagerDispatcher,  // ฟังก์ชัน entrypoint ของ background task
    isInDebugMode: false,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);  
  // handle push notification ตอนแอปอยู่ background

  runApp(
    OverlaySupport.global(  
      // เปิดระบบ overlay สำหรับ push notification
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ProfileProvider())],  
        // ใช้ Provider จัดการ state โปรไฟล์ผู้ใช้
        child: const EduNudgeApp(),
      ),
    ),
  );
}


class EduNudgeApp extends StatelessWidget {
  const EduNudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // เอาแถบ debug ออก
      title: 'EduNudge',  // ชื่อแอป
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),  
      // ธีมของแอป
      locale: const Locale('th'),  // ภาษาเริ่มต้น = ไทย
      supportedLocales: const [Locale('en'), Locale('th')],  
      // รองรับอังกฤษ/ไทย
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,  
      // ใช้ global key นำทาง
      initialRoute: '/',  
      // route แรกคือ splash screen

      // 🔹 map routes ไปยังแต่ละหน้า
      routes: {
        '/': (context) => const SplashScreenWrapper(),
        '/login': (context) => const Login(),
        '/register01': (context) => Register01(),
        '/register02': (context) => Register02(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/reset_password': (context) => const ResetPassword(),
        '/profile': (context) => const ProfilePage(),
        '/home_student': (context) => const Home(),
        '/join-classroom': (context) => const ClassroomJoin(),
        '/classroom': (context) => const Classroom(),
        '/attendance': (context) => const Attendance(),
        '/home_teacher': (context) => const HomePage(),
        '/classroom_create01': (context) => const CreateClassroom01(),
        '/classroom_create02': (context) => const CreateClassroom02(),
        '/classroom_create03': (context) => const CreateClassroom03(),
        '/classroom_create04': (context) => const CreateClassroom04(),
      },

      // handle route ที่ต้องส่ง arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/subject') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) =>
                Subject(classroomId: int.tryParse(args['id'] ?? '') ?? 0),
          );
        }
        if (settings.name == '/classroom_subject') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ClassroomSubject(classroomId: classroomId),
          );
        }
        if (settings.name == '/classroom_check') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => AttendancePage(classroomId: classroomId),
          );
        }
        if (settings.name == '/classroom_report') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ReportMenuPage(classroomId: classroomId),
          );
        }
        if (settings.name == '/classroom_report_summarize') {
          final args = settings.arguments as Map<String, dynamic>;
          final classroomId = args['classroomId'] as int;
          final atRiskList = args['atRiskList'] as List<String>;
          return MaterialPageRoute(
            builder: (context) => ReportBsummarizePage(
              classroomId: classroomId,
              atRiskList: atRiskList,
            ),
          );
        }
        if (settings.name == '/classroom_report_becareful') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ReportBecarefulPage(classroomId: classroomId),
          );
        }
        if (settings.name == '/classroom_report_student') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => StudentReportPage(classroomId: classroomId),
          );
        }
        if (settings.name == '/classroom_settings') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                ClassroomSettingsPage(classroomId: classroomId),
          );
        }
        return null;
      },
    );
  }
}


// 🔹 Wrapper ของ SplashScreen
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  final LocationNotificationService locationService =
      LocationNotificationService();

  @override
  void initState() {
    super.initState();

    // รันหลังจาก build เสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationService.init();       // init GPS service
      await notificationService.init();   // init Notification service
    });

    // หน่วงเวลา 1 วินาที แล้วตรวจ user
    Timer(const Duration(seconds: 1), () async {
      final user = FirebaseAuth.instance.currentUser;  
      // ตรวจว่ามี user login อยู่มั้ย
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final roleId = prefs.getInt('role_id');  
        // ดึง role_id จาก local storage

        if (roleId == 2) {
          Navigator.of(context).pushReplacementNamed('/home_teacher');  
          // ถ้า role = teacher
        } else {
          Navigator.of(context).pushReplacementNamed('/home_student');  
          // ถ้า role = student
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');  
        // ถ้าไม่มี user → ไปหน้า login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();  
    // แสดง splash screen
  }
}
