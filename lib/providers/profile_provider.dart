import 'package:flutter/material.dart'; // นำเข้า Material Design ของ Flutter เพื่อใช้คลาสพื้นฐาน เช่น ChangeNotifier

// คลาส ProfileProvider ใช้เก็บและจัดการข้อมูลโปรไฟล์ของผู้ใช้
// และสืบทอดจาก ChangeNotifier เพื่อแจ้งเตือน UI เมื่อข้อมูลเปลี่ยน
class ProfileProvider extends ChangeNotifier {
  String _name = '';      // ตัวแปรเก็บชื่อ (private เพราะขึ้นต้นด้วย _)
  String _lastname = '';  // ตัวแปรเก็บนามสกุล
  String _email = '';     // ตัวแปรเก็บอีเมล
  String _phone = '';     // ตัวแปรเก็บเบอร์โทรศัพท์

  // ===== Getter (อ่านค่าได้ แต่แก้ไม่ได้ตรงๆ) =====
  String get name => _name;           // คืนค่า name
  String get lastname => _lastname;   // คืนค่า lastname
  String get email => _email;         // คืนค่า email
  String get phone => _phone;         // คืนค่า phone

  // Getter initials = ตัวอักษรแรกของชื่อ + นามสกุล
  String get initials {
    String first = _name.isNotEmpty ? _name[0] : '';       // ถ้ามีชื่อ ให้ดึงอักษรแรก ไม่งั้นให้เป็น ''
    String last = _lastname.isNotEmpty ? _lastname[0] : ''; // ถ้ามีนามสกุล ให้ดึงอักษรแรก
    return (first + last).toUpperCase();                   // รวมอักษรแรก และแปลงเป็นพิมพ์ใหญ่ เช่น Anusara Yurayat -> AY
  }

  // ===== Setter (แก้ไขค่าได้ พร้อมแจ้งเตือน UI ด้วย notifyListeners) =====
  set name(String value) {
    _name = value;        // เปลี่ยนค่า name
    notifyListeners();    // แจ้งเตือน widget ที่ฟัง (Consumer/Provider) ให้อัปเดต UI ใหม่
  }

  set lastname(String value) {
    _lastname = value;    // เปลี่ยนค่า lastname
    notifyListeners();    // แจ้งเตือนให้ UI รีเฟรช
  }

  set email(String value) {
    _email = value;       // เปลี่ยนค่า email
    notifyListeners();    // แจ้งเตือน UI
  }

  set phone(String value) {
    _phone = value;       // เปลี่ยนค่า phone
    notifyListeners();    // แจ้งเตือน UI
  }

  // ฟังก์ชันตั้งค่าข้อมูลโปรไฟล์ทั้งหมดในครั้งเดียว
  void setProfileData({
    required String name,       // ชื่อใหม่
    required String lastname,   // นามสกุลใหม่
    required String email,      // อีเมลใหม่
    required String phone,      // เบอร์โทรใหม่
  }) {
    _name = name;           // อัปเดตค่า name
    _lastname = lastname;   // อัปเดตค่า lastname
    _email = email;         // อัปเดตค่า email
    _phone = phone;         // อัปเดตค่า phone
    notifyListeners();      // แจ้งเตือน UI แค่ครั้งเดียว (ประหยัดกว่า set ทีละค่า)
  }
}
