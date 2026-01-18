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
  bool isLoading = false;
  late Map<String, dynamic> classroomInfo;
  late GoogleMapController _mapController;

  static const LatLng _defaultLocation = LatLng(13.736717, 100.523186);

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
    if (!await Geolocator.isLocationServiceEnabled()) {
      return _setDefaultLocation();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _setDefaultLocation();
      }
    }

    try {
      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
      selectedLocation = _defaultLocation;
      selectedMarker = Marker(
        markerId: const MarkerId('defaultLocation'),
        position: _defaultLocation,
      );
    });
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
      _showSnackBar('ไม่สามารถหาตำแหน่งปัจจุบันได้', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87, size: 28),
            onPressed: () => _showHelpDialog(),
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

  void _showHelpDialog() {
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
  }

  Widget _buildLocationPicker() {
    if (selectedLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(target: selectedLocation!, zoom: 14),
          markers: selectedMarker != null ? {selectedMarker!} : {},
          onTap: (latLng) => _updateSelectedLocation(latLng),
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

  void _updateSelectedLocation(LatLng latLng) {
    _showSnackBar(
      'เลือกตำแหน่ง: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
      Colors.green,
    );
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
  }

  Future<void> submitClassroom() async {
    if (!_validateLocation()) {
      print('validateLocation: false');
      print('selectedLocation: $selectedLocation');
      print('lat: ${selectedLocation!.latitude}');
      print('lng: ${selectedLocation!.longitude}');
      print('lat >= -90: ${selectedLocation!.latitude >= -90}');
      print('lng >= -180: ${selectedLocation!.longitude >= -180}');
      print('lat == 0.0 && lng == 0.0: ${selectedLocation!.latitude == 0.0 && selectedLocation!.longitude == 0.0}');
      print('lat == 13.736717 && lng == 100.523186: ${selectedLocation!.latitude == 13.736717 && selectedLocation!.longitude == 100.523186}');
      _showSnackBar('กรุณาเลือกตำแหน่งห้องเรียน', Colors.red);
      return;
    }

    if (!_validateClassroomData()) {
      _showSnackBar('กรุณากรอกข้อมูลให้ครบถ้วนทุกช่อง', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final payload = _buildPayload();
      await ApiService.createClassroom(payload);
      _showSnackBar('สร้างห้องเรียนสำเร็จ', Colors.green);
      Navigator.pushNamedAndRemoveUntil(context, '/home_teacher', (r) => false);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateLocation() {
    print('selectedLocation: $selectedLocation');
    print('selectedLocation: ${selectedLocation!.latitude}');
    print('selectedLocation: ${selectedLocation!.longitude}');

    if (selectedLocation == null) return false;

    final location = selectedLocation!;
    final lat = location.latitude;
    final lng = location.longitude;
    print('lat: $lat');
    print('lng: $lng');
    // ตรวจสอบว่าเป็นพิกัดที่ถูกต้อง
    final isValidCoordinate = lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
    print('isValidCoordinate: $isValidCoordinate');
    // ตรวจสอบว่าไม่ใช่พิกัด (0, 0) - มักเป็นค่า default ที่ไม่ถูกต้อง
    final isNotZero = !(lat == 0.0 && lng == 0.0);
    print('isNotZero: $isNotZero');
    // ตรวจสอบว่าไม่ใช่ default location (ตำแหน่งเริ่มต้น)
    final isNotDefault = lat != _defaultLocation.latitude ||
        lng != _defaultLocation.longitude;
    print('defaultLocation: ${_defaultLocation.latitude}');
    print('defaultLocation: ${_defaultLocation.longitude}');
    print('isNotDefault: $isNotDefault');
    return isValidCoordinate && isNotZero && isNotDefault;
  }

  bool _validateClassroomData() {
    final requiredDays = classroomInfo['required_days'] ?? 0;
    final rewardPoints = classroomInfo['reward_points'] ?? 0;
    final points = classroomInfo['points'] ?? [];
    final schedules = classroomInfo['schedules'] ?? [];
    final semester = classroomInfo['semester'] ?? '';
    final year = classroomInfo['year'] ?? '';
    final startDate = classroomInfo['start_date'] ?? '';
    final endDate = classroomInfo['end_date'] ?? '';

    return requiredDays >= 1 &&
        rewardPoints >= 1 &&
        points.isNotEmpty &&
        schedules.isNotEmpty &&
        semester.isNotEmpty &&
        year.isNotEmpty &&
        startDate.isNotEmpty &&
        endDate.isNotEmpty;
  }

  Map<String, dynamic> _buildPayload() {
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

    return {
      "name_subject": classroomInfo['name_subject'] ?? '',
      "room_number": classroomInfo['room_number'] ?? '',
      "latitude": selectedLocation!.latitude,
      "longitude": selectedLocation!.longitude,
      "required_days": classroomInfo['required_days'] ?? 0,
      "reward_points": classroomInfo['reward_points'] ?? 0,
      "points": (classroomInfo['points'] ?? [])
          .map((p) => {
                "point_percent": p['point_percent'] ?? 0,
                "point_extra": p['point_extra'] ?? 0,
              })
          .toList(),
      "terms": [
        {
          "semester": classroomInfo['semester'] ?? '1',
          "year": year,
          "start_date": classroomInfo['start_date'] ?? '',
          "end_date": classroomInfo['end_date'] ?? '',
        }
      ],
      "schedules": (classroomInfo['schedules'] ?? [])
          .map((s) => {
                "day_of_week": s['day_of_week'] ?? '',
                "time_start": s['time_start'] ?? '',
                "time_end": s['time_end'] ?? '',
              })
          .toList(),
    };
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
            height: screenHeight - bottomNavHeight - 64,
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
                _buildHeader('สร้างห้องเรียน'),
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
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/classroom_create01', (r) => false,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ยกเลิก',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEAA7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: submitClassroom,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'ตกลง',
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
