// main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:edunudge/services/firebase_messaging.dart';

// ✅ Providers
import 'providers/profile_provider.dart';

// ✅ Auth Pages
import 'auth/login.dart';
import 'auth/register01.dart';
import 'auth/register02.dart';
import 'auth/forgot_password.dart';
import 'auth/reset_password.dart';

// ✅ Shared
import 'shared/profile.dart';

// ✅ Student Pages
import 'pages/student/home.dart';
import 'pages/student/attendance.dart';
import 'pages/student/classroom.dart';
import 'pages/student/join_class.dart';
import 'pages/student/subject.dart';

// ✅ Teacher Pages
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

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const EduNudgeApp(),
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
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      locale: const Locale('th'),
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/login',
      routes: {
        // 🔐 Authentication
        '/login': (context) => const Login(),
        '/register01': (context) => Register01(),
        '/register02': (context) => Register02(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/reset_password': (context) => const ResetPassword(),

        // 👤 Shared
        '/profile': (context) => const ProfilePage(),

        // 👨‍🎓 Student
        '/home_student': (context) => const Home(),
        '/join-classroom': (context) => const ClassroomJoin(),
        '/classroom': (context) => const Classroom(),
        '/attendance': (context) => const Attendance(),

        // 👩‍🏫 Teacher
        '/home_teacher': (context) => const HomePage(),
        '/classroom_create01': (context) => const CreateClassroom01(),
        '/classroom_create02': (context) => const CreateClassroom02(),
        '/classroom_create03': (context) => const CreateClassroom03(),
        '/classroom_create04': (context) => const CreateClassroom04(),
        '/classroom_settings': (context) => ClassroomSettingsPage(),


        
        '/classroom_report_summarize': (context) =>
            const ReportBsummarizePage(),
      },
      onGenerateRoute: (settings) {
        // สำหรับหน้าที่ต้องรับ arguments

        if (settings.name == '/subject') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => Subject(
              classroomId: int.tryParse(args['id'] ?? '') ?? 0,
            ),
          );
        }

        if (settings.name == '/classroom_subject') {
          final classroomId = settings.arguments as int; // รับเป็น int
          return MaterialPageRoute(
            builder: (context) => ClassroomSubject(classroomId: classroomId),
          );
        }

        if (settings.name == '/classroom_check') {
          final classroomId = settings.arguments as int; // รับ classroomId
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
        if (settings.name == '/classroom_report_student') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => StudentReportPage(classroomId: classroomId),
          );
        }
        if (settings.name == '/classroom_report_becareful') {
          final classroomId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ReportBecarefulPage(classroomId: classroomId),
          );
        }
        return null;
      },
    );
  }
}
