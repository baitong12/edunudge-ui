import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  String email = "example@email.com";
  String phone = "0812345678";

  void _editField(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('แก้ไข$title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'กรอก$titleใหม่'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    } else if (parts.isNotEmpty) {
      return parts[0][0];
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final name = profileProvider.name;

    return Scaffold(
      backgroundColor: const Color(0xFF221B64),
      appBar: AppBar(
        title: const Text('', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เสร็จสิ้น', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueGrey,
                child: Text(
                  _getInitials(name),
                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            _sectionTitle('ข้อมูลส่วนตัว'),
            _infoTile('ชื่อ–นามสกุล', name, () {
              _editField('ชื่อ–นามสกุล', name, (val) {
                Provider.of<ProfileProvider>(context, listen: false).setName(val);
              });
            }),
            _infoTile('อีเมล', email, () {
              _editField('อีเมล', email, (val) => setState(() => email = val));
            }),
            _infoTile('เบอร์โทรศัพท์', phone, () {
              _editField('เบอร์โทรศัพท์', phone, (val) => setState(() => phone = val));
            }),
            const SizedBox(height: 20),
            _sectionTitle('รหัสผ่าน'),
            _infoTile('เปลี่ยนรหัสผ่าน', '', () {
              _editField('รหัสผ่าน', '', (val) {
                // TODO: save new password securely
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: value.isNotEmpty ? Text(value) : null,
        trailing: const Text('แก้ไข >'),
        onTap: onTap,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
