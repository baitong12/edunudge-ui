import 'package:flutter/material.dart'; // นำเข้าไลบรารี Flutter material

class CustomBottomNav extends StatelessWidget { // กำหนดคลาส CustomBottomNav ซึ่งเป็น StatelessWidget
  final int currentIndex; // ตัวแปรสำหรับเก็บ index ของรายการที่ถูกเลือกในปัจจุบัน
  final BuildContext context; // ตัวแปรสำหรับเก็บ BuildContext ที่ส่งมาจากภายนอก (ไม่จำเป็นต้องใช้แบบนี้ใน StatelessWidget)

  const CustomBottomNav({ // Constructor สำหรับคลาส
    super.key, // ส่ง key ไปยัง superclass (StatelessWidget)
    required this.currentIndex, // ต้องกำหนดค่าสำหรับ currentIndex
    required this.context, // ต้องกำหนดค่าสำหรับ context
  });

  @override // ระบุว่าเมธอดนี้เป็นการ Override เมธอดใน superclass
  Widget build(BuildContext context) { // เมธอด build ที่สร้าง UI สำหรับ widget นี้
    final screenWidth = MediaQuery.of(context).size.width; // คำนวณความกว้างของหน้าจออุปกรณ์

    // คำนวณค่า padding และขนาดต่างๆ โดยอิงตามความกว้างของหน้าจอเพื่อการตอบสนองต่อขนาดหน้าจอ
    final double horizontalPadding = screenWidth * 0.04; // คำนวณ padding แนวนอนสำหรับ Container หลัก
    final double verticalPadding = screenWidth * 0.02; // คำนวณ padding แนวตั้งสำหรับ Container หลัก
    final double iconSize = screenWidth * 0.07; // คำนวณขนาดไอคอน
    final double textSize = screenWidth * 0.028; // คำนวณขนาดตัวอักษร
    final double itemHorizontalPadding = screenWidth * 0.03; // คำนวณ padding แนวนอนสำหรับแต่ละรายการ
    final double itemVerticalPadding = screenWidth * 0.01; // คำนวณ padding แนวตั้งสำหรับแต่ละรายการ

    return Container( // คืนค่า Container หลักสำหรับแถบนำทางด้านล่าง
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding), // กำหนด padding ให้กับ Container หลัก
      decoration: BoxDecoration( // กำหนดการตกแต่งให้กับ Container
        color: const Color(0xFF00B894), // กำหนดสีพื้นหลัง (สีเขียวเทอร์ควอยซ์)
        borderRadius: BorderRadius.circular(30), // กำหนดรัศมีขอบโค้ง
        boxShadow: [ // กำหนดเงาให้กับ Container
          BoxShadow( // เงาอันแรก
            color: Colors.black.withOpacity(0.15), // สีของเงาพร้อมความทึบ
            blurRadius: 8, // รัศมีการเบลอของเงา
            offset: const Offset(0, 3), // ตำแหน่งของเงา (เลื่อนลง 3 พิกเซล)
          ),
        ],
      ),
      child: Row( // กำหนดให้มี children เรียงกันในแนวนอน
        mainAxisAlignment: MainAxisAlignment.spaceAround, // จัดเรียง children ให้มีช่องว่างรอบๆ เท่าๆ กัน
        children: [ // รายการ children (รายการนำทาง)
          _navBarItem(Icons.home, 'หน้าหลัก', currentIndex == 0, () { // รายการที่ 1: หน้าหลัก
            if (currentIndex != 0) { // ตรวจสอบว่ารายการนี้ยังไม่ถูกเลือกในปัจจุบัน
              Navigator.pushReplacementNamed(this.context, '/home_student'); // นำทางไปยังหน้า '/home_student' โดยแทนที่หน้าปัจจุบัน
            }
          }, iconSize, textSize, itemHorizontalPadding, itemVerticalPadding), // ส่งค่าขนาดและ padding ที่คำนวณไว้
          _navBarItem(Icons.groups, 'เข้าร่วมห้องเรียน', currentIndex == 1, () { // รายการที่ 2: เข้าร่วมห้องเรียน
            if (currentIndex != 1) { // ตรวจสอบว่ารายการนี้ยังไม่ถูกเลือกในปัจจุบัน
              Navigator.pushReplacementNamed(this.context, '/join-classroom'); // นำทางไปยังหน้า '/join-classroom'
            }
          }, iconSize, textSize, itemHorizontalPadding, itemVerticalPadding), // ส่งค่าขนาดและ padding ที่คำนวณไว้
          _navBarItem(Icons.description, 'ห้องเรียน', currentIndex == 2, () { // รายการที่ 3: ห้องเรียน
            if (currentIndex != 2) { // ตรวจสอบว่ารายการนี้ยังไม่ถูกเลือกในปัจจุบัน
              Navigator.pushReplacementNamed(this.context, '/classroom'); // นำทางไปยังหน้า '/classroom'
            }
          }, iconSize, textSize, itemHorizontalPadding, itemVerticalPadding), // ส่งค่าขนาดและ padding ที่คำนวณไว้
        ],
      ),
    );
  }

  // เมธอดส่วนตัวสำหรับสร้างรายการนำทางแต่ละรายการ
  Widget _navBarItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap, // รับไอคอน, ข้อความ, สถานะที่ถูกเลือก, ฟังก์ชันเมื่อแตะ
      double iconSize, double textSize, double itemHorizontalPadding, double itemVerticalPadding) { // รับค่าขนาดและ padding
    return GestureDetector( // ใช้ GestureDetector เพื่อตรวจจับการแตะ
      onTap: onTap, // กำหนดฟังก์ชันที่จะทำงานเมื่อแตะ
      child: AnimatedContainer( // ใช้ AnimatedContainer เพื่อให้มีการเปลี่ยนแปลงแบบเคลื่อนไหวเมื่อสถานะเปลี่ยน
        duration: const Duration(milliseconds: 250), // กำหนดระยะเวลาการเคลื่อนไหว
        curve: Curves.easeInOut, // กำหนดรูปแบบการเคลื่อนไหว
        padding: EdgeInsets.symmetric(horizontal: itemHorizontalPadding, vertical: itemVerticalPadding), // กำหนด padding ภายในรายการ
        decoration: BoxDecoration( // กำหนดการตกแต่งให้กับรายการ
          color: isSelected ? const Color(0xFFFFEAA7).withOpacity(0.3) : Colors.transparent, // สีพื้นหลัง: สีเหลืองอ่อนโปร่งแสงเมื่อถูกเลือก, โปร่งใสเมื่อไม่ถูกเลือก
          borderRadius: BorderRadius.circular(15), // กำหนดรัศมีขอบโค้ง
        ),
        child: Column( // จัดเรียงไอคอนและข้อความในแนวตั้ง
          mainAxisSize: MainAxisSize.min, // ให้ Column ใช้พื้นที่น้อยที่สุดตามขนาดของ children
          children: [ // รายการ children
            Icon( // ไอคอน
              icon, // ใช้ไอคอนที่ส่งมา
              color: isSelected ? const Color(0xFFFFEAA7) : Colors.white, // สีไอคอน: สีเหลืองอ่อนเมื่อถูกเลือก, สีขาวเมื่อไม่ถูกเลือก
              size: iconSize, // ขนาดไอคอน
            ),
            const SizedBox(height: 4), // เว้นระยะห่างแนวตั้งระหว่างไอคอนกับข้อความ
            Text( // ข้อความ
              label, // ใช้ข้อความที่ส่งมา
              style: TextStyle( // สไตล์ข้อความ
                fontSize: textSize, // ขนาดตัวอักษร
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // น้ำหนักตัวอักษร: ตัวหนาเมื่อถูกเลือก, ปกติเมื่อไม่ถูกเลือก
                color: isSelected ? const Color(0xFFFFEAA7) : Colors.white, // สีข้อความ: สีเหลืองอ่อนเมื่อถูกเลือก, สีขาวเมื่อไม่ถูกเลือก
              ),
            ),
          ],
        ),
      ),
    );
  }
}