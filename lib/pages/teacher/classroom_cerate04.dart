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

  late Map<String, dynamic> classroomInfo;
  late GoogleMapController _mapController;

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
    } catch (_) {
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

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLocation = currentLatLng;
        selectedMarker = Marker(
          markerId: const MarkerId('selectedLocation'),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: 'ตำแหน่งปัจจุบัน'),
        );
      });

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 16),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถหาตำแหน่งปัจจุบันได้'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget buildHeader(String title) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('คู่มือการใช้งาน'),
                  content: const Text(
                      'แตะบนแผนที่เพื่อเลือกตำแหน่งห้องเรียน หรือกดปุ่มตำแหน่งปัจจุบัน'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ปิด'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker() {
    if (selectedLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(
            target: selectedLocation!,
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
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> submitClassroom() async {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกตำแหน่งห้องเรียน'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    int year = 2023;
    if (classroomInfo['year'] != null) {
      int? inputYear = classroomInfo['year'] is int
          ? classroomInfo['year']
          : int.tryParse(classroomInfo['year'].toString());
      if (inputYear != null) {
        if (inputYear > 2500) inputYear -= 543;
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
    const bottomNavHeight = 60.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Container(
            width: double.infinity,
            height: screenHeight - bottomNavHeight - 32 - 32, 
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF91C8E4),
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
              children: [
                buildHeader('สร้างห้องเรียน'),
                const Divider(height: 24, thickness: 1, color: Colors.grey),
                const Text(
                  'เลือกตำแหน่งห้องเรียนด้านล่าง',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildLocationPicker()),
                const SizedBox(height: 12),
                const Text(
                  'หมายเหตุ: หลังจากสร้างห้องเสร็จสิ้น กรุณาตั้งค่าเวลาการแจ้งเตือน\n'
                  'ระดับสีเขียวคือก่อนถึงเวลาเรียน\n'
                  'ระดับสีแดงคือเลยเวลาเรียน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(221, 255, 2, 2),
                  ),
                ),
                const SizedBox(height: 12),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFEAA7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: submitClassroom,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('ตกลง',
                              style:
                                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
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
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }
}
