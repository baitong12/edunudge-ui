import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/profile_provider.dart';

class CustomAppBar extends StatelessWidget {

  static final String baseUrl = dotenv.env['API_URL'] ?? "http://127.0.0.1:8000/api";
  final VoidCallback onProfileTap;
  final VoidCallback? onLogoutTap;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
    this.onLogoutTap,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse("$baseUrl/logout"),
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

    if (onLogoutTap != null) {
      onLogoutTap!();
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  onTap: onProfileTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        profile.initials,
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
                  onTap: () => _logout(context),
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
  }
}
