import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:edunudge/services/api_service.dart';

class Student {
  final int id;
  final String name;
  final String? phone;
  double score;
  double percentScore;

  Student({
    required this.id,
    required this.name,
    this.phone,
    this.score = 0.0,
    this.percentScore = 0.0,
  });
}

class ClassroomSubject extends StatefulWidget {
  final int classroomId;

  const ClassroomSubject({Key? key, required this.classroomId})
      : super(key: key);

  @override
  State<ClassroomSubject> createState() => _ClassroomSubjectState();
}

class _ClassroomSubjectState extends State<ClassroomSubject> {
  List<Student> students = [];
  String subjectName = '';
  String roomNumber = '';
  bool isLoading = true;
  LatLng classroomLocation = const LatLng(13.736717, 100.523186);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    fetchClassroomData();
  }

  Future<void> fetchClassroomData() async {
    try {
      final data = await ApiService.getTeacherClassroomDetail(widget.classroomId)
          .catchError((e) {
        throw Exception('Failed to load classroom data: $e');
      });

      setState(() {
        subjectName = data['name_subject'] ?? '';
        roomNumber = data['room_number'] ?? '';
        students = (data['students'] as List<dynamic>?)
                ?.map(
                  (e) => Student(
                    id: e['user_id'],
                    name: '${e['name']} ${e['lastname']}',
                    phone: e['phone'],
                    score: double.tryParse((e['score'] ?? 0).toString()) ?? 0.0,
                    percentScore:
                        double.tryParse((e['point_percent'] ?? 0).toString()) ?? 0.0,
                  ),
                )
                .toList() ??
            [];

        if (data['latitude'] != null && data['longitude'] != null) {
          double lat = double.tryParse(data['latitude'].toString()) ??
              classroomLocation.latitude;
          double lng = double.tryParse(data['longitude'].toString()) ??
              classroomLocation.longitude;
          classroomLocation = LatLng(lat, lng);
          _mapController?.moveCamera(
            CameraUpdate.newLatLngZoom(classroomLocation, 16),
          );
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถโหลดข้อมูลห้องเรียนได้')),
      );
    }
  }

  void _confirmRemoveStudent(int index) async {
    final student = students[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบ ${student.name} ออกจากห้องเรียนหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _removeStudent(index);
    }
  }

  void _removeStudent(int index) async {
    final student = students[index];
    try {
      await ApiService.removeStudent(widget.classroomId, student.id);
      setState(() => students.removeAt(index));
    } catch (e) {
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController!.moveCamera(
      CameraUpdate.newLatLngZoom(classroomLocation, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.04;
    final double avatarRadius = size.width * 0.06;
    final double buttonHeight = size.height * 0.06;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'ห้องเรียน: $roomNumber',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/classroom_settings',
                arguments: widget.classroomId,
              );
              if (result == true) fetchClassroomData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF91C8E4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/classroom_check',
                          arguments: widget.classroomId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFEAA7),
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
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/classroom_report',
                          arguments: widget.classroomId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F8FAF),
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
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: const Color(0xFF3F8FAF)),
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
                      ListView.builder(
                        itemCount: students.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final initials = getInitials(student.name);
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmRemoveStudent(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: size.height * 0.02),
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
                                const Icon(
                                  Icons.location_pin,
                                  color: Color.fromARGB(255, 255, 21, 0),
                                ),
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
