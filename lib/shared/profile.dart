import 'package:edunudge/services/api_service.dart'; 
// ใช้เรียก API ไปยัง backend เช่น updateData, confirmOtp

import 'package:flutter/material.dart'; 
// ใช้สำหรับสร้าง UI ด้วย Flutter Material Design

import 'package:provider/provider.dart'; 
// ใช้ Provider สำหรับจัดการ state ระดับ global

import 'package:edunudge/providers/profile_provider.dart'; 
// ใช้ ProfileProvider สำหรับเก็บและอัพเดตข้อมูลโปรไฟล์ผู้ใช้

import 'package:shared_preferences/shared_preferences.dart'; 
// ใช้ SharedPreferences เก็บข้อมูลผู้ใช้แบบ local (key-value storage)

import 'package:flutter/services.dart'; 
// ใช้สำหรับจัดการ Input เช่น จำกัดตัวเลข, ความยาว, กรอง input


class ProfilePage extends StatefulWidget { 
  // ProfilePage เป็น StatefulWidget เพราะข้อมูลภายใน (state) สามารถเปลี่ยนแปลงได้
  const ProfilePage({super.key}); // constructor ของหน้า ProfilePage

  @override
  State<ProfilePage> createState() => _ProfilePageState(); 
  // ฟังก์ชันสร้าง state ของ widget นี้ โดยเชื่อมไปยัง _ProfilePageState
}

class _ProfilePageState extends State<ProfilePage> { 
  // class สำหรับเก็บ state ของ ProfilePage
  bool _isPageLoading = false; 
  // ตัวแปรบอกสถานะว่า กำลังโหลดข้อมูลอยู่หรือไม่ (ใช้แสดงวงกลมโหลด)

  @override
  void initState() { 
    // ฟังก์ชัน initState() จะทำงานตอน widget ถูกสร้างครั้งแรก
    super.initState();
    _setInitialProfileData(); 
    // เรียกใช้ฟังก์ชันเพื่อดึงข้อมูลผู้ใช้จาก SharedPreferences แล้วอัพเดต Provider
  }

  void _setInitialProfileData() async { 
    // ฟังก์ชันดึงข้อมูลผู้ใช้ที่เคยบันทึกไว้มาใส่ใน Provider
    if (!mounted) return; 
    // เช็คว่า widget ยังอยู่ใน tree หรือไม่ (ถ้าไม่อยู่แล้ว จะไม่ทำงานต่อ)
    try {
      final prefs = await SharedPreferences.getInstance(); 
      // เข้าถึง SharedPreferences

      final profileProvider = Provider.of<ProfileProvider>( 
        context,
        listen: false, 
        // ใช้ false เพราะไม่ต้องการ rebuild widget เมื่อมีการเปลี่ยนแปลง
      );

      profileProvider.setProfileData( 
        // ตั้งค่าข้อมูลเริ่มต้นจากที่ดึงมาได้
        name: prefs.getString('user_name') ?? '',
        lastname: prefs.getString('user_lastname') ?? '',
        email: prefs.getString('user_email') ?? '',
        phone: prefs.getString('user_phone') ?? '',
      );
    } catch (e) {
      debugPrint('Failed to set initial profile data: $e'); 
      // ถ้าเกิด error ให้แสดง log
    }
  }


    Future<void> _saveAndUpdateProfile(Map<String, String?> fields) async { 
    // ฟังก์ชันบันทึกข้อมูลใหม่ทั้งลง SharedPreferences และอัพเดต Provider
    if (!mounted) return; 

    final prefs = await SharedPreferences.getInstance(); 
    // เปิด SharedPreferences

    final profileProvider = Provider.of<ProfileProvider>( 
      context,
      listen: false,
    );

    for (var entry in fields.entries) { 
      // วน loop key-value ที่ส่งมา เช่น {'name': 'Anusara'}
      final key = entry.key; 
      final value = entry.value;
      if (value == null) continue; // ถ้า value เป็น null ข้าม

      switch (key) { 
        // เช็คว่า field ไหน แล้วบันทึกทั้ง prefs และ provider
        case 'name':
          await prefs.setString('user_name', value);
          profileProvider.name = value;
          break;
        case 'lastname':
          await prefs.setString('user_lastname', value);
          profileProvider.lastname = value;
          break;
        case 'email':
          await prefs.setString('user_email', value);
          profileProvider.email = value;
          break;
        case 'phone':
          await prefs.setString('user_phone', value);
          profileProvider.phone = value;
          break;
      }
    }
  }

  void showMessage(String message) { 
    // ฟังก์ชันนี้ใช้สำหรับแสดงข้อความชั่วคราวที่ด้านล่างจอ (SnackBar)
    if (!mounted) return; 
    // ถ้า widget ถูกถอดออกจาก tree แล้ว จะไม่ทำงาน
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message))); 
    // แสดง SnackBar พร้อมข้อความที่ส่งเข้ามา
  }

  Widget _buildTextField(
    TextEditingController controller, // controller สำหรับเก็บค่าที่ผู้ใช้กรอก
    String hintText, { // hintText คือข้อความตัวอย่าง (placeholder)
    bool obscureText = false, // ใช้สำหรับซ่อนข้อความ (true = ซ่อน เช่นรหัสผ่าน)
    TextInputType keyboardType = TextInputType.text, // ประเภทคีย์บอร์ด เช่น email, number
    bool autofocus = false, // กำหนดว่าจะโฟกัสช่องนี้อัตโนมัติหรือไม่
    List<TextInputFormatter>? inputFormatters, // ใช้กำหนดเงื่อนไขการพิมพ์ เช่น จำกัดตัวเลข
  }) {
    return TextField(
      controller: controller, // เชื่อมกับ controller
      obscureText: obscureText, // ซ่อนข้อความถ้าเป็นรหัสผ่าน
      keyboardType: keyboardType, // ประเภทคีย์บอร์ด
      autofocus: autofocus, // โฟกัสทันทีหรือไม่
      inputFormatters: inputFormatters, // กำหนดกฎการกรอก
      style: const TextStyle(color: Colors.white), // สีตัวอักษร
      decoration: InputDecoration(
        hintText: hintText, // ข้อความ hint
        hintStyle: const TextStyle(color: Color.fromARGB(150, 255, 255, 255)), 
        // สีกึ่งโปร่งแสงสำหรับ hint
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), 
          // เส้นใต้ตอนยังไม่ได้ focus
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), 
          // เส้นใต้ตอน focus อยู่
        ),
      ),
    );
  }


   Future<void> _buildProfileDialog({
    required BuildContext context, // context ของหน้า
    required String title, // หัวข้อ dialog
    required List<Widget> children, // widget ที่อยู่ใน dialog เช่น TextField
    required String actionButtonText, // ข้อความปุ่ม action เช่น "บันทึก"
    required VoidCallback onSave, // ฟังก์ชันที่ทำงานเมื่อกดปุ่มบันทึก
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
        // มุมโค้งมน
        backgroundColor: Colors.transparent, // โปร่งใส (เพื่อโชว์ gradient)
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // มุมโค้งมน
              gradient: const LinearGradient(
                colors: [Color(0xFF00B894),  Color(0xFF91C8E4),], 
                // พื้นหลังแบบไล่สี (เขียว-ฟ้า)
              ),
            ),
            padding: const EdgeInsets.all(20), // เว้นขอบ
            child: Column(
              mainAxisSize: MainAxisSize.min, // ขนาดพอดีกับเนื้อหา
              children: [
                Text(
                  title, // แสดงหัวข้อ
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20), // เว้นระยะห่าง
                ...children, // วาง widget ที่ส่งเข้ามา
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // ปุ่มอยู่ขวาสุด
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      // กดแล้วปิด dialog
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: onSave, 
                      // กดแล้วเรียกฟังก์ชัน onSave
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, 
                        // พื้นหลังปุ่มสีขาว
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // มุมโค้ง
                        ),
                      ),
                      child: Text(
                        actionButtonText, // ข้อความปุ่ม เช่น "บันทึก"
                        style: const TextStyle(color: Color(0xFF221B64)), 
                        // ตัวอักษรสีน้ำเงินเข้ม
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _editProfileNameDialog(
    BuildContext context,
    ProfileProvider profileProvider,
  ) {
    final nameController = TextEditingController(text: profileProvider.name); 
    // สร้าง TextEditingController พร้อมค่าชื่อที่มีอยู่แล้ว
    final lastnameController = TextEditingController(text: profileProvider.lastname); 
    // เช่นเดียวกันสำหรับนามสกุล

    _buildProfileDialog( // ใช้ฟังก์ชันที่เราสร้างไว้ตอนที่ 4
      context: context,
      title: 'แก้ไขชื่อ–นามสกุล', // หัวข้อ dialog
      actionButtonText: 'บันทึก', // ปุ่มบันทึก
      children: [
        _buildTextField(nameController, 'ชื่อ'), // ช่องกรอกชื่อ
        const SizedBox(height: 10), // เว้นระยะ
        _buildTextField(lastnameController, 'นามสกุล'), // ช่องกรอกนามสกุล
      ],
      onSave: () async {
        final name = nameController.text.trim(); // ตัดช่องว่างออกจากชื่อ
        final lastname = lastnameController.text.trim(); // ตัดช่องว่างจากนามสกุล
        if (name.isEmpty || lastname.isEmpty) { 
          // ตรวจสอบว่ากรอกครบหรือไม่
          showMessage('กรุณากรอกชื่อและนามสกุล');
          return;
        }

        try {
          final response = await ApiService.updateData({
            'field': 'name', // บอกว่าแก้ไข field ชื่อ
            'data': {'name': name, 'lastname': lastname}, // ข้อมูลใหม่
          });

          if (response['status'] == 'success') {
            await _saveAndUpdateProfile({'name': name, 'lastname': lastname}); 
            // บันทึกลง SharedPreferences และ Provider
            Navigator.pop(context); // ปิด dialog
            showMessage(response['message'] ?? 'บันทึกสำเร็จ'); // แสดงผลลัพธ์
          } else {
            showMessage(response['message'] ?? 'เกิดข้อผิดพลาด');
          }
        } catch (e) {
          showMessage('เกิดข้อผิดพลาด: ${e.toString()}'); // ถ้า error
        }
      },
    );
  }

  void _updateEmailOrPhone({
    required BuildContext context,
    required ProfileProvider profileProvider,
    required String field, // รับค่า 'email' หรือ 'phone'
  }) {
    final controller = TextEditingController(
      text: field == 'email' ? profileProvider.email : profileProvider.phone,
      // ถ้าเป็น email ให้ใช้ email เดิม, ถ้าเป็น phone ให้ใช้เบอร์เดิม
    );
    final passwordController = TextEditingController(); // ช่องกรอกรหัสผ่านเพื่อยืนยัน

    _buildProfileDialog(
      context: context,
      title: field == 'email' ? 'แก้ไขอีเมล' : 'แก้ไขเบอร์โทรศัพท์',
      actionButtonText: 'ต่อไป',
      children: [
        _buildTextField(
          controller,
          field == 'email' ? 'กรอกอีเมลใหม่' : 'กรุณากรอกเบอร์โทร',
          keyboardType: field == 'email'
              ? TextInputType.emailAddress // ถ้า email ใช้คีย์บอร์ด email
              : TextInputType.phone, // ถ้า phone ใช้คีย์บอร์ดตัวเลข
          inputFormatters: field == 'phone'
              ? [
                  FilteringTextInputFormatter.digitsOnly, // รับแต่ตัวเลข
                  LengthLimitingTextInputFormatter(10), // จำกัดไม่เกิน 10 หลัก
                ]
              : null,
        ),
        const SizedBox(height: 10),
        _buildTextField(passwordController, 'กรอกรหัสผ่าน', obscureText: true), 
        // รหัสผ่านเก่าของผู้ใช้
      ],
      onSave: () async {
        final value = controller.text.trim();
        final password = passwordController.text.trim();

        if (value.isEmpty ||
            password.isEmpty ||
            (field == 'email' && !value.contains('@')) || // ตรวจสอบ email
            (field == 'phone' && value.length != 10)) { // ตรวจสอบเบอร์
          showMessage('กรุณากรอกข้อมูลให้ครบถ้วน');
          return;
        }

        try {
          final response = await ApiService.updateData({
            'field': field, // บอกว่าแก้ไข field ไหน
            'data': field == 'email'
                ? {'newEmail': value, 'password': password}
                : {'phone': value, 'password': password},
          });

          if (response['status'] == 'success') {
            Navigator.of(context, rootNavigator: true).pop(); // ปิด dialog
            _showOtpDialog( // เปิด dialog สำหรับยืนยัน OTP
              context: context,
              title:
                  'ยืนยัน OTP ${field == 'email' ? 'อีเมล' : 'เบอร์โทรศัพท์'}',
              onConfirm: (otp) async { // เมื่อกดยืนยัน OTP
                final result = await ApiService.confirmOtp({
                  'otp': otp,
                  'field': field,
                });
                if (result['status'] == 'success') {
                  await _saveAndUpdateProfile({field: value}); 
                  // บันทึกข้อมูลใหม่ถ้า OTP ถูกต้อง
                  showMessage('ยืนยัน OTP สำเร็จ');
                } else {
                  showMessage('OTP ไม่ถูกต้องหรือหมดอายุ');
                }
              },
            );
          } else {
            showMessage(response['message'] ?? 'เกิดข้อผิดพลาด');
          }
        } catch (e) {
          showMessage('เกิดข้อผิดพลาด: $e');
        }
      },
    );
  }
  Future<void> _showOtpDialog({
    required BuildContext context,
    required String title, // หัวข้อ dialog เช่น "ยืนยัน OTP เบอร์โทรศัพท์"
    required Function(String otp) onConfirm, // ฟังก์ชัน callback เมื่อกดยืนยัน
  }) async {
    final otpController = TextEditingController(); // ช่องกรอก OTP
    String? errorMessage; // ใช้แสดง error ถ้า OTP ว่างหรือไม่ถูกต้อง

    return showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder( // ใช้ StatefulBuilder เพื่ออัพเดต state ของ dialog (errorMessage)
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.transparent, // โปร่งใส
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B894),  Color(0xFF91C8E4),],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title, // แสดงหัวข้อ
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number, // รับตัวเลขเท่านั้น
                    autofocus: true, // โฟกัสอัตโนมัติ
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'กรอก OTP',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(150, 255, 255, 255),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!, // ถ้ามี error จะแสดงตรงนี้
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // ปิด dialog
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final otp = otpController.text.trim(); // เอาค่า OTP
                          if (otp.isEmpty) {
                            setState(() => errorMessage = 'กรุณากรอก OTP'); 
                            // ถ้าไม่กรอก แสดง error
                            return;
                          }

                          onConfirm(otp); // ส่งค่า otp ไปให้ callback
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ยืนยัน',
                          style: TextStyle(color: Color(0xFF221B64)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

   void _changePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController(); // ช่องกรอกรหัสผ่านเก่า
    final newPassController = TextEditingController(); // ช่องกรอกรหัสผ่านใหม่
    final confirmPassController = TextEditingController(); // ช่องยืนยันรหัสผ่านใหม่

    _buildProfileDialog( // ใช้ dialog ที่สร้างไว้ตอนที่ 4
      context: context,
      title: 'เปลี่ยนรหัสผ่าน', // หัวข้อ
      actionButtonText: 'บันทึก', // ปุ่มบันทึก
      children: [
        _buildTextField(oldPassController, 'รหัสผ่านเก่า', obscureText: true),
        const SizedBox(height: 10),
        _buildTextField(newPassController, 'รหัสผ่านใหม่', obscureText: true),
        const SizedBox(height: 10),
        _buildTextField(
          confirmPassController,
          'ยืนยันรหัสผ่านใหม่',
          obscureText: true,
        ),
      ],
      onSave: () async {
        final oldPass = oldPassController.text.trim(); // ค่า input รหัสเก่า
        final newPass = newPassController.text.trim(); // ค่า input รหัสใหม่
        final confirmPass = confirmPassController.text.trim(); // ค่า input ยืนยันรหัสใหม่

        if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
          showMessage('กรุณากรอกข้อมูลให้ครบถ้วน'); // ตรวจสอบค่าว่าง
          return;
        }

        if (newPass.length < 8) { 
          // รหัสใหม่ต้องมีอย่างน้อย 8 ตัวอักษร
          showMessage('รหัสผ่านใหม่ต้องมีอย่างน้อย 8 ตัวอักษร');
          return;
        }

        if (newPass != confirmPass) { 
          // ตรวจสอบว่ารหัสใหม่กับยืนยันตรงกันหรือไม่
          showMessage('รหัสผ่านใหม่ไม่ตรงกัน');
          return;
        }

        try {
          final response = await ApiService.updateData({
            'field': 'newPassword', // แจ้ง backend ว่าเปลี่ยนรหัสผ่าน
            'data': {'password': oldPass, 'newPassword': newPass},
          });

          if (response['status'] == 'success') {
            oldPassController.clear(); // ล้างช่องกรอก
            newPassController.clear();
            confirmPassController.clear();
            showMessage(response['message']); // แสดงข้อความจาก backend
          } else {
            showMessage(response['error'] ?? 'เกิดข้อผิดพลาด');
          }
        } catch (e) {
          showMessage('เกิดข้อผิดพลาด: $e');
        }
        Navigator.pop(context); // ปิด dialog หลังทำเสร็จ
      },
    );
  }

    Widget _sectionTitle(String title) => Align(
        alignment: Alignment.centerLeft, // จัดชิดซ้าย
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0), // เว้นระยะบน-ล่าง
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // ตัวหนังสือสีขาว
            ),
          ),
        ),
      );

    Widget _infoTile(String title, String? value, VoidCallback onTap) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0, // ไม่มีเงา
        color: Colors.white.withOpacity(0.9), // พื้นหลังขาวโปร่งเล็กน้อย
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), 
          // หัวข้อ เช่น "อีเมล"
          subtitle: value != null && value.isNotEmpty
              ? Text(value, style: TextStyle(color: Colors.grey[600])) 
              : null, // ถ้ามีค่า จะแสดงใต้หัวข้อ
          trailing: const Icon(Icons.edit, color: Color(0xFF00B894)), 
          // ไอคอนดินสอแก้ไข
          onTap: onTap, // กดแล้วทำงาน (เปิด dialog แก้ไข)
        ),
      );

    @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>( // ใช้ Consumer ดึงข้อมูลจาก ProfileProvider
      builder: (context, profileProvider, child) {
        return Scaffold( // สร้างหน้า Scaffold หลัก
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient( // ใส่พื้นหลังแบบ Gradient ไล่สี
                colors: [Color(0xFF00B894),  Color(0xFF91C8E4),], // เขียว → ฟ้า
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent, // โปร่งใส (โชว์ gradient ข้างนอก)
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white), 
                  // ปุ่มย้อนกลับ
                  onPressed: () => Navigator.pop(context), // กดแล้วกลับไปหน้าก่อน
                ),
                title: const Text(
                  'ข้อมูลส่วนตัว', // หัวข้อ AppBar
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent, // โปร่งใส
                elevation: 0, // ไม่มีเงา
              ),
              body: _isPageLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white), 
                      // ถ้ากำลังโหลด แสดงวงกลมโหลด
                    )
                  : SingleChildScrollView( // ถ้าโหลดเสร็จ แสดงเนื้อหา
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 60, // ขนาดวงกลม
                              backgroundColor: Colors.white.withOpacity(0.2), 
                              // พื้นหลังโปร่งนิดๆ
                              child: Text(
                                profileProvider.initials, 
                                // ตัวย่อชื่อ–นามสกุล เช่น "AY"
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${profileProvider.name} ${profileProvider.lastname}', 
                            // ชื่อเต็มผู้ใช้
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          _sectionTitle('ข้อมูลส่วนตัว'), // หัวข้อ "ข้อมูลส่วนตัว"

                          _infoTile(
                            'ชื่อ–นามสกุล',
                            '${profileProvider.name} ${profileProvider.lastname}', 
                            // ค่าใน provider
                            () => _editProfileNameDialog(
                              context,
                              profileProvider,
                            ), // กดแล้วเปิด dialog แก้ไขชื่อ–นามสกุล
                          ),
                          _infoTile(
                            'อีเมล',
                            profileProvider.email, // แสดงอีเมล
                            () => _updateEmailOrPhone(
                              context: context,
                              profileProvider: profileProvider,
                              field: 'email',
                            ), // กดแล้วเปิด dialog แก้ไขอีเมล
                          ),
                          _infoTile(
                            'เบอร์โทรศัพท์',
                            profileProvider.phone, // แสดงเบอร์
                            () => _updateEmailOrPhone(
                              context: context,
                              profileProvider: profileProvider,
                              field: 'phone',
                            ), // กดแล้วเปิด dialog แก้ไขเบอร์โทร
                          ),

                          const SizedBox(height: 20),
                          _sectionTitle('รหัสผ่าน'), // หัวข้อ "รหัสผ่าน"

                          _infoTile(
                            'เปลี่ยนรหัสผ่าน',
                            '', // ไม่มีค่า subtitle เพราะไม่ต้องโชว์รหัสผ่าน
                            () => _changePasswordDialog(context), 
                            // กดแล้วเปิด dialog เปลี่ยนรหัสผ่าน
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
