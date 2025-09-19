import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/profile_provider.dart';

class CustomAppBar extends StatefulWidget {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? "http://52.63.155.211/api";

  final VoidCallback onProfileTap;
  final VoidCallback? onLogoutTap;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _initials = '--';

  @override
  void initState() {
    super.initState();
    _loadInitials();
  }

  Future<void> _loadInitials() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final lastname = prefs.getString('user_lastname') ?? '';
    setState(() {
      _initials =
          ((name.isNotEmpty ? name[0] : '-') + (lastname.isNotEmpty ? lastname[0] : '-'))
              .toUpperCase();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse("${CustomAppBar.baseUrl}/logout"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        final data = jsonDecode(response.body);
        debugPrint("Logout Response: $data");
      } catch (e) {
        debugPrint("Logout Error: $e");
      }
    }

    await prefs.clear();

    if (widget.onLogoutTap != null) {
      widget.onLogoutTap!();
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

    Future<void> _confirmLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'ยืนยันการออกจากระบบ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ? การดำเนินการนี้จะต้องเข้าสู่ระบบใหม่เพื่อใช้งาน'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Color(0xFF3F8FAF)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); 
              _logout(context);       
            },
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, child) {
        
        final initialsFromProvider = profile.initials.isNotEmpty ? profile.initials : _initials;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAA7), 
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EduNudge',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onProfileTap,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF00B894), Color(0xFF91C8E4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initialsFromProvider,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _confirmLogout(context),
                      child: const Icon(
                        Icons.power_settings_new,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
