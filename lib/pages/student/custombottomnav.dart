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
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height; 

    
    final double horizontalPadding = screenWidth * 0.04; 
    final double verticalPadding = screenWidth * 0.03; 
    final double iconSize = screenWidth * 0.065; 
    final double textSize = screenWidth * 0.03; 
    final double itemHorizontalPadding = screenWidth * 0.03; 
    final double itemVerticalPadding = screenWidth * 0.02; 

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 3, 193, 149), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBarItem(Icons.home, 'หน้าหลัก', currentIndex == 0, () {
              if (currentIndex != 0) {
                Navigator.pushReplacementNamed(this.context, '/home_student');
              }
            }, iconSize, textSize, itemHorizontalPadding, itemVerticalPadding),
            _navBarItem(Icons.groups, 'เข้าร่วมห้องเรียน', currentIndex == 1, () {
              if (currentIndex != 1) {
                Navigator.pushReplacementNamed(this.context, '/join-classroom');
              }
            }, iconSize, textSize, itemHorizontalPadding, itemVerticalPadding),
            _navBarItem(Icons.description, 'ห้องเรียน', currentIndex == 2, () {
              if (currentIndex != 2) {
                Navigator.pushReplacementNamed(this.context, '/classroom');
              }
            }, iconSize, textSize, itemHorizontalPadding, itemVerticalPadding),
          ],
        ),
      ),
    );
  }

  
  Widget _navBarItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap,
      double iconSize, double textSize, double itemHorizontalPadding, double itemVerticalPadding) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: itemHorizontalPadding, vertical: itemVerticalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color.fromARGB(255, 1, 150, 63) : Colors.black54,
              size: iconSize,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color.fromARGB(255, 1, 150, 63) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
