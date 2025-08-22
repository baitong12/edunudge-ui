import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edunudge/providers/profile_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _setInitialProfileData();
  }

  
  void _setInitialProfileData() {
    if (mounted) {
      Provider.of<ProfileProvider>(context, listen: false).setProfileData(
        name: 'ชื่อผู้ใช้',
        lastname: 'นามสกุล',
        email: 'user@example.com',
        phone: '0987654321',
      );
    }
  }

  
  void _doneAndNavigateBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  
  void _updateProfile(Map<String, String?> updatedFields) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตข้อมูลโปรไฟล์สำเร็จ')),
      );
      
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.setProfileData(
        name: updatedFields['name'] ?? profileProvider.name,
        lastname: updatedFields['lastname'] ?? profileProvider.lastname,
        email: updatedFields['email'] ?? profileProvider.email,
        phone: updatedFields['phone'] ?? profileProvider.phone,
      );
    }
  }

  
  void _changePassword(String currentPassword, String newPassword) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          body: Container(
            
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('ข้อมูลส่วนตัว',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  TextButton(
                    onPressed: _doneAndNavigateBack,
                    child: const Text('เสร็จสิ้น',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                  ),
                ],
              ),
              body: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white.withOpacity(0.2), 
                              child: Text(
                                profileProvider.initials,
                                style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${profileProvider.name} ${profileProvider.lastname}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 30),
                          _sectionTitle('ข้อมูลส่วนตัว'),
                          _infoTile(
                            'ชื่อ–นามสกุล',
                            '${profileProvider.name} ${profileProvider.lastname}',
                            () => _editProfileNameDialog(context, profileProvider),
                          ),
                          _infoTile(
                            'อีเมล',
                            profileProvider.email, 
                            () => _editEmailDialog(context, profileProvider),
                          ),
                          _infoTile(
                            'เบอร์โทรศัพท์',
                            profileProvider.phone, 
                            () => _editPhoneDialog(context, profileProvider),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('รหัสผ่าน'),
                          _infoTile('เปลี่ยนรหัสผ่าน', '',
                              () => _changePasswordDialog(context)),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoTile(String title, String? value, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0, 
      color: Colors.white.withOpacity(0.9), 
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: value != null && value.isNotEmpty
            ? Text(value, style: TextStyle(color: Colors.grey[600]))
            : null,
        trailing: const Icon(Icons.edit, color: Color(0xFF00C853)), 
        onTap: onTap,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }

  

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(150, 255, 255, 255)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  void _editProfileNameDialog(
      BuildContext context, ProfileProvider profileProvider) {
    TextEditingController nameController =
        TextEditingController(text: profileProvider.name);
    TextEditingController lastnameController =
        TextEditingController(text: profileProvider.lastname);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'แก้ไขชื่อ-นามสกุล',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'ชื่อ'),
                const SizedBox(height: 10),
                _buildTextField(lastnameController, 'นามสกุล'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _updateProfile({
                          'name': nameController.text,
                          'lastname': lastnameController.text,
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'บันทึก',
                        style: TextStyle(color: Color(0xFF221B64)),
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

  void _editEmailDialog(BuildContext context, ProfileProvider profileProvider) {
    TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขอีเมล',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(emailController, 'กรอกอีเมลใหม่'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showPasswordConfirmDialog(
                              context, emailController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ต่อไป',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _showPasswordConfirmDialog(BuildContext context, String newEmail) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขอีเมล',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(passwordController, 'กรุณาใส่รหัสผ่าน',
                      obscureText: true),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showOtpDialog(context, newEmail);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ยืนยัน',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _showOtpDialog(BuildContext context, String newEmail) {
    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขอีเมล',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(otpController, 'กรุณากรอก OTP'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _updateProfile({'email': newEmail});
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ยืนยัน',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _editPhoneDialog(BuildContext context, ProfileProvider profileProvider) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขเบอร์โทรศัพท์',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(passwordController, 'กรุณากรอกรหัสผ่าน',
                      obscureText: true),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showPhoneConfirmDialog(context, profileProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ต่อไป',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _showPhoneConfirmDialog(
      BuildContext context, ProfileProvider profileProvider) {
    TextEditingController newPhoneController =
        TextEditingController(text: profileProvider.phone);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขเบอร์โทรศัพท์',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(
                      newPhoneController, 'กรุณากรอกเบอร์โทรศัพท์ใหม่'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showPhoneOtpDialog(context, newPhoneController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ยืนยัน',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _showPhoneOtpDialog(BuildContext context, String newPhone) {
    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขเบอร์โทรศัพท์',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(otpController, 'กรุณากรอกรหัส OTP'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _updateProfile({'phone': newPhone});
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ยืนยัน',
                            style: TextStyle(color: Color(0xFF221B64))),
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
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขรหัสผ่าน',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(passwordController, 'กรุณากรอกรหัสผ่าน',
                      obscureText: true),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showPasswordConfirmEmailDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ต่อไป',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _showPasswordConfirmEmailDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขรหัสผ่าน',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(emailController, 'กรุณากรอกอีเมล'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showPasswordOtpDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ยืนยัน',
                            style: TextStyle(color: Color(0xFF221B64))),
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

  void _showPasswordOtpDialog(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmNewPasswordController =
        TextEditingController();
    TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('แก้ไขรหัสผ่าน',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(newPasswordController, 'รหัสผ่านใหม่',
                      obscureText: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                      confirmNewPasswordController, 'ยืนยันรหัสผ่านใหม่',
                      obscureText: true),
                  const SizedBox(height: 10),
                  _buildTextField(otpController, 'รหัส OTP'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _changePassword(
                            newPasswordController.text,
                            confirmNewPasswordController.text,
                          );
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('บันทึก',
                            style: TextStyle(color: Color(0xFF221B64))),
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
}