import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; // ✅ เพิ่ม

// 🔧 เพิ่ม Provider ของคุณ
import 'providers/profile_provider.dart';

// ไฟล์อื่นๆ
import 'auth/login.dart';
import 'auth/register01.dart';
import 'auth/register02.dart';
import 'auth/reset_password.dart';
import 'auth/forgot_password.dart';

import 'shared/profile.dart';

import 'pages/student/home.dart';
import 'pages/student/attendance.dart';
import 'pages/student/classroom.dart';
import 'pages/student/join_class.dart';
import 'pages/student/subject.dart';

import 'pages/teacher/home.dart';
import 'pages/teacher/classroom_create.dart';
import 'pages/teacher/classroom_settings.dart';
import 'pages/teacher/classroom_subject.dart';
import 'pages/teacher/classroom_check.dart';
import 'pages/teacher/classroom_report.dart';
import 'pages/teacher/classroom_report_student.dart';
import 'pages/teacher/classroom_report_becareful.dart';
import 'pages/teacher/classroom_report_summarize.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th');

  // ✅ ห่อแอปด้วย MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const Edunudge(),
    ),
  );
}

class Edunudge extends StatelessWidget {
  const Edunudge({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduNudge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
      ],
      initialRoute: '/login',
      routes: {
        //ใช้ร่วมกัน
        '/login': (context) => const Login(),
        '/register01': (context) => Register01(),
        '/register02': (context) => Register02(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/reset_password': (context) => const ResetPassword(),

        '/profile': (context) => Profile(),

        //นักเรียน
        '/home_student': (context) => Home(),
        '/join-classroom': (context) => ClassroomJoin(),
        '/classroom': (context) => Classroom(),
        '/attendance': (context) => Attendance(),

        //อาจารย์
        '/home_teacher': (context) => HomePage(),
        '/classroom_create': (context) => const CreateClassroom(),
        '/classroom_settings': (context) => ClassroomSettingsPage(),
        '/classroom_subject': (context) => const ClassroomSubject(),
        '/classroom_check': (context) => const AttendancePage(),
        '/classroom_report': (context) => const ReportMenuPage(),
        '/classroom_report_student': (context) => const StudentReportPage(),
        '/classroom_report_becareful': (context) => const ReportBecarefulPage(),
        '/classroom_report_summarize': (context) => const ReportBsummarizePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/subject') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => Subject(
              subject: args['subject'] ?? '',
              room: args['room'] ?? '',
              teacher: args['teacher'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}
