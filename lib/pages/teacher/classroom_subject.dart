import 'package:flutter/material.dart';
//  นำเข้า Flutter Material UI สำหรับสร้างหน้าจอหลัก (Scaffold, Text, AppBar, Icon, Button, etc.)

import 'package:google_maps_flutter/google_maps_flutter.dart';
//  นำเข้า Google Maps Flutter สำหรับแสดงแผนที่ห้องเรียน

import 'package:edunudge/services/api_service.dart';
//  นำเข้า ApiService ของเรา เพื่อดึงข้อมูลห้องเรียนและจัดการ API

// ====================== MODEL ======================
class Student {
  final int id;            // รหัสนักศึกษา (user_id จาก backend)
  final String name;       // ชื่อ-นามสกุลของนักศึกษา
  final String? phone;     // เบอร์โทรศัพท์ (nullable อาจไม่มีข้อมูล)
  double score;            // คะแนนสะสม (ค่าตัวเลข)
  double percentScore;     // คะแนนเปอร์เซ็นต์ (0 - 100)

  Student({
    required this.id,       // ต้องใส่ค่า id ทุกครั้ง
    required this.name,     // ต้องใส่ชื่อทุกครั้ง
    this.phone,             // phone อาจไม่มี
    this.score = 0.0,       // ค่าเริ่มต้น = 0
    this.percentScore = 0.0,// ค่าเริ่มต้น = 0
  });
}
//  คลาส Student ใช้เก็บข้อมูลนักศึกษาแต่ละคนในห้องนี้


// ====================== WIDGET หลัก ======================
class ClassroomSubject extends StatefulWidget {
  final int classroomId; // id ห้องเรียนที่รับมาจากหน้าอื่น

  const ClassroomSubject({Key? key, required this.classroomId})
      : super(key: key);

  @override
  State<ClassroomSubject> createState() => _ClassroomSubjectState();
}
//  StatefulWidget เพราะข้อมูลจะเปลี่ยนแปลงได้ (โหลดจาก API, ลบ/แก้ไข)


class _ClassroomSubjectState extends State<ClassroomSubject> {
  List<Student> students = [];   // เก็บลิสต์นักศึกษา
  String subjectName = '';       // ชื่อวิชา
  String roomNumber = '';        // เลขห้องเรียน
  bool isLoading = true;         // state โหลดข้อมูล
  LatLng classroomLocation = const LatLng(13.736717, 100.523186); 
  // ค่า default = กทม.

  GoogleMapController? _mapController; // ตัวควบคุม Google Map


  @override
  void initState() {
    super.initState();
    fetchClassroomData(); // โหลดข้อมูลห้องเรียนทันทีเมื่อเข้าหน้านี้
  }

  // ====================== ดึงข้อมูลจาก API ======================
  Future<void> fetchClassroomData() async {
    try {
      final data = await ApiService.getTeacherClassroomDetail(widget.classroomId)
          .catchError((e) {
        throw Exception('Failed to load classroom data: $e');
      });
      //  เรียก API เพื่อนำข้อมูลห้องเรียน + นักศึกษา

      setState(() {
        subjectName = data['name_subject'] ?? ''; // กำหนดชื่อวิชา
        roomNumber = data['room_number'] ?? '';   // กำหนดเลขห้อง

        //  สร้างลิสต์ Student จากข้อมูล JSON
        students = (data['students'] as List<dynamic>?)
                ?.map(
                  (e) => Student(
                    id: e['user_id'], // user_id
                    name: '${e['name']} ${e['lastname']}', // รวมชื่อ + นามสกุล
                    phone: e['phone'], // เบอร์
                    score: double.tryParse((e['score'] ?? 0).toString()) ?? 0.0,
                    //  parse คะแนนสะสม
                    percentScore:
                        double.tryParse((e['point_percent'] ?? 0).toString()) ?? 0.0,
                    //  parse คะแนนเปอร์เซ็นต์
                  ),
                )
                .toList() ??
            [];

        //  ถ้ามีพิกัดห้องเรียน ให้ update แผนที่
        if (data['latitude'] != null && data['longitude'] != null) {
          double lat = double.tryParse(data['latitude'].toString()) ??
              classroomLocation.latitude;
          double lng = double.tryParse(data['longitude'].toString()) ??
              classroomLocation.longitude;
          classroomLocation = LatLng(lat, lng);

          //  ขยับกล้องไปยังตำแหน่งห้องเรียน
          _mapController?.moveCamera(
            CameraUpdate.newLatLngZoom(classroomLocation, 16),
          );
        }

        isLoading = false; // โหลดเสร็จ
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถโหลดข้อมูลห้องเรียนได้')),
      );
    }
  }

  // ====================== ลบนักศึกษา ======================
  void _confirmRemoveStudent(int index) async {
    final student = students[index]; // นักศึกษาที่จะลบ
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบ ${student.name} ออกจากห้องเรียนหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // ยกเลิก
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // ตกลงลบ
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _removeStudent(index); // ถ้ายืนยัน -> ลบ
    }
  }

  void _removeStudent(int index) async {
    final student = students[index];
    try {
      await ApiService.removeStudent(widget.classroomId, student.id); 
      //  เรียก API ลบนักศึกษา
      setState(() => students.removeAt(index)); 
      //  เอาออกจากลิสต์ใน state
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ลบนักศึกษาไม่สำเร็จ')));
    }
  }

  // ====================== Utility: ตัวอักษรย่อชื่อ ======================
  String getInitials(String fullName) {
    List<String> parts = fullName.split(' '); // แยกชื่อ-นามสกุล
    String firstInitial = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    String lastInitial = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return '$firstInitial$lastInitial'; // เช่น "สมชาย ใจดี" -> "สจ"
  }

  // ====================== Google Map ======================
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController!.moveCamera(
      CameraUpdate.newLatLngZoom(classroomLocation, 16), // ขยับกล้องไปที่ห้องเรียน
    );
  }

  // ====================== BUILD UI ======================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // ขนาดหน้าจอ
    final double padding = size.width * 0.04; 
    final double avatarRadius = size.width * 0.06;
    final double buttonHeight = size.height * 0.06;

    if (isLoading) {
      //  ถ้ายังโหลดข้อมูล -> วงกลม loading
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // พื้นหลัง AppBar
        elevation: 0, // ไม่มีเงา
        iconTheme: const IconThemeData(color: Colors.black), // icon สีดำ
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName, // ชื่อวิชา
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'เลขห้องเรียน: $roomNumber', // หมายเลขห้อง
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        centerTitle: false, // จัดซ้าย
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black), // ปุ่มตั้งค่า
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/classroom_settings', // ไปหน้า settings
                arguments: widget.classroomId,
              );
              if (result == true) fetchClassroomData(); // กลับมาแล้ว reload
            },
          ),
        ],
      ),

      // ====================== BODY ======================
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF91C8E4), // พื้นหลังฟ้า
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  ปุ่ม "การเช็คชื่อเข้าเรียน" และ "ข้อมูลการเข้าเรียน"
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ปุ่มการเช็คชื่อ
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/classroom_check',
                          arguments: widget.classroomId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFEAA7), // สีเหลือง
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.5,
                            horizontal: size.width * 0.02,
                          ),
                          child: Text(
                            'การเช็คชื่อเข้าเรียน',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.035,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),

                    // ปุ่มข้อมูลการเข้าเรียน
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/classroom_report',
                          arguments: widget.classroomId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F8FAF), // สีฟ้าเข้ม
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.5,
                            horizontal: size.width * 0.02,
                          ),
                          child: Text(
                            'ข้อมูลการเข้าเรียน',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              //  ส่วนรายชื่อนักศึกษา
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: Color(0xFF3F8FAF)),
                          SizedBox(width: size.width * 0.02),
                          const Text(
                            'รายชื่อนักศึกษา',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: size.height * 0.02, thickness: 1),

                      //  แสดงรายชื่อนักศึกษาแบบ list
                      ListView.builder(
                        itemCount: students.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final initials = getInitials(student.name); // อักษรย่อ

                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.008,
                            ),
                            padding: EdgeInsets.all(size.width * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Avatar อักษรย่อ
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: const Color(0xFFFFFBDE),
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),

                                // ข้อมูลนักศึกษา
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: TextStyle(
                                          fontSize: size.width * 0.035,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.005),
                                      Text(
                                        'เบอร์: ${student.phone ?? '-'}',
                                        style: TextStyle(
                                          fontSize: size.width * 0.028,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.002),
                                      Text(
                                        'คะเเนนสะสม: ${student.score.toStringAsFixed(2)} | คะแนนเปอร์เซ็นต์: ${student.percentScore.toStringAsFixed(2)} %',
                                        style: TextStyle(
                                          fontSize: size.width * 0.028,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ปุ่มลบ
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmRemoveStudent(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: size.height * 0.02),

                      //  ส่วนตำแหน่งห้องเรียน (Google Map)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(size.width * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_pin,
                                    color: Color.fromARGB(255, 255, 21, 0)),
                                SizedBox(width: size.width * 0.02),
                                Text(
                                  'ตำแหน่งห้องเรียน',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.04,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.01),
                            SizedBox(
                              height: size.height * 0.25,
                              width: double.infinity,
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: classroomLocation,
                                  zoom: 16,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('classroom'),
                                    position: classroomLocation,
                                  ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
