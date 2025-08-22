import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CreateClassroom04 extends StatefulWidget {
  const CreateClassroom04({super.key});

  @override
  State<CreateClassroom04> createState() => _CreateClassroom04State();
}

class _CreateClassroom04State extends State<CreateClassroom04> {
  final Color primaryColor = const Color(0xFF3F8FAF);

  LatLng? selectedLocation;
  Marker? selectedMarker;
  LatLng defaultLocation = const LatLng(13.736717, 100.523186); 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        selectedLocation = defaultLocation;
        selectedMarker = Marker(
          markerId: const MarkerId('defaultLocation'),
          position: defaultLocation,
        );
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          selectedLocation = defaultLocation;
          selectedMarker = Marker(
            markerId: const MarkerId('defaultLocation'),
            position: defaultLocation,
          );
        });
        return;
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
      setState(() {
        selectedLocation = defaultLocation;
        selectedMarker = Marker(
          markerId: const MarkerId('defaultLocation'),
          position: defaultLocation,
        );
      });
    }
  }

  Widget _buildLocationPicker() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF00C853),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () => Navigator.pushNamed(context, '/profile'),
          onLogoutTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
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
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Divider(height: 24, thickness: 1, color: Colors.grey),
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('ตำแหน่งห้องเรียน',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildLocationPicker(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/home_teacher');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'ตกลง',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomBottomNav(currentIndex: 1, context: context),
            ],
          ),
        ),
      ),
    );
  }
}
