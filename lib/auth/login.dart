import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edunudge/services/api_service.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  // ✅ ตรวจสอบ token และ role
  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    final roleId = prefs.getInt('role_id') ?? -1;

    if (token != null && roleId != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (roleId == 1) {
          Navigator.pushReplacementNamed(context, '/home_student');
        } else if (roleId == 2) {
          Navigator.pushReplacementNamed(context, '/home_teacher');
        }
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกอีเมลและรหัสผ่าน';
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await ApiService.login(email, password);

      final token = data['token'];
      final user = data['user'];
      final roleId = int.tryParse(user['role_id'].toString()) ?? -1;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token ?? '');
      await prefs.setInt('role_id', roleId);

      // ✅ เก็บเฉพาะ field ที่ Laravel ส่งมา
      await prefs.setInt('user_id', user['id'] ?? -1);
      await prefs.setString('user_name', user['name'] ?? '');
      await prefs.setString('user_lastname', user['lastname'] ?? '');
      await prefs.setString('user_email', user['email'] ?? '');
      await prefs.setString('user_phone', user['phone'] ?? '');
      await prefs.setInt('department_id', user['department_id'] ?? -1);

      // Navigate ตาม role
      if (roleId == 1) {
        Navigator.pushReplacementNamed(context, '/home_student');
      } else if (roleId == 2) {
        Navigator.pushReplacementNamed(context, '/home_teacher');
      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถระบุสถานะผู้ใช้ได้ (Role ID: $roleId)';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/logo_notname.png', height: 200),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'อีเมล',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'รหัสผ่าน',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F8FAF), // สีพื้นหลัง
                      foregroundColor: Colors.white, // สีตัวอักษร
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot_password');
                        },
                        child: const Text(
                          'ลืมรหัสผ่าน ?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register01');
                        },
                        child: const Text(
                          'ลงทะเบียน',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
