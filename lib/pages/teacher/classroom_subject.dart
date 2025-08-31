import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:edunudge/services/api_service.dart';

class Student {
  final int id;
  final String name;
  double score;

  Student({required this.id, required this.name, this.score = 0});
}

class ClassroomSubject extends StatefulWidget {
  final int classroomId;

  const ClassroomSubject({Key? key, required this.classroomId}) : super(key: key);

  @override
  State<ClassroomSubject> createState() => _ClassroomSubjectState();
}

class _ClassroomSubjectState extends State<ClassroomSubject> {
  List<Student> students = [];
  String subjectName = '';
  String roomNumber = '';
  String classroomCode = '';
  bool isLoading = true;

  LatLng classroomLocation = const LatLng(13.736717, 100.523186); // พิกัดตัวอย่าง

  @override
  void initState() {
    super.initState();
    fetchClassroomData();
  }

  Future<void> fetchClassroomData() async {
    try {
      final data = await ApiService.getTeacherClassroomDetail(widget.classroomId).catchError((e) {
        throw Exception('Failed to load classroom data: $e');
      });
      print('Classroom Data: $data');
      setState(() {
        subjectName = data['name_subject'] ?? '';
        roomNumber = data['room_number'] ?? '';
        print('students: $subjectName');

        // แปลง students
        students = (data['students'] as List<dynamic>?)
        ?.map((e) => Student(
              id: e['user_id'], // ใช้ hash ของชื่อแทน id ถ้าไม่มี id จริง
              name: '${e['name']} ${e['lastname']}',
              score: e['point_percent'] ?? 0,
            ))
        .toList() ?? [];
        print('students: $students');

        // ถ้ามีพิกัดห้องเรียนจริงจาก backend
        if (data['latitude'] != null && data['longitude'] != null) {
          classroomLocation = LatLng(
            double.tryParse(data['latitude'].toString()) ?? classroomLocation.latitude,
            double.tryParse(data['longitude'].toString()) ?? classroomLocation.longitude,
          );
        }

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching classroom data: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ไม่สามารถโหลดข้อมูลห้องเรียนได้')));
    }
  }

  void _removeStudent(int index) async {
    final student = students[index];
    try {
      await ApiService.removeStudent(widget.classroomId, student.id);
      setState(() => students.removeAt(index));
    } catch (e) {
      print('Failed to remove student: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ลบนักศึกษาไม่สำเร็จ')));
    }
  }

  String getInitials(String fullName) {
    List<String> parts = fullName.split(' ');
    String firstInitial = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    String lastInitial = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$firstInitial$lastInitial';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF00C853),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ห้องเรียน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/classroom_settings',
                  arguments: widget.classroomId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ข้อมูลห้องเรียน
                  Center(
                    child: Column(
                      children: [
                        Text(subjectName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(roomNumber,
                            style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(classroomCode,
                            style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ปุ่ม Report / Check
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/classroom_report',
                                arguments: widget.classroomId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('ข้อมูลการเข้าชั้นเรียน',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/classroom_check',
                                arguments: widget.classroomId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('การเช็คชื่อเข้าชั้นเรียน',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // รายชื่อนักเรียน
                  const Row(
                    children: [
                      Icon(Icons.people, color: Color(0xFF3F8FAF)),
                      SizedBox(width: 8),
                      Text('รายชื่อนักเรียน',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 16, thickness: 1),
                  ListView.builder(
                    itemCount: students.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final initials = getInitials(student.name);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 1)),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF00C853),
                              child: Text(initials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    'แต้มสะสม: ${student.score} % | คะแนนพิเศษ: 0 คะแนน',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeStudent(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // กรอบตำแหน่งห้องเรียน
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_pin,
                                color: Color.fromARGB(255, 255, 21, 0)),
                            SizedBox(width: 8),
                            Text('ตำแหน่งห้องเรียน',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: classroomLocation,
                              zoom: 16,
                            ),
                            markers: {
                              Marker(
                                  markerId: const MarkerId('classroom'),
                                  position: classroomLocation)
                            },
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            mapType: MapType.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
