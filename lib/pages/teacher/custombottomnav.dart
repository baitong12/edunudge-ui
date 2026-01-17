import 'package:flutter/material.dart'; 
//  นำเข้า Flutter Material สำหรับสร้าง UI

class CustomBottomNav extends StatelessWidget {
  final int currentIndex; 
  //  เก็บ index ของเมนูที่ถูกเลือก (0 = หน้าแรก, 1 = สร้างห้องเรียน)

  final BuildContext context; 
  //  เก็บ context ของหน้าปัจจุบันเพื่อใช้ Navigator

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.context,
  });
  //  constructor รับ currentIndex และ context มาจากหน้าที่เรียกใช้งาน

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, //  สีพื้นหลังของแถบ navigation
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
      //  padding รอบนอก

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10), 
        //  padding ด้านใน (เฉพาะบน/ล่าง)

        decoration: BoxDecoration(
          color: const Color(0xFF91C8E4), //  สีฟ้าพื้นหลังปุ่ม nav
          borderRadius: BorderRadius.circular(30), //  ทำมุมโค้ง 30px
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), //  เงาสีดำโปร่งใส
              blurRadius: 8, //  ความเบลอของเงา
              offset: const Offset(0, 3), //  เลื่อนเงาลง 3px
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, 
          //  จัดปุ่ม nav ให้อยู่ห่างเท่ากัน

          children: [
            //  ปุ่ม "หน้าหลัก"
            _navBarItem(Icons.home, 'หน้าหลัก', currentIndex == 0, () {
              if (currentIndex != 0) {
                Navigator.pushReplacementNamed(context, '/home_teacher'); 
                //  ไปหน้า Home (แทนที่หน้าปัจจุบัน)
              }
            }),

            //  ปุ่ม "สร้างห้องเรียน"
            _navBarItem(Icons.add_home, 'สร้างห้องเรียน', currentIndex == 1, () {
              if (currentIndex != 1) {
                Navigator.pushReplacementNamed(context, '/classroom_create01'); 
                //  ไปหน้าสร้างห้องเรียน (แทนที่หน้าปัจจุบัน)
              }
            }),
          ],
        ),
      ),
    );
  }

  // ====================== WIDGET ย่อยสำหรับสร้างปุ่มเมนู ======================
  Widget _navBarItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, //  เมื่อกดที่ปุ่ม -> เรียกฟังก์ชัน onTap

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), //  เวลาแอนิเมชัน 0.3 วิ
        curve: Curves.easeInOut, //  รูปแบบการเคลื่อนไหว
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
        //  padding รอบปุ่ม

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFEAA7).withOpacity(0.2) //  ถ้าเลือก -> พื้นหลังเหลืองจางๆ
              : Colors.transparent, //  ถ้าไม่เลือก -> โปร่งใส
          borderRadius: BorderRadius.circular(20), //  ทำมุมโค้งปุ่ม
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min, //  ขนาดคอลัมน์พอดีกับเนื้อหา
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFEAA7) : Colors.white, 
              //  ถ้าเลือก -> ไอคอนสีเหลือง, ถ้าไม่เลือก -> สีขาว
              size: 28,
            ),
            const SizedBox(height: 4), //  เว้นระยะระหว่าง icon กับข้อความ
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                //  ถ้าเลือก -> ตัวหนา, ถ้าไม่เลือก -> ปกติ
                color: isSelected ? const Color(0xFFFFEAA7) : Colors.white, 
                //  สีตัวอักษรตามสถานะเลือก/ไม่เลือก
              ),
            ),
          ],
        ),
      ),
    );
  }
}
