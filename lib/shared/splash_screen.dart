import 'package:flutter/material.dart'; 
// นำเข้าแพ็กเกจ material.dart ของ Flutter 
// เพื่อใช้ widget และ UI ตาม Material Design เช่น Scaffold, Container, Text, Image เป็นต้น

class SplashScreen extends StatelessWidget { 
  // ประกาศคลาส SplashScreen ซึ่งสืบทอดจาก StatelessWidget 
  // ใช้ทำหน้าสำหรับแสดง Splash Screen (หน้ารอโหลด/แสดงโลโก้)

  const SplashScreen({super.key}); 
  // คอนสตรัคเตอร์ของคลาสนี้ 
  // super.key ใช้ส่งค่าคีย์ไปยัง StatelessWidget เพื่อช่วย Flutter จัดการ widget tree ได้ดีขึ้น

  @override
  Widget build(BuildContext context) { 
    // ฟังก์ชัน build() ทำหน้าที่สร้าง UI ของหน้านี้
    // context จะเป็นตัวบอกตำแหน่งของ widget นี้ใน widget tree
    return Scaffold( 
      // Scaffold เป็นโครงหลักของหน้า UI ของ Material Design
      body: Container( 
        // body คือเนื้อหาหลักใน Scaffold
        // ใช้ Container ครอบเพื่อกำหนด background และจัด layout
        decoration: const BoxDecoration( 
          // decoration ใช้ตกแต่งพื้นหลังของ Container
          gradient: LinearGradient( 
            // กำหนดพื้นหลังเป็น Gradient ไล่สี
            begin: Alignment.topCenter, 
            // จุดเริ่มต้นของการไล่สี (ด้านบนสุด)
            end: Alignment.bottomCenter, 
            // จุดสิ้นสุดของการไล่สี (ด้านล่างสุด)
            colors: [Color(0xFF00B894), Color(0xFF91C8E4)], 
            // กำหนดสีที่ใช้ใน Gradient: เขียวอมฟ้า → ฟ้าอ่อน
          ),
        ),
        child: Center( 
          // Center ใช้สำหรับจัด widget ข้างในให้อยู่กึ่งกลางของ Container
          child: Image.asset( 
            // แสดงรูปภาพจาก assets
            'images/logo_notname.png', 
            // path ของไฟล์รูปภาพที่อยู่ในโฟลเดอร์ assets/images
            width: 300, 
            // กำหนดความกว้างของรูปภาพ = 300 px
          ),
        ),
      ),
    );
  }
}
