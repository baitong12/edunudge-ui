import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:location/location.dart';

class Subject extends StatefulWidget {
  final String subject;
  final String room;
  final String teacher;

  const Subject({
    super.key,
    required this.subject,
    required this.room,
    required this.teacher,
  });

  @override
  State<Subject> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<Subject> {
  LocationData? userLocation;
  int currentWeek = 5; 

  final students = List.generate(
    10,
    (index) => {
      'name': 'ชื่อ-นามสกุล นักศึกษา ${index + 1}',
      'profile': null,
      'status': index % 4 == 0
          ? 'late'
          : index % 4 == 1
              ? 'absent'
              : index % 4 == 2
                  ? 'present'
                  : 'leave',
    },
  );

  
  Future<void> _getUserLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final currentLocation = await location.getLocation();
    setState(() => userLocation = currentLocation);
  }

  
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green; 
      case 'late':
        return Colors.orange; 
      case 'absent':
        return Colors.red; 
      case 'leave':
        return Colors.blue; 
      case 'no_class':
        return Colors.grey; 
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
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
            backgroundColor: Colors.transparent, 
            elevation: 0, 
            automaticallyImplyLeading: true, 
            title: const Text( 
              'รายละเอียดรายวิชา',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 20, 
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white), 
          ),
          body: ListView(
            padding: const EdgeInsets.all(16), 
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendDot(color: getStatusColor('present'), label: 'มาเรียน'),
                    _LegendDot(color: getStatusColor('late'), label: 'สาย'), 
                    _LegendDot(color: getStatusColor('absent'), label: 'ขาด'),
                    _LegendDot(color: getStatusColor('leave'), label: 'ลา'),
                    _LegendDot(color: getStatusColor('no_class'), label: 'ไม่มีเรียน'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreCard(
                      icon: Icons.close,
                      count: 2,
                      label: 'ขาดเรียน',
                      color: Colors.red,
                    ),
                    Container(height: 40, width: 1, color: Colors.grey.shade300),
                    _ScoreCard(
                      icon: Icons.access_time,
                      count: 1,
                      label: 'มาเรียนสาย',
                      color: Colors.orange,
                    ),
                    Container(height: 40, width: 1, color: Colors.grey.shade300),
                    _ScoreCard(
                      icon: Icons.star,
                      count: 20,
                      label: 'คะแนนสะสม',
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              
              Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Text(
                    widget.subject,
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    widget.room,
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 15), 
                  Text( 
                    '${widget.teacher}',
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 5), 
                  Text( 
                    'สัปดาห์ที่: $currentWeek',
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'เกณฑ์การให้คะแนน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(color: Colors.grey, thickness: 0.5, height: 20),
                    _buildGradeCriteriaRow(context, 'มาเรียนคิดเป็น:', '0 วัน', 'คะแนนสะสม:', '0 คะแนน'),
                    const SizedBox(height: 8),
                    _buildGradeCriteriaRow(context, 'มาเป็นเปอร์เซ็นต์:', '0%', 'คะแนนพิเศษ:', '0 คะแนน'),
                    const SizedBox(height: 8),
                    _buildGradeCriteriaRow(context, 'ขาดเป็นเปอร์เซ็นต์:', '0%', 'คะแนนพิเศษ:', '0 คะแนน'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('รายชื่อนักศึกษา',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        )),
                    const Divider(color: Colors.grey, thickness: 0.5, height: 20),
                    ...students.map((student) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 20,
                              child: Text(
                                student['name']![0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              student['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Icon(Icons.circle,
                                color: getStatusColor(student['status']!),
                                size: 12),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ตำแหน่ง',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        )),
                    const Divider(color: Colors.grey, thickness: 0.5, height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        elevation: 3,
                        shadowColor: const Color(0xFF00C853).withOpacity(0.5),
                      ),
                      child: const Text(
                        'แผนที่ห้องเรียน',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _getUserLocation,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        elevation: 3,
                        shadowColor: const Color(0xFF00C853).withOpacity(0.5),
                      ),
                      child: const Text(
                        'แผนที่นักศึกษา',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (userLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'ตำแหน่งของคุณ: (${userLocation!.latitude?.toStringAsFixed(4)}, ${userLocation!.longitude?.toStringAsFixed(4)})',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20), 
            ],
          ),
          bottomNavigationBar: CustomBottomNav(currentIndex: 2, context: context),
        ),
      ),
    );
  }

  
  Widget _buildGradeCriteriaRow(
      BuildContext context, String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '$label1 $value1',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            '$label2 $value2',
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}


class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _ScoreCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text('$count',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14)),
      ],
    );
  }
  }


class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500), 
        ),
      ],
    );
  }
}
