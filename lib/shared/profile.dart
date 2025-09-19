import 'package:edunudge/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edunudge/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPageLoading = false;

  @override
  void initState() {
    super.initState();
    _setInitialProfileData();
  }

  void _setInitialProfileData() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      profileProvider.setProfileData(
        name: prefs.getString('user_name') ?? '',
        lastname: prefs.getString('user_lastname') ?? '',
        email: prefs.getString('user_email') ?? '',
        phone: prefs.getString('user_phone') ?? '',
      );
    } catch (e) {
      debugPrint('Failed to set initial profile data: $e');
    }
  }

  Future<void> _saveAndUpdateProfile(Map<String, String?> fields) async {
    if (!mounted) return;
    
      final prefs = await SharedPreferences.getInstance();
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      for (var entry in fields.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value == null) continue;

        switch (key) {
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
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool autofocus = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
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

  Future<void> _buildProfileDialog({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required String actionButtonText,
    required VoidCallback onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...children,
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
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        actionButtonText,
                        style: const TextStyle(color: Color(0xFF221B64)),
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
    final lastnameController = TextEditingController(text: profileProvider.lastname);

    _buildProfileDialog(
      context: context,
      title: 'แก้ไขชื่อ–นามสกุล',
      actionButtonText: 'บันทึก',
      children: [
        _buildTextField(nameController, 'ชื่อ'),
        const SizedBox(height: 10),
        _buildTextField(lastnameController, 'นามสกุล'),
      ],
      onSave: () async {
        final name = nameController.text.trim();
        final lastname = lastnameController.text.trim();
        if (name.isEmpty || lastname.isEmpty) {
          showMessage('กรุณากรอกชื่อและนามสกุล');
          return;
        }

        try {
          final response = await ApiService.updateData({
            'field': 'name',
            'data': {'name': name, 'lastname': lastname},
          });

          if (response['status'] == 'success') {
            await _saveAndUpdateProfile({'name': name, 'lastname': lastname});
            Navigator.pop(context);
            showMessage(response['message'] ?? 'บันทึกสำเร็จ');
          } else {
            showMessage(response['message'] ?? 'เกิดข้อผิดพลาด');
          }
        } catch (e) {
          showMessage('เกิดข้อผิดพลาด: ${e.toString()}');
        }
      },
    );
  }

  void _updateEmailOrPhone({
    required BuildContext context,
    required ProfileProvider profileProvider,
    required String field,
  }) {
    final controller = TextEditingController(
      text: field == 'email' ? profileProvider.email : profileProvider.phone,
    );
    final passwordController = TextEditingController();

    _buildProfileDialog(
      context: context,
      title: field == 'email' ? 'แก้ไขอีเมล' : 'แก้ไขเบอร์โทรศัพท์',
      actionButtonText: 'ต่อไป',
      children: [
        _buildTextField(
          controller,
          field == 'email' ? 'กรอกอีเมลใหม่' : 'กรุณากรอกเบอร์โทร',
          keyboardType: field == 'email'
              ? TextInputType.emailAddress
              : TextInputType.phone,
          inputFormatters: field == 'phone'
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ]
              : null,
        ),
        const SizedBox(height: 10),
        _buildTextField(passwordController, 'กรอกรหัสผ่าน', obscureText: true),
      ],
      onSave: () async {
        final value = controller.text.trim();
        final password = passwordController.text.trim();

        if (value.isEmpty ||
            password.isEmpty ||
            (field == 'email' && !value.contains('@')) ||
            (field == 'phone' && value.length != 10)) {
          showMessage(
              'กรุณากรอกข้อมูลให้ครบถ้วน');
          return;
        }

        try {
          final response = await ApiService.updateData({
            'field': field,
            'data': field == 'email'
                ? {'newEmail': value, 'password': password}
                : {'phone': value, 'password': password},
          });

          if (response['status'] == 'success') {
            Navigator.of(context, rootNavigator: true).pop();
            _showOtpDialog(
              context: context,
              title:
                  'ยืนยัน OTP ${field == 'email' ? 'อีเมล' : 'เบอร์โทรศัพท์'}',
              onConfirm: (otp) async {
                final result = await ApiService.confirmOtp({
                  'otp': otp,
                  'field': field,
                });
                if (result['status'] == 'success') {
                  await _saveAndUpdateProfile({field: value});
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
    required String title,
    required Function(String otp) onConfirm,
  }) async {
    final otpController = TextEditingController();
    String? errorMessage;

    return showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.transparent,
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
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
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
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
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
                        onPressed: () async {
                          final otp = otpController.text.trim();
                          if (otp.isEmpty) {
                            setState(() => errorMessage = 'กรุณากรอก OTP');
                            return;
                          }

                          onConfirm(otp);
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
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    _buildProfileDialog(
      context: context,
      title: 'เปลี่ยนรหัสผ่าน',
      actionButtonText: 'บันทึก',
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
        final oldPass = oldPassController.text.trim();
        final newPass = newPassController.text.trim();
        final confirmPass = confirmPassController.text.trim();

        if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
          showMessage('กรุณากรอกข้อมูลให้ครบถ้วน');
          return;
        }

        if (newPass.length < 8) {
          showMessage('รหัสผ่านใหม่ต้องมีอย่างน้อย 8 ตัวอักษร');
          return;
        }

        if (newPass != confirmPass) {
          showMessage('รหัสผ่านใหม่ไม่ตรงกัน');
          return;
        }

        try {
          final response = await ApiService.updateData({
            'field': 'newPassword',
            'data': {'password': oldPass, 'newPassword': newPass},
          });

          if (response['status'] == 'success') {
            oldPassController.clear();
            newPassController.clear();
            confirmPassController.clear();
            showMessage(response['message']);
          } else {
            showMessage(response['error'] ?? 'เกิดข้อผิดพลาด');
          }
        } catch (e) {
          showMessage('เกิดข้อผิดพลาด: $e');
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _sectionTitle(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget _infoTile(String title, String? value, VoidCallback onTap) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        color: Colors.white.withOpacity(0.9),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: value != null && value.isNotEmpty
              ? Text(value, style: TextStyle(color: Colors.grey[600]))
              : null,
          trailing: const Icon(Icons.edit, color: Color(0xFF00B894)),
          onTap: onTap,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B894),  Color(0xFF91C8E4),],
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
                title: const Text(
                  'ข้อมูลส่วนตัว',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: _isPageLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${profileProvider.name} ${profileProvider.lastname}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _sectionTitle('ข้อมูลส่วนตัว'),
                          _infoTile(
                            'ชื่อ–นามสกุล',
                            '${profileProvider.name} ${profileProvider.lastname}',
                            () => _editProfileNameDialog(
                              context,
                              profileProvider,
                            ),
                          ),
                          _infoTile(
                            'อีเมล',
                            profileProvider.email,
                            () => _updateEmailOrPhone(
                              context: context,
                              profileProvider: profileProvider,
                              field: 'email',
                            ),
                          ),
                          _infoTile(
                            'เบอร์โทรศัพท์',
                            profileProvider.phone,
                            () => _updateEmailOrPhone(
                              context: context,
                              profileProvider: profileProvider,
                              field: 'phone',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('รหัสผ่าน'),
                          _infoTile(
                            'เปลี่ยนรหัสผ่าน',
                            '',
                            () => _changePasswordDialog(context),
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
