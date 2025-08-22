import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';

class Student {
  final String name;
  int score;

  Student({required this.name, this.score = 0});
}

class ClassroomSubject extends StatefulWidget {
  const ClassroomSubject({Key? key}) : super(key: key);

  @override
  State<ClassroomSubject> createState() => _ClassroomSubjectState();
}

class _ClassroomSubjectState extends State<ClassroomSubject> {
  List<Student> students = [
    Student(name: 'สมชาย ใจดี'),
    Student(name: 'กิตติศักดิ์ สาระดี'),
    Student(name: 'สุดารัตน์ พงษ์ศรี'),
    Student(name: 'นริศรา ใจงาม'),
  ];

  void _removeStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  String getInitials(String fullName) {
    List<String> parts = fullName.split(' ');
    String firstInitial =
        parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    String lastInitial =
        parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
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
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16), 
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('ห้องเรียน',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/classroom_settings');
                                    },
                                    child:
                                        const Icon(Icons.settings), 
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Column(
                                children: const [
                                  Text('ชื่อวิชา',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('เลขห้องเรียน',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                  SizedBox(height: 4),
                                  Text('รหัสห้องเรียน',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  Icon(Icons.people,
                                      color: Color(0xFF3F8FAF)),
                                  SizedBox(width: 8),
                                  Text('รายชื่อนักเรียน',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1, thickness: 1),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                final initials = getInitials(student.name);
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(0, 1)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            const Color(0xFF3F8FAF),
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Text(
                                              'แต้มสะสม: 0 % | คะแนนพิเศษ: 0 คะแนน',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _removeStudent(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_pin, color: Colors.pink),
                                SizedBox(width: 6),
                                Text('ตำแหน่ง',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://maps.googleapis.com/maps/api/staticmap?center=13.736717,100.523186&zoom=15&size=200x120&maptype=roadmap&markers=color:red%7C13.736717,100.523186&key=YOUR_GOOGLE_MAPS_API_KEY',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 100,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/classroom_report');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F8FAF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('ข้อมูลการเข้าชั้นเรียน',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/classroom_check');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F8FAF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('การเช็คชื่อเข้าชั้นเรียน',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, context: context),
    );
  }
}
