import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:edunudge/shared/customappbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final classrooms = List.generate(20, (index) => {
          'subject': 'ชื่อวิชา ${index + 1}',
          'room': 'เลขห้องเรียน ${100 + index}',
          'teacher': 'ชื่ออาจารย์ผู้สอน ${index + 1}'
        });

    return Scaffold(
      backgroundColor: Color(0xFF221B64),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: classrooms.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            final classroom = classrooms[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/classroom_subject',
                  arguments: {
                    'subject': classroom['subject'],
                    'room': classroom['room'],
                    'teacher': classroom['teacher'],
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classroom['subject']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${classroom['room']}'), // แสดงเลขห้องเรียน
                    const SizedBox(height: 4),
                    Text('รหัสห้องเรียน: 12345', style: TextStyle(fontSize: 13, color: Colors.grey[700])), // ตัวอย่างรหัสห้องเรียน
                    const Divider(),
                    Text(classroom['teacher']!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
    );
  }
}
