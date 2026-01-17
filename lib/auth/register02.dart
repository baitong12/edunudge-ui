// นำเข้า Flutter Material library สำหรับสร้าง UI
import 'package:flutter/material.dart'; // ส่วนประกอบ UI พื้นฐานของ Flutter

// นำเข้า HTTP package สำหรับทำ API request (POST, GET)
import 'package:http/http.dart' as http; // ใช้สำหรับการเรียกใช้บริการ API (Backend communication)

// นำเข้า JSON encoder/decoder สำหรับแปลงข้อมูล
import 'dart:convert'; // ใช้สำหรับแปลง Object/Map เป็น JSON String (jsonEncode) และแปลงกลับ (jsonDecode)

// นำเข้า dotenv สำหรับอ่าน environment variables เช่น API URL
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ใช้จัดการค่า Config เช่น API Endpoint โดยแยกออกจากโค้ดหลัก

// สร้าง StatefulWidget สำหรับหน้าลงทะเบียน Register02
class Register02 extends StatefulWidget {
  // Register02 คือคลาส Widget ที่มีสถานะ (State) เปลี่ยนแปลงได้
  @override
  State<Register02> createState() => _Register02State();
  // createState() สร้าง state object สำหรับจัดการสถานะและ logic ของ Widget
}

// State class ของ Register02
class _Register02State extends State<Register02> {

  // baseUrl อ่านจาก .env ถ้าไม่มีใช้ default เป็น "http://52.63.155.211/api"
  static final String baseUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
  // ประกาศตัวแปรคงที่สำหรับเก็บ URL หลักของ API เพื่อให้ง่ายต่อการเรียกใช้

  // ตัวแปรเก็บค่าที่ผู้ใช้เลือกจาก DropdownButtonFormField
  int? _selectedFacultyId;    // คณะที่ถูกเลือก (ใช้ 'id' ส่งไปยัง API)
  int? _selectedDepartmentId;  // สาขาที่ถูกเลือก (ใช้ 'id' ส่งไปยัง API)
  int? _selectedRoleId;        // สถานะ (นักศึกษา/อาจารย์) ที่ถูกเลือก (ใช้ 'id' ส่งไปยัง API)

  bool _isLoading = false;      // สถานะเพื่อเช็คว่ากำลังส่งข้อมูล API หรือไม่ (ใช้สำหรับควบคุมปุ่มลงทะเบียน)
  String? _errorMessage;         // ข้อความ error ที่จะแสดงบน UI หากการลงทะเบียนล้มเหลว

  // ข้อมูลคณะ (static) ใช้สำหรับ Dropdown 'คณะ'
  final List<Map<String, dynamic>> _facultiesData = [
    {'id': 1, 'name': 'คณะเทคโนโลยีการจัดการ'},
    {'id': 2, 'name': 'คณะเกษตรศาสตร์และเทคโนโลยี'},
    // ข้อมูลคณะจำลองที่ hardcode ไว้สำหรับ Dropdown
  ];

  // ข้อมูลสาขา แยกตาม faculty_id (ใช้ Map เพื่อเชื่อมโยง)
  final Map<int, List<Map<String, dynamic>>> _departmentDataMap = {
    2: [ // faculty_id 2 → สาขาเกษตร
      {'id': 1, 'name': 'สาขาพืชศาสตร์'},
      {'id': 2, 'name': 'สาขาสัตวศาสตร์'},
      {'id': 3, 'name': 'สาขาประมง'},
      {'id': 4, 'name': 'สาขาเครื่องกลเกษตร'},
      {'id': 5, 'name': 'สาขาช่างไฟฟ้า'},
      {'id': 6, 'name': 'สาขาเทคโนโลยีคอมพิวเตอร์'},
      {'id': 7, 'name': 'สาขาเทคโนโลยีสิ่งทอและเครื่องนุ่งห่ม'},
      {'id': 8, 'name': 'สาขาเทคโนโลยีการผลิต'},
      {'id': 9, 'name': 'สาขาเทคโนโลยีอาหาร'},
      {'id': 10, 'name': 'สาขาเทคโนโลยีการเกษตร'},
      {'id': 11, 'name': 'สาขาเคมีประยุกต์'},
      {'id': 12, 'name': 'สาขาเทคโนโลยีและการจัดการสิ่งแวดล้อม'},
      {'id': 13, 'name': 'สาขาเทคโนโลยีชีวภาพทางการเกษตร'},
      {'id': 14, 'name': 'สาขาการออกแบบภูมิทัศน์และการจัดสวน'},
      {'id': 15, 'name': 'สาขาเทคโนโลยีสิ่งทอและการออกแบบแฟชั่น'},
      {'id': 16, 'name': 'สาขาวิศวกรรมเครื่องจักรกลเกษตร'},
      {'id': 17, 'name': 'สาขาวิศวกรรมไฟฟ้า'},
      {'id': 18, 'name': 'สาขาวิศวกรรมเครื่องกล'},
      {'id': 19, 'name': 'สาขาวิศวกรรมโยธา'},
      {'id': 20, 'name': 'สาขาวิศวกรรมยานยนต์'},
      {'id': 21, 'name': 'สาขาสถาปัตยกรรมภายใน'},
      {'id': 22, 'name': 'สาขาเทคโนโลยีไฟฟ้า'},
    ],
    1: [ // faculty_id 1 → สาขาการจัดการ
      {'id': 23, 'name': 'สาขาการจัดการสมัยใหม่'},
      {'id': 24, 'name': 'สาขาการตลาด'},
      {'id': 25, 'name': 'สาขาการบัญชี'},
      {'id': 26, 'name': 'สาขาคอมพิวเตอร์ธุรกิจ'},
      {'id': 27, 'name': 'สาขาเทคโนโลยีการตลาดสมัยใหม่'},
      {'id': 28, 'name': 'สาขาเทคโนโลยีธุรกิจดิจิทัล'},
      {'id': 29, 'name': 'สาขาการท่องเที่ยวและการโรงแรม'},
      {'id': 30, 'name': 'สาขาภาษาอังกฤษเพื่อการสื่อสาร'},
      {'id': 31, 'name': 'สาขาเทคโนโลยีมัลติมีเดีย'},
      {'id': 32, 'name': 'สาขาเทคโนโลยีในธุรกิจดิจิทัล'},
    ]
  };
  // ข้อมูลสาขาถูกจัดกลุ่มตาม 'faculty_id' เพื่อให้แสดงรายการที่เกี่ยวข้องเท่านั้น (Dependent Dropdown)

  // ข้อมูลสถานะผู้ใช้ (role)
  final List<Map<String, dynamic>> _rolesData = [
    {'id': 1, 'name': 'student', 'display_name': 'นักศึกษา'},
    {'id': 2, 'name': 'teacher', 'display_name': 'อาจารย์'},
    // ใช้ 'id' เป็นค่าที่ส่งไป API แต่ใช้ 'display_name' ในการแสดงผลบน UI
  ];

  // ฟังก์ชันลงทะเบียนผู้ใช้ (ทำงานแบบ asynchronous)
  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;  // เริ่ม loading: กำหนดสถานะการโหลดเป็นจริง เพื่อแสดง Progress Indicator
      _errorMessage = null; // ลบ error เก่า: เคลียร์ข้อความ error ก่อนเริ่มทำงาน
    });

    // ตรวจสอบว่าผู้ใช้เลือกครบทุก dropdown
    if (_selectedFacultyId == null ||
        _selectedDepartmentId == null ||
        _selectedRoleId == null) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบถ้วน'; // ตั้งค่าข้อความ error
        _isLoading = false; // หยุด loading ทันที
      });
      return; // ออกจากฟังก์ชัน
    }

    // ดึงข้อมูล arguments จากหน้า Register01 (ข้อมูลส่วนตัว: ชื่อ, อีเมล, รหัสผ่าน ฯลฯ)
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // ModalRoute.of(context) ใช้สำหรับเข้าถึงข้อมูลที่ถูกส่งมาผ่าน Navigator

    // URL API สำหรับลงทะเบียน
    final String apiUrl = '$baseUrl/register'; // สร้าง URL เต็ม

    try {
      // ส่ง POST request ไปยัง API
      final response = await http.post(
        Uri.parse(apiUrl), // แปลง String URL เป็น Uri object
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8', // กำหนด Header เป็น JSON
        },
        body: jsonEncode(<String, dynamic>{ // แปลง Map ข้อมูลทั้งหมดเป็น String JSON เพื่อส่งไป API
          'name': args['name'],
          'lastname': args['lastname'],
          'email': args['email'],
          'phone': args['phone'],
          'password': args['password'],
          'password_confirmation': args['password_confirmation'],
          'faculty_id': _selectedFacultyId, // ข้อมูลจากหน้านี้
          'department_id': _selectedDepartmentId,
          'role_id': _selectedRoleId,
        }),
      );

      // ถ้าสำเร็จ (HTTP Status Code 200 หรือ 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog( // แสดง Dialog แจ้งผู้ใช้ว่าลงทะเบียนสำเร็จ
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ลงทะเบียนสำเร็จ'),
            content: const Text(
              'ลงทะเบียนเสร็จสิ้น\nกรุณายืนยันตัวตนผ่านอีเมล เพื่อเข้าใช้งานแอปพลิเคชัน',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด dialog
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false); // ไปหน้า login และล้าง Stack เพื่อป้องกันการย้อนกลับ
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else { 
        // กรณี API ตอบกลับมาเป็น error (Status Code อื่นๆ เช่น 422 Validation Error)
        final errorResponse = jsonDecode(response.body); // ถอดรหัส JSON ของ Error Response
        String message = errorResponse['message'] ?? 'การลงทะเบียนล้มเหลว'; // ดึงข้อความหลัก

        if (errorResponse['errors'] != null) { // ถ้ามีรายละเอียด error ในแต่ละ field
          Map<String, dynamic> errors = errorResponse['errors'];
          message = ''; // เคลียร์ข้อความหลัก
          errors.forEach((key, value) {
            message += '${value[0]}\n'; // รวม error ของทุก field มาแสดงผล
          });
        }

        setState(() {
          _errorMessage = message; // แสดง error บน UI
        });
      }
    } catch (e) { // ถ้า network มีปัญหาหรือเกิด exception อื่นๆ (เช่น Time out, No internet)
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: โปรดลองอีกครั้ง ($e)'; // แสดงข้อความ error การเชื่อมต่อ
      });
    } finally { // ส่วนที่ทำงานเสมอไม่ว่าผลลัพธ์จะเป็นอะไร
      setState(() {
        _isLoading = false; // หยุด loading
      });
    }
  }

  // ฟังก์ชันยกเลิก → กลับหน้า login
  void _cancel() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    // นำทางไปยังหน้า '/login' พร้อมล้างทุกหน้าใน Stack
  }

  // Build UI (ส่วนประกอบหลักของหน้าจอ)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( // ใช้ Container เพื่อกำหนด Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient( // กำหนดสี Gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B894), Color(0xFF91C8E4)], // สีเขียว-ฟ้า
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อให้หน้าจอเลื่อนได้เมื่อ Keyboard เปิด
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text( // หัวข้อ 'ลงทะเบียน'
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow( // เงาให้ตัวอักษร
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black38)
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown คณะ (เรียกใช้ฟังก์ชันสร้าง Dropdown แบบ reusable)
                  _buildDropdown(
                    value: _selectedFacultyId,
                    hint: 'คณะ',
                    items: _facultiesData,
                    onChanged: (value) {
                      setState(() {
                        _selectedFacultyId = value;
                        _selectedDepartmentId = null; // reset สาขาเมื่อคณะเปลี่ยน
                      });
                    },
                  ),

                  // Dropdown สาขา (รายการจะอิงตามค่าที่เลือกใน _selectedFacultyId)
                  _buildDropdown(
                    value: _selectedDepartmentId,
                    hint: 'สาขา',
                    items: _departmentDataMap[_selectedFacultyId] ?? [], // กรองรายการสาขา
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartmentId = value;
                      });
                    },
                  ),

                  // Dropdown สถานะ
                  _buildDropdown(
                    value: _selectedRoleId,
                    hint: 'สถานะ',
                    items: _rolesData,
                    onChanged: (value) {
                      setState(() {
                        _selectedRoleId = value;
                      });
                    },
                    labelKey: 'display_name', // ใช้ display_name สำหรับแสดงผล
                  ),

                  const SizedBox(height: 20),

                  // แสดงข้อความผิดพลาด
                  if (_errorMessage != null) // แสดงเมื่อมีค่า _errorMessage
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ปุ่มลงทะเบียน
                  Container( // ตกแต่งปุ่มลงทะเบียน
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F8FAF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isLoading ? null : _registerUser, // ปิดการใช้งานปุ่มเมื่อกำลังโหลด
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white) // แสดง loading
                          : const Text(
                              'ลงทะเบียน',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ปุ่มยกเลิก
                  Container( // ตกแต่งปุ่มยกเลิก
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _cancel,
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง Dropdown (Reusable Widget)
  Widget _buildDropdown({
    required int? value,                  // ค่า selected ปัจจุบัน
    required String hint,                  // ข้อความ hint
    required List<Map<String, dynamic>> items, // รายการข้อมูล
    required ValueChanged<int?> onChanged, // callback เมื่อเลือกค่าใหม่
    String? labelKey,                      // กำหนด key สำหรับแสดงข้อความ (default 'name')
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<int>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF221B64)),
          decoration: InputDecoration( // การออกแบบ Dropdown Field
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
          ),
          items: items.map<DropdownMenuItem<int>>((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'] as int, // ใช้ 'id' เป็นค่าที่ส่งกลับ
              child: Text(item[labelKey ?? 'name'].toString()), // แสดงค่าจาก 'name' หรือ 'labelKey'
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}