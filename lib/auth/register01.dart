import 'package:flutter/material.dart';

class Register01 extends StatefulWidget {
  @override
  _Register01State createState() => _Register01State();
}

class _Register01State extends State<Register01> {

  final TextEditingController nameController = TextEditingController();//ตัวนี้คือ กล่องเก็บข้อมูลชั่วคราว สำหรับ:ชื่อ, นามสกุล, อีเมล, เบอร์โทร, รหัสผ่าน, ยืนยันรหัสผ่าน
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController = TextEditingController();

  String? _errorMessage;//เก็บข้อความแจ้งข้อผิดพลาด

  @override
  void dispose() {//ตอนผู้ใช้ ออกจากหน้านี้ กล่องเก็บข้อมูลจะถูกล้าง เพื่อไม่ให้ข้อมูลค้าง
    nameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  void _navigateToRegister02() {//ลบข้อความผิดพลาดเก่า
    setState(() {
      _errorMessage = null; 
    });

    if (nameController.text.isEmpty || //เช็คว่ากล่องเก็บข้อมูลว่างหรือไม่
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmationController.text.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบถ้วน';
      });
      return;
    }

    String email = emailController.text.trim(); //ตรวจสอบรูปแบบอีเมล
    String emailPattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";//ตรวจสอบว่าอีเมลผู้ใช้มีรูปแบบถูกต้อง มี @ และ . ตามหลักมาตรฐานไหม ถ้าไม่ตรง → ถือว่าไม่ถูกต้อง
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'กรุณากรอกอีเมลให้ถูกต้อง';
      });
      return;
    }

    String phone = phoneController.text.trim();//ตรวจสอบรูปแบบเบอร์โทรศัพท์ 10 ตัว
    RegExp phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _errorMessage = 'เบอร์โทรศัพท์ต้องเป็นตัวเลข 10 หลัก';
      });
      return;
    }


    if (passwordController.text.length < 8) {//ตรวจสอบรหัสผ่าน ต้องมีความยาวอย่างน้อย 8 ตัว
      setState(() {
        _errorMessage = 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
      });
      return;
    }


    if (passwordController.text != passwordConfirmationController.text) {//ตรวจสอบว่ารหัสผ่าน กับ ยืนยันรหัสผ่าน ตรงกันไหม
      setState(() {
        _errorMessage = 'รหัสผ่านไม่ตรงกัน';
      });
      return;
    }


    Navigator.pushNamed(//ถ้าผ่านทั้งหมด → ไปหน้า /register02 ส่งข้อมูลที่กรอกไปด้วย
      context,
      '/register02',
      arguments: {
        'name': nameController.text,
        'lastname': lastnameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'password_confirmation': passwordConfirmationController.text,
      },
    );
  }

 @override
  Widget build(BuildContext context) { 
    return Scaffold( // Scaffold เป็น layout หลักของหน้าจอ
       body: Container( // Container ใช้กำหนด decoration, gradient
        decoration: const BoxDecoration( 
          gradient: LinearGradient( 
            begin: Alignment.topCenter, // ไล่สีจากบนลงล่าง
            end: Alignment.bottomCenter, 
            colors: [Color(0xFF00B894),  Color(0xFF91C8E4)], 
          ), 
        ), 
        child: Center( // จัด widget ลูกให้อยู่กึ่งกลาง
          child: SingleChildScrollView( // ทำให้ scroll ได้ถ้าหน้าจอเล็ก
            child: Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // ขอบซ้ายขวา 30
              child: Column( 
                mainAxisAlignment: MainAxisAlignment.center, // จัดกึ่งกลางแนวตั้ง
                children: [ 
                  const Text( // แสดงหัวข้อหน้า
                    'ลงทะเบียน', 
                    style: TextStyle( 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                      shadows: [ // ใส่เงาให้ข้อความ
                        Shadow( 
                          offset: Offset(2, 2), 
                          blurRadius: 4, 
                          color: Colors.black38, 
                        ) 
                      ], 
                    ), 
                  ), 
                  const SizedBox(height: 20), // ช่องว่าง 20 px
                  _buildTextField('ชื่อ', controller: nameController), // ช่องกรอกชื่อ
                  _buildTextField('นามสกุล', controller: lastnameController), // ช่องกรอกนามสกุล
                  _buildTextField('อีเมล', controller: emailController, keyboardType: TextInputType.emailAddress), // ช่องกรอกอีเมล
                  _buildTextField('เบอร์โทรศัพท์', controller: phoneController, keyboardType: TextInputType.phone), // ช่องกรอกเบอร์

                  Column( // รวมช่องรหัสผ่านและข้อความแนะนำ
                    crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
                    children: [ 
                      _buildTextField('รหัสผ่าน', obscureText: true, controller: passwordController), // ช่องกรอกรหัสผ่าน
                      const Padding( 
                        padding: EdgeInsets.only(top: 4.0, left: 12.0), 
                        child: Text( 
                          'รหัสผ่านต้องมี 8 ตัวขึ้นไป', // ข้อความแนะนำ
                          style: TextStyle( 
                            color: Colors.redAccent, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                          ), 
                        ), 
                      ), 
                    ], 
                  ), 

                  _buildTextField('ยืนยันรหัสผ่าน', obscureText: true, controller: passwordConfirmationController), // ช่องยืนยันรหัสผ่าน
                  const SizedBox(height: 20), // ช่องว่าง

                  if (_errorMessage != null) // ถ้ามีข้อความผิดพลาด
                    Padding( 
                      padding: const EdgeInsets.only(bottom: 15.0), 
                      child: Text( 
                        _errorMessage!, // แสดงข้อความผิดพลาด
                        style: const TextStyle( 
                          color: Colors.redAccent, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                        ), 
                        textAlign: TextAlign.center, 
                      ), 
                    ), 

                  Row( // แถวปุ่มย้อนกลับ + ถัดไป
                    children: [ 
                      Expanded( // ปุ่มย้อนกลับ
                        child: Container( 
                          height: 50, 
                          decoration: BoxDecoration( 
                            borderRadius: BorderRadius.circular(25), 
                            boxShadow: const [ 
                              BoxShadow( 
                                color: Colors.black38, 
                                blurRadius: 6, 
                                offset: Offset(0, 4), 
                              ), 
                            ], 
                          ), 
                          child: ElevatedButton( 
                            style: ElevatedButton.styleFrom( 
                              backgroundColor: const Color.fromARGB(255, 255, 0, 0), 
                              shape: RoundedRectangleBorder( 
                                borderRadius: BorderRadius.circular(25), 
                              ), 
                            ), 
                            onPressed: () { 
                              Navigator.pushReplacementNamed(context, '/login'); // กลับหน้า login
                            }, 
                            child: const Text( 
                              'ย้อนกลับ', 
                              style: TextStyle( 
                                fontSize: 18, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                              ), 
                            ), 
                          ), 
                        ), 
                      ), 
                      const SizedBox(width: 16), // ช่องว่างระหว่างปุ่ม
                      Expanded( // ปุ่มถัดไป
                        child: Container( 
                          height: 50, 
                          decoration: BoxDecoration( 
                            borderRadius: BorderRadius.circular(25), 
                            boxShadow: const [ 
                              BoxShadow( 
                                color: Colors.black38, 
                                blurRadius: 6, 
                                offset: Offset(0, 4), 
                              ), 
                            ], 
                          ), 
                          child: ElevatedButton( 
                            style: ElevatedButton.styleFrom( 
                              backgroundColor: const Color(0xFF3F8FAF), 
                              shape: RoundedRectangleBorder( 
                                borderRadius: BorderRadius.circular(25), 
                              ), 
                            ), 
                            onPressed: _navigateToRegister02, // เรียกฟังก์ชัน validate + navigation
                            child: const Text( 
                              'ถัดไป', 
                              style: TextStyle( 
                                fontSize: 18, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                              ), 
                            ), 
                          ), 
                        ), 
                      ), 
                    ], 
                  ), 
                ], 
              ), 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 

  // ฟังก์ชันสร้าง TextField แบบ reusable
  Widget _buildTextField(String hint, {bool obscureText = false, TextEditingController? controller, TextInputType? keyboardType}) { 
    return Padding( 
      padding: const EdgeInsets.symmetric(vertical: 8.0), // ช่องว่างบน-ล่าง
      child: TextField( 
        controller: controller, // เชื่อม TextField กับ controller
        obscureText: obscureText, // ถ้าเป็น true → ซ่อนข้อความ (รหัสผ่าน)
        keyboardType: keyboardType, // กำหนด keyboard type (อีเมล, ตัวเลข, text)
        style: const TextStyle(fontSize: 16, color: Colors.black), // ขนาดและสีข้อความ
        decoration: InputDecoration( 
          hintText: hint, // ข้อความแนะนำในช่อง
          hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold), 
          filled: true, // เติม background
          fillColor: Colors.white, // สีพื้นหลัง
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // ระยะขอบใน TextField
          border: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(25), 
            borderSide: BorderSide.none, // ไม่มีเส้นขอบ
          ), 
          enabledBorder: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(25), 
            borderSide: BorderSide.none, 
          ), 
          focusedBorder: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(25), 
            borderSide: const BorderSide(color: Color(0xFF221B64), width: 2), // ขอบสีเข้มเวลา focus
          ), 
        ), 
      ), 
    ); 
  } 
} 