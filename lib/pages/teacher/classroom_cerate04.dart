import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:edunudge/services/api_service.dart';

class CreateClassroom04 extends StatefulWidget {
  const CreateClassroom04({super.key});

  @override
  State<CreateClassroom04> createState() => _CreateClassroom04State();
}

class _CreateClassroom04State extends State<CreateClassroom04> {
  LatLng? selectedLocation;
  Marker? selectedMarker;
  LatLng defaultLocation = const LatLng(13.736717, 100.523186);
  bool isLoading = false;

  // ข้อมูลจากหน้า 03
  late Map<String, dynamic> classroomInfo;

  final Map<String, String> weekDayMap = {
    'จันทร์': 'monday',
    'อังคาร': 'tuesday',
    'พุธ': 'wednesday',
    'พฤหัสบดี': 'thursday',
    'ศุกร์': 'friday',
    'เสาร์': 'saturday',
    'อาทิตย์': 'sunday',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) classroomInfo = Map.from(args);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return _setDefaultLocation();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _setDefaultLocation();
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        selectedMarker = Marker(
          markerId: const MarkerId('selectedLocation'),
          position: selectedLocation!,
        );
      });
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      selectedLocation = defaultLocation;
      selectedMarker = Marker(
        markerId: const MarkerId('defaultLocation'),
        position: defaultLocation,
      );
    });
  }

  Widget _buildLocationPicker() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: selectedLocation ?? defaultLocation,
            zoom: 14,
          ),
          markers: selectedMarker != null ? {selectedMarker!} : {},
          onTap: (latLng) {
            setState(() {
              selectedLocation = latLng;
              selectedMarker = Marker(
                markerId: const MarkerId('selectedLocation'),
                position: latLng,
                infoWindow: InfoWindow(
                  title: 'ตำแหน่งที่เลือก',
                  snippet:
                      'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}',
                ),
              );
            });
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Future<void> submitClassroom() async {
    if (selectedLocation == null) {
      // SnackBar แจ้งเตือนผู้ใช้เลือกตำแหน่ง
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกตำแหน่งห้องเรียน'),
          backgroundColor: Colors.red, // พื้นหลังสีแดง
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // ให้ลอยเหนือหน้าจอ
        ),
      );
      return; // ออกจากฟังก์ชันไม่ให้ทำงานต่อ
    }

    setState(() => isLoading = true);

    int year = 2023;
    if (classroomInfo['year'] != null) {
      int? inputYear;
      if (classroomInfo['year'] is int) {
        inputYear = classroomInfo['year'];
      } else {
        inputYear = int.tryParse(classroomInfo['year'].toString());
      }
      if (inputYear != null) {
        if (inputYear > 2500) inputYear = inputYear - 543;
        year = inputYear;
      }
    }

    final payload = {
      "name_subject": classroomInfo['name_subject'] ?? '',
      "room_number": classroomInfo['room_number'] ?? '',
      "latitude": selectedLocation!.latitude,
      "longitude": selectedLocation!.longitude,
      "required_days": classroomInfo['required_days'] ?? 0,
      "reward_points": classroomInfo['reward_points'] ?? 0,
      "points": (classroomInfo['points'] ?? []).map((p) => {
            "point_percent": p['point_percent'] ?? 0,
            "point_extra": p['point_extra'] ?? 0,
          }).toList(),
      "terms": [
        {
          "semester": classroomInfo['semester'] ?? '1',
          "year": year,
          "start_date": classroomInfo['start_date'] ?? '',
          "end_date": classroomInfo['end_date'] ?? '',
        }
      ],
      "schedules": (classroomInfo['schedules'] ?? []).map((s) => {
            "day_of_week": s['day_of_week'] ?? '',
            "time_start": s['time_start'] ?? '',
            "time_end": s['time_end'] ?? '',
          }).toList(),
    };

    try {
      await ApiService.createClassroom(payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สร้างห้องเรียนสำเร็จ'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home_teacher', (r) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF00C853),
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.71),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      const Text('สร้างห้องเรียน',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const Divider(height: 24, thickness: 1, color: Colors.grey),
                      Row(
                        children: const [
                          Icon(Icons.add_location_alt, color: Colors.red),
                          SizedBox(width: 8),
                          Text('ตำแหน่งห้องเรียน',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildLocationPicker(),
                      const SizedBox(height: 24),
                      if (isLoading) const LinearProgressIndicator(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                                  context, '/classroom_create01', (r) => false),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('ยกเลิก',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: submitClassroom,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('ตกลง',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
        ),
      ),
    );
  }
}
