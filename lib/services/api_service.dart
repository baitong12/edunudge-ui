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
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kAuthToken);
  }
  
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
    if (response.statusCode == 200) {   
      return {
        'status': 'success',
        'message': decoded['message'] ?? 'ยืนยัน OTP สำเร็จ',
      };
    } else if (response.statusCode == 400) {
      return {
        'status': 'error',
        'message': decoded['message'] ?? 'OTP ไม่ถูกต้องหรือหมดอายุ',
      };
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final token = data['token'];
      final user = data['user'];
      _registerDeviceToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token ?? '');
      await prefs.setInt(
        'role_id',int.tryParse(user['role_id'].toString()) ?? -1,
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
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'เข้าห้องเรียนไม่สำเร็จ');
    }
  }
  
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'สร้างห้องเรียนไม่สำเร็จ');
    }
  }
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
      return data['classrooms'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงรายการห้องเรียนได้');
    }
  }

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
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? device_token = await messaging.getToken();
    String? token = await getToken();
    if (device_token != null) {
      final response = await http.post(
        Uri.parse(
          "http://52.63.155.211/api/save-device-token",
        ), 
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "device_token": device_token,
          "platform": "android", 
        }),
      );
    }
  }

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
      return data;
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงสรุปการเข้าเรียนได้');
    }
  }

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
        return data;
      } else if (data is Map && data.containsKey('students')) {
        return data['students'] ?? [];
      } else {
        throw Exception('โครงสร้างข้อมูลไม่ถูกต้อง');
      }
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถดึงสรุปการเข้าเรียนได้');
    }
  }

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
        return data; 
      } else if (data is Map && data.containsKey('students')) {
        return data['students'] ?? [];
      } else {
        throw Exception('โครงสร้างข้อมูลไม่ถูกต้อง');
      }
    } else {
      throw Exception(
        data['message'] ?? 'ไม่สามารถดึงรายชื่อนักศึกษา At Risk ได้',
      );
    }
  }

  static Future<List<dynamic>> getWeeklyAttendanceSummary({
    required int classroomId,
    List<int>? weeks, 
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');

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

  static Future<Map<String, dynamic>> updateWarnTimes(
    int classroomId, {
    String? warnGreen,
    String? warnRed,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');
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
      return data; 
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดต warn times ได้');
    }
  }

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
        'status': status, 
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; 
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตสถานะห้องเรียนได้');
    }
  }

  static Future<Map<String, dynamic>> updateHolidays(
    int classroomId,
    List<DateTime> holidays,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('Token ไม่พบ กรุณาล็อกอินก่อน');
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
      return data; 
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถอัปเดตวันหยุดได้');
    }
  }

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
    } else {
      throw Exception(data['message'] ?? 'ไม่สามารถลบห้องเรียนได้');
    }
  }
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
        return {
          "status": "not_found",
        };
      } else {
        return {
          "status": "error",
          "messagae": data['message'],
        };
      }
    } catch (e) {
      rethrow;
    }
  }
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
      return {
        "warnGreen": data['warn_green'] ?? 0,
        "warnRed": data['warn_red'] ?? 0,
        "status": data['status'] ?? 1, 
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
}
