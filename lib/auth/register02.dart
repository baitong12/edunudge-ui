import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Register02 extends StatefulWidget {
  @override
  State<Register02> createState() => _Register02State();
}

class _Register02State extends State<Register02> {
  static final String baseUrl = dotenv.env['API_URL'] ?? "http://52.63.155.211/api";
  int? _selectedFacultyId;
  int? _selectedDepartmentId;
  int? _selectedRoleId;

  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _facultiesData = [
    {'id': 1, 'name': 'คณะเทคโนโลยีการจัดการ'},
    {'id': 2, 'name': 'คณะเกษตรศาสตร์และเทคโนโลยี'},
  ];

  final Map<int, List<Map<String, dynamic>>> _departmentDataMap = {
    2: [
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
    1: [
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

  final List<Map<String, dynamic>> _rolesData = [
    {'id': 1, 'name': 'student', 'display_name': 'นักศึกษา'},
    {'id': 2, 'name': 'teacher', 'display_name': 'อาจารย์'},
  ];

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_selectedFacultyId == null ||
        _selectedDepartmentId == null ||
        _selectedRoleId == null) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบถ้วน';
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String apiUrl = '$baseUrl/register';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': args['name'],
          'lastname': args['lastname'],
          'email': args['email'],
          'phone': args['phone'],
          'password': args['password'],
          'password_confirmation': args['password_confirmation'],
          'faculty_id': _selectedFacultyId,
          'department_id': _selectedDepartmentId,
          'role_id': _selectedRoleId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // แสดง Dialog แจ้งผู้ใช้
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ลงทะเบียนสำเร็จ'),
            content: const Text(
              'ลงทะเบียนเสร็จสิ้น\nกรุณายืนยันตัวตนผ่านอีเมล เพื่อเข้าใช้งานแอปพลิเคชัน',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Dialog
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        String message = errorResponse['message'] ?? 'การลงทะเบียนล้มเหลว';

        if (errorResponse['errors'] != null) {
          Map<String, dynamic> errors = errorResponse['errors'];
          message = '';
          errors.forEach((key, value) {
            message += '${value[0]}\n';
          });
        }

        setState(() {
          _errorMessage = message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: โปรดลองอีกครั้ง ($e)';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancel() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B894),  Color(0xFF91C8E4),],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black38)
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    value: _selectedFacultyId,
                    hint: 'คณะ',
                    items: _facultiesData,
                    onChanged: (value) {
                      setState(() {
                        _selectedFacultyId = value;
                        _selectedDepartmentId = null;
                      });
                    },
                  ),
                  _buildDropdown(
                    value: _selectedDepartmentId,
                    hint: 'สาขา',
                    items: _departmentDataMap[_selectedFacultyId] ?? [],
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartmentId = value;
                      });
                    },
                  ),
                  _buildDropdown(
                    value: _selectedRoleId,
                    hint: 'สถานะ',
                    items: _rolesData,
                    onChanged: (value) {
                      setState(() {
                        _selectedRoleId = value;
                      });
                    },
                    labelKey: 'display_name',
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
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
                  Container(
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
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isLoading ? null : _registerUser,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
                  Container(
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

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    String? labelKey,
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
          decoration: InputDecoration(
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
              value: item['id'] as int,
              child: Text(item[labelKey ?? 'name'].toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
