
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:edunudge/services/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';

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
import 'package:workmanager/workmanager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final locationService = LocationNotificationService();
final notificationService = NotificationService();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<bool> requestLocationPermissionAtStartup() async {

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    await Geolocator.openLocationSettings();

  }


  var permission = await Geolocator.checkPermission();


  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }


  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
    return false;
  }


  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  await initializeDateFormatting('th');


  await dotenv.load(fileName: ".env");


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await requestLocationPermissionAtStartup();

  
  await Workmanager().initialize(
    lastLocationWorkmanagerDispatcher,
    isInDebugMode: false, 
  );


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ProfileProvider())],
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
      debugShowCheckedModeBanner: false,
      title: 'EduNudge',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      locale: const Locale('th'),
      supportedLocales: const [Locale('en'), Locale('th')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      initialRoute: '/',
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


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationService.init();
      await notificationService.init();
    });


    Timer(const Duration(seconds: 1), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final roleId = prefs.getInt('role_id');

        if (roleId == 2) {
          Navigator.of(context).pushReplacementNamed('/home_teacher');
        } else {
          Navigator.of(context).pushReplacementNamed('/home_student');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
