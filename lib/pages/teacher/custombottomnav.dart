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
      
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 3, 193, 149), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(30), 
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
                Navigator.pushReplacementNamed(context, '/home_teacher');
              }
            }),
            
            _navBarItem(Icons.add_home, 'สร้างห้องเรียน', currentIndex == 1, () {
              if (currentIndex != 1) {
                Navigator.pushReplacementNamed(context, '/classroom_create01');
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
      child: AnimatedContainer( 
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              
              color: isSelected ? const Color(0xFF00C853) : Colors.black54,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                
                color: isSelected ? const Color.fromARGB(255, 7, 255, 131) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
