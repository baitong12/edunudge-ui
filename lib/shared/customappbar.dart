import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

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
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onLogoutTap,
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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