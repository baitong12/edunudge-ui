import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // =======================
  // ✅ Login
  // =======================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _registerDeviceToken();

      // เก็บ token และ user info ใน SharedPreferences
      final token = data['token'];
      final user = data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token ?? '');
      await prefs.setInt(
          'role_id', int.tryParse(user['role_id'].toString()) ?? -1);
      await prefs.setInt('user_id', user['id'] ?? -1);
      await prefs.setString('user_name', user['name'] ?? '');
      await prefs.setString('user_lastname', user['lastname'] ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_phone', user['phone'] ?? '');
      await prefs.setInt('department_id', user['department_id'] ?? -1);

      return data;
    } else {
      throw Exception(
          data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ (${response.statusCode})');
    }
  }

  // =======================
  // ✅ Logout
  // =======================
  static Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Logout ล้มเหลว: ${response.statusCode}');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // =======================
  // ✅ ดึง token จาก SharedPreferences
  // =======================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  // =======================
  // ✅ เข้าร่วมห้องเรียน (Student)
  // =======================
  static Future<Map<String, dynamic>> joinClassroom(String code) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.post(
      Uri.parse('$baseUrl/student/classrooms/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code}),
    );

    // Debug log
    print('Join Classroom Status: ${response.statusCode}');
    print('Join Classroom Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'เข้าห้องเรียนไม่สำเร็จ');
    }
  }

  // =======================
  // ✅ สร้างห้องเรียน (Teacher)
  // =======================
  static Future<Map<String, dynamic>> createClassroom(
      Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.post(
      Uri.parse('$baseUrl/teacher/classrooms/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    // Debug log
    print('Create Classroom Status: ${response.statusCode}');
    print('Create Classroom Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'สร้างห้องเรียนไม่สำเร็จ');
    }
  }

  // ✅ ดึงรายละเอียดห้องเรียน (Student)
  static Future<Map<String, dynamic>> getClassroomDetail(
      int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/classrooms/$classroomId/detail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูลห้องเรียนได้');
    }
  }

// =======================
// ✅ ดึงรายการห้องเรียนของ Student
// =======================
  static Future<List<dynamic>> getStudentClassrooms() async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/classrooms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // ถ้าไม่มีห้องเรียน ให้คืน empty list
      return data['classrooms'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงรายการห้องเรียนได้');
    }
  }

// ✅ ดึงข้อมูล Home ของอาจารย์
  static Future<Map<String, dynamic>> getTeacherHome() async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/teacher/home'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูล Home ได้');
    }
  }

  // ✅ ดึงรายละเอียดห้องเรียนสำหรับ Teacher
  static Future<Map<String, dynamic>> getTeacherClassroomDetail(
      int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/teacher/classroom/$classroomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(
          data['message'] ?? 'ไม่สามารถดึงข้อมูลห้องเรียนอาจารย์ได้');
    }
  }

// =======================
// ✅ ดึงข้อมูล Home ของ Student (สถิติการเข้าเรียน)
// =======================
  static Future<Map<String, dynamic>> getStudentHome() async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/home'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // คืนค่าเป็น Map<String, dynamic
      return {
        'present': data['present'] ?? 0.0,
        'late': data['late'] ?? 0.0,
        'absent': data['absent'] ?? 0.0,
        'leave': data['leave'] ?? 0.0,
      };
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูล Home นักศึกษาได้');
    }
  }

// =======================
// ✅ ดึงรายละเอียดรายวิชา (Student)
// =======================
  static Future<Map<String, dynamic>> getSubjectDetail(int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/classrooms/$classroomId/detail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'name_subject': data['name_subject'] ?? '',
        'room_number': data['room_number'] ?? '',
        'teacher_name': data['teacher_name'] ?? '',
        'department': data['department'] ?? '',
        'contact': data['contact'] ?? '',
      };
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูลรายวิชาได้');
    }
  }

  static Future<void> _registerDeviceToken() async {
    // ✅ ขอ device token จาก Firebase
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    print("FCM Device Token: $token");

    if (token != null) {
      // ✅ ส่ง token ไปเก็บที่ Laravel API
      final response = await http.post(
        Uri.parse(
            "http://127.0.0.1:8000/api/save-device-token"), // เปลี่ยน URL ให้ตรงกับ backend
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": 53, // ส่ง user_id ของนักศึกษา/อาจารย์
          "device_token": token, // ✅ token ที่ได้จาก Firebase
          "platform": "android" // หรือ "ios"
        }),
      );

      if (response.statusCode == 200) {
        print("Token registered: ${response.body}");
      } else {
        print("Failed to register token: ${response.body}");
      }
    }
  }

  // =======================
// ✅ ดึงรายละเอียดห้องเรียน (Teacher version)
// =======================
static Future<Map<String, dynamic>> getClassroomDetailTeacher(int classroomId) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.get(
    Uri.parse('$baseUrl/teacher/classrooms/$classroomId/detail'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูลห้องเรียนอาจารย์ได้');
  }
}

// =======================
// ✅ ลบนักศึกษาออกจากห้องเรียน
// =======================
static Future<void> removeStudent(int classroomId, int userId) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.delete(
    Uri.parse('$baseUrl/teacher/classrooms/$classroomId/remove-student/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  final data = jsonDecode(response.body);
  if (response.statusCode != 200) {
    throw Exception(data['message'] ?? 'ไม่สามารถลบนักศึกษาได้');
  }
}

// =======================
// ✅ เช็คชื่อ (Mark Attendance)
// =======================
static Future<Map<String, dynamic>> markAttendance({
  required int userId,
  required int classroomId,
  required String status, // "present" | "late" | "leave" | "absent"
}) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.post(
    Uri.parse('$baseUrl/teacher/classrooms/attendance'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode({
      'user_id': userId,
      'classroom_id': classroomId,
      'status': status,
    }),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception(data['message'] ?? 'เช็คชื่อไม่สำเร็จ');
  }
}

static Future<Map<String, dynamic>> updateWarnTimes(
    int classroomId, {
    String? warnGreen,
    String? warnYellow,
    String? warnRed,
  }) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.put(
    Uri.parse('$baseUrl/teacher/classrooms/$classroomId/warn-times'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'warn_green': warnGreen,
      'warn_yellow': warnYellow,
      'warn_red': warnRed,
    }),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตเวลาการแจ้งเตือนได้');
  }
}

static Future<int> updateClassroomStatus(int classroomId, int status) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.put(
    Uri.parse('$baseUrl/teacher/classrooms/$classroomId/status'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'status': status}),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return data['status'];
  } else {
    throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตสถานะห้องเรียนได้');
  }
}

static Future<List<dynamic>> updateHolidays(int classroomId, List<String> holidays) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.put(
    Uri.parse('$baseUrl/teacher/classrooms/$classroomId/holidays'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'holidays': holidays}),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return List<String>.from(data['holidays'] ?? []);
  } else {
    throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตวันหยุดได้');
  }
}

static Future<void> deleteClassroom(int classroomId) async {
  final token = await getToken();
  if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  final response = await http.delete(
    Uri.parse('$baseUrl/teacher/classrooms/$classroomId'),
    headers: {
      'Content-Type': 'applicationุ/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'ไม่สามารถลบห้องเรียนได้');
  }
}

}
