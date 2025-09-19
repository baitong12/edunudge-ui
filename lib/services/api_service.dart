import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../shared/constants.dart';

class ApiService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
  static final String apiKey = dotenv.env['API_KEY'] ?? "";
  // ดึง token จาก SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kAuthToken);
  }
  // อัปเดตข้อมูล profile
  static Future<Map<String, dynamic>> updateData(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/profile/update-data');
    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    print('Response body: ${decoded.toString()}');
    print('Raw response: ${response.body}');

    if (response.statusCode == 200) {
      return {
        'status': 'success',
        'message': decoded['message'] ?? 'อัปเดตสำเร็จ',
      };
    } else {
      return {
        'status': 'error',
        'message': decoded['message'] ?? 'เกิดข้อผิดพลาด',
      };
    }
  }

  // ยืนยัน OTP
  static Future<Map<String, dynamic>> confirmOtp(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/profile/confirmOtp');
    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);
    print("Confirm OTP Response: $decoded"); // ✅ debug log

    if (response.statusCode == 200) {
      // สมมติ backend ส่ง {"status":"success","message":"OTP ถูกต้อง"}
      return {
        'status': 'success',
        'message': decoded['message'] ?? 'ยืนยัน OTP สำเร็จ',
      };
    } else if (response.statusCode == 400) {
      // สมมติ backend ส่ง {"status":"error","message":"OTP ไม่ถูกต้อง"}
      return {
        'status': 'error',
        'message': decoded['message'] ?? 'OTP ไม่ถูกต้องหรือหมดอายุ',
      };
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  // =======================
  // ✅ Login
  // =======================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('Response status: ${jsonDecode(response.body)}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // เก็บ token และ user info ใน SharedPreferences
      final token = data['token'];
      final user = data['user'];
      _registerDeviceToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token ?? '');
      await prefs.setInt(
        'role_id',
        int.tryParse(user['role_id'].toString()) ?? -1,
      );
      await prefs.setInt('user_id', user['id'] ?? -1);
      await prefs.setString('user_name', user['name'] ?? '');
      await prefs.setString('user_lastname', user['lastname'] ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_phone', user['phone'] ?? '');
      await prefs.setInt('department_id', user['department_id'] ?? -1);

      return data;
    } else {
      throw Exception(
        data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ (${response.statusCode})',
      );
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
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Logout ล้มเหลว: ${response.statusCode}');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
    Map<String, dynamic> body,
  ) async {
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
    int classroomId,
  ) async {
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
      return data;
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูลห้องเรียนได้');
    }
  }

  // =======================
  // ✅ ดึงห้องเรียนของ Student
  // =======================
  static Future<List<dynamic>> getStudentClassrooms() async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/getClassroomsList'),
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
    int classroomId,
  ) async {
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
        data['message'] ?? 'ไม่สามารถดึงข้อมูลห้องเรียนอาจารย์ได้',
      );
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
    String? device_token = await messaging.getToken();
    String? token = await getToken();
    print("FCM Device Token: $device_token");

    if (device_token != null) {
      // ✅ ส่ง token ไปเก็บที่ Laravel API
      final response = await http.post(
        Uri.parse(
          "http://52.63.155.211/api/save-device-token",
        ), // เปลี่ยน URL ให้ตรงกับ backend
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "device_token": device_token, // ✅ token ที่ได้จาก Firebase
          "platform": "android", // หรือ "ios"
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
  // ✅ ลบนักศึกษาออกจากห้องเรียน
  // =======================
  static Future<void> removeStudent(int classroomId, int userId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.delete(
      Uri.parse('$baseUrl/teacher/classroom/$classroomId/student/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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
      Uri.parse('$baseUrl/teacher/attendance/mark'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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

  // =======================
  // ✅ ดึงสรุปการเข้าเรียนของ Student ตาราง home น้อย
  // =======================
  static Future<Map<String, dynamic>> homeAttendanceSummary() async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/attendance-summary'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // data ตัวอย่าง:
      // {
      //   "classrooms": [{ "classroom_id": 1, "name_subject": "Math", "present": 5, "late": 1, "absent": 0, "leave_count": 0, "percent": 83.33 }, ...],
      //   "totals": { "present": 15, "late": 3, "absent": 2, "leave": 1 }
      // }
      return data;
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงสรุปการเข้าเรียนได้');
    }
  }

  // =======================
  // ✅ ดึงรายละเอียดรายวิชาแบบ Student เลือกรายละเอียด home น้อย
  // =======================
  static Future<Map<String, dynamic>> homeSubjectDetail(int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/student/subject-detail/$classroomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // map ให้ตรงกับ JSON ที่ backend ส่งกลับ
      return {
        'name_subject': data['name_subject'] ?? '',
        'room_number': data['room_number'] ?? '',
        'teacher_name': data['teacher_name'] ?? '',
        'department': data['department'] ?? '',
        'faculty': data['faculty'] ?? '',
        'contact': data['contact'] ?? '',
      };
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงข้อมูลรายวิชาได้');
    }
  }

  // =======================
  // ✅ ดึงสรุปการเข้าเรียนของนักศึกษาในห้องเรียน
  // =======================
  static Future<List<dynamic>> studentAttendanceSummary(int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/classrooms/$classroomId/attendance-summary'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        // ✅ กรณี backend ส่ง array ตรง ๆ
        return data;
      } else if (data is Map && data.containsKey('students')) {
        // ✅ กรณี backend ห่อ array ใน key "students"
        return data['students'] ?? [];
      } else {
        throw Exception('โครงสร้างข้อมูลไม่ถูกต้อง');
      }
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงสรุปการเข้าเรียนได้');
    }
  }

  // =======================
  // ✅ ดึงรายชื่อนักศึกษา At Risk ของห้องเรียน (Teacher)
  // =======================
  static Future<List<dynamic>> getAtRiskStudents(int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/classrooms/$classroomId/student-atrisk'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data; // ✅ ถ้า backend ส่ง array ตรง ๆ
      } else if (data is Map && data.containsKey('students')) {
        return data['students'] ?? []; // ✅ ถ้า backend ห่อด้วย key
      } else {
        throw Exception('โครงสร้างข้อมูลไม่ถูกต้อง');
      }
    } else {
      throw Exception(
        data['message'] ?? 'ไม่สามารถดึงรายชื่อนักศึกษา At Risk ได้',
      );
    }
  }

  // =======================
  // ✅ ดึงสรุปการเข้าเรียนรายสัปดาห์
  // =======================
  static Future<List<dynamic>> getWeeklyAttendanceSummary({
    required int classroomId,
    List<int>? weeks, // ตัวเลือกว่าจะเอาสัปดาห์ไหนบ้าง
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    // สร้าง query string ถ้ามี weeks
    String queryString = '';
    if (weeks != null && weeks.isNotEmpty) {
      queryString = '?weeks=${weeks.join(',')}';
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/classrooms/$classroomId/weekly-attendance-summary$queryString',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      } else {
        throw Exception('โครงสร้างข้อมูลไม่ถูกต้อง');
      }
    } else {
      throw Exception(
        data['message'] ?? 'ไม่สามารถดึงสรุปการเข้าเรียนรายสัปดาห์ได้',
      );
    }
  }

  // =======================
  // ✅ อัปเดตเวลาการแจ้งเตือนของห้องเรียน (warn times)
  // =======================
  static Future<Map<String, dynamic>> updateWarnTimes(
    int classroomId, {
    String? warnGreen,
    String? warnRed,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    // แปลง string เป็น int
    final int? warnGreenInt = warnGreen != null
        ? int.tryParse(warnGreen)
        : null;
    final int? warnRedInt = warnRed != null ? int.tryParse(warnRed) : null;

    final response = await http.put(
      Uri.parse('$baseUrl/classrooms/$classroomId/settings/warn-times'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (warnGreenInt != null) 'warn_green': warnGreenInt,
        if (warnRedInt != null) 'warn_red': warnRedInt,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // คืนค่า JSON response จาก backend
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดต warn times ได้');
    }
  }

  // =======================
  // ✅ อัปเดตสถานะห้องเรียน (เปิด/ปิด)
  // =======================
  static Future<Map<String, dynamic>> updateClassroomStatus(
    int classroomId,
    int status,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.put(
      Uri.parse('$baseUrl/classrooms/$classroomId/settings/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status, // 1 = เปิด, 0 = ปิด
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // {"message": "...", "status": 1}
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตสถานะห้องเรียนได้');
    }
  }

  // =======================
  // ✅ อัปเดตวันหยุดของห้องเรียน
  // =======================
  static Future<Map<String, dynamic>> updateHolidays(
    int classroomId,
    List<DateTime> holidays,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    // แปลง List<DateTime> เป็น List<String "yyyy-MM-dd")
    final holidayStrings = holidays
        .map((d) => d.toIso8601String().split('T').first)
        .toList();

    final response = await http.put(
      Uri.parse('$baseUrl/classrooms/$classroomId/settings/holidays'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'holidays': holidayStrings}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // {"message": "...", "holidays": [...]}
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตวันหยุดได้');
    }
  }

  // =======================
  // ✅ ลบห้องเรียน (Teacher)
  // =======================
  static Future<void> deleteClassroom(int classroomId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.delete(
      Uri.parse('$baseUrl/classrooms/$classroomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // ลบสำเร็จ
      print('Delete Classroom Success: ${data['message']}');
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถลบห้องเรียนได้');
    }
  }

  // ดึง location classroom
  // static Future<Map<String, dynamic>> getLocationClassroom() async {
  //   final token = await getToken();
  //   if (token == null){
  //     return {"status": 'error','message': 'Token ไม่พบ กรุณาล็อกอินก่อน'};
  //   }

  //   final response = await http.get(
  //     Uri.parse('$baseUrl/student/getLocation'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   final data = jsonDecode(response.body);

  //   if (response.statusCode == 200) {
  //     // ✅ แปลงเป็น String
  //     final String latitude = data['latitude'].toString();
  //     final String longitude = data['longitude'].toString();

  //     // ✅ เก็บตำแหน่งล่าสุดลง SharedPreferences เป็น String
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('last_latitude', latitude);
  //     await prefs.setString('last_longitude', longitude);

  //     return {
  //       "classroom_id": data['classroom_id'],
  //       "latitude": latitude,
  //       "longitude": longitude,
  //     };
  //   } else {
  //     throw Exception(data['message'] ?? 'Cant get classroom Position');
  //   }
  // }
  static Future<Map<String, dynamic>> getLocationClassroom() async {
    final token = await getToken();
    if (token == null) {
      return {"status": 'error', 'message': 'Token ไม่พบ กรุณาล็อกอินก่อน'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/getLocation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ ป้องกัน null หรือ type mismatch

        final String latitude = data['latitude']?.toString() ?? '';
        final String longitude = data['longitude']?.toString() ?? '';

        return {
          "status": "success",
          "classroom_id": data['classroom_id'],
          "name_subject": data['name_subject'], 
          "latitude": latitude,
          "longitude": longitude,
        };
      } else if (response.statusCode == 404) {
        print('getLocationClassroom Not Found $data["message"] ');
        return {
          "status": "not_found",
        };
      } else {
        print('getLocationClassroom Error: $data["message"] ');
        return {
          "status": "error",
          "messagae": data['message'],
        };
      }
    } catch (e) {
      // ✅ log error เพื่อ debug
      print("Error getLocationClassroom: $e");
      rethrow;
    }
  }

  // =======================
  // ✅ ดึงการตั้งค่าห้องเรียน (Teacher หรือ Student)
  // =======================
  static Future<Map<String, dynamic>> getClassroomSettings(
    int classroomId,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.get(
      Uri.parse('$baseUrl/classrooms/$classroomId/settings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // สมมติ backend ส่งข้อมูลแบบนี้:
      // {
      //   "warn_green": 5,
      //   "warn_red": 10,
      //   "status": 1,
      //   "holidays": ["2025-09-05", "2025-09-12"]
      // }
      return {
        "warnGreen": data['warn_green'] ?? 0,
        "warnRed": data['warn_red'] ?? 0,
        "status": data['status'] ?? 1, // 1 = เปิด, 0 = ปิด
        "holidays":
            (data['holidays'] as List<dynamic>?)
                ?.map((e) => DateTime.parse(e))
                .toList() ??
            [],
      };
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงการตั้งค่าห้องเรียนได้');
    }
  }

  // =======================
  // ✅ อัปเดตชื่อวิชาและเลขห้อง
  // =======================
  // static Future<Map<String, dynamic>> updateClassroomInfo(
  //     int classroomId, {
  //     required String subjectName,
  //     required String roomNumber,
  //   }) async {
  //   final token = await getToken();
  //   if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

  //   final response = await http.put(
  //     Uri.parse('$baseUrl/teacher/classrooms/$classroomId/update-info'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: jsonEncode({
  //       'name_subject': subjectName,
  //       'room_number': roomNumber,
  //     }),
  //   );

  //   final data = jsonDecode(response.body);

  //   if (response.statusCode == 200) {
  //     return {'status': 'success',
  //             'message': data['message'] ?? 'อัปเดตสำเร็จ'};
  //   } else {
  //     throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตข้อมูลห้องเรียนได้');
  //   }
  // }

  static Future<Map<String, dynamic>> updateSubjectName(
    int classroomId,
    String subjectName,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.put(
      Uri.parse('$baseUrl/classrooms/$classroomId/subject'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name_subject': subjectName}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'status': 'success',
        'message': data['message'] ?? 'อัปเดตชื่อวิชาสำเร็จ',
        'name_subject': data['name_subject'],
      };
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตชื่อวิชาได้');
    }
  }

  static Future<Map<String, dynamic>> updateRoomNumber(
    int classroomId,
    String roomNumber,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

    final response = await http.put(
      Uri.parse('$baseUrl/classrooms/$classroomId/room-number'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'room_number': roomNumber}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'status': 'success',
        'message': data['message'] ?? 'อัปเดตเลขห้องสำเร็จ',
        'room_number': data['room_number'],
      };
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตเลขห้องได้');
    }
  }
}
