import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String formattedDate = DateFormat('dd MMMM yyyy', 'th').format(DateTime.now());
  final List<String> statusList = List.filled(10, '');

  
  final List<String> studentNames = [
    'สมชาย ใจดี',
    'กิตติศักดิ์ สาระดี',
    'สุดารัตน์ พงษ์ศรี',
    'นริศรา ใจงาม',
    'อภิชาติ แสนดี',
    'วิชาญ บุญมา',
    'ภานุพงศ์ ทองดี',
    'ดารารัตน์ ทองคำ',
    'สุชาติ รักดี',
    'พรทิพย์ พูลสุข',
  ];

  
  String getInitials(String fullName) {
    List<String> parts = fullName.split(' ');
    String firstInitial = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    String lastInitial = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$firstInitial$lastInitial';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C853), 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          onLogoutTap: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ),
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
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'การเช็คชื่อเข้าชั้นเรียน',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24, color: Colors.grey, thickness: 1.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F8FAF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.people, color: Color(0xFF3F8FAF)),
                          SizedBox(width: 8),
                          Text('รายชื่อนักเรียน',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Column(
                        children: List.generate(10, (index) => _buildStudentRow(index)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/classroom_subject');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.white, fontSize: 16), 
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/classroom_subject');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'เสร็จสิ้น',
                            style: TextStyle(color: Colors.white, fontSize: 16), 
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
        ),
      ),
    );
  }

  Widget _buildStudentRow(int index) {
    final studentName = studentNames[index];
    final initials = getInitials(studentName);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x336D6D6D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF3F8FAF),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(studentName, style: const TextStyle(color: Colors.black, fontSize: 14)),
          ),
          Expanded(child: _buildStatusButton(index, 'ขาด', 'FF1800')), 
          const SizedBox(width: 4),
          Expanded(child: _buildStatusButton(index, 'สาย', 'FFAB40')), 
          const SizedBox(width: 4),
          Expanded(child: _buildStatusButton(index, 'มา', '00C853')), 
          const SizedBox(width: 4),
          Expanded(child: _buildStatusButton(index, 'ลา', '2979FF')), 
        ],
      ),
    );
  }

  Widget _buildStatusButton(int index, String text, String hexColor) {
    final isSelected = statusList[index] == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          statusList[index] = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(int.parse('0xFF$hexColor')) : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
