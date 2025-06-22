import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF221B64), // สีพื้นหลังรอบนอก
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // เว้นรอบด้าน
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // มนรอบมุม
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBarItem(Icons.home, 'หน้าหลัก', currentIndex == 0, () {
              if (currentIndex != 0) {
                Navigator.pushReplacementNamed(context, '/home_student');
              }
            }),
            _navBarItem(Icons.groups, 'เข้าร่วมห้องเรียน', currentIndex == 1, () {
              if (currentIndex != 1) {
                Navigator.pushReplacementNamed(context, '/join-classroom');
              }
            }),
            _navBarItem(Icons.description, 'ห้องเรียน', currentIndex == 2, () {
              if (currentIndex != 2) {
                Navigator.pushReplacementNamed(context, '/classroom');
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _navBarItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF221B64) : Colors.black,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF221B64) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
