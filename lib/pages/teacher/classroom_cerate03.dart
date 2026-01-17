import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:edunudge/pages/teacher/manual.dart';

class CreateClassroom03 extends StatefulWidget { // สร้าง StatefulWidget สำหรับหน้าการตั้งค่าคะแนน
  const CreateClassroom03({super.key}); // constructor ปกติ

  @override
  State<CreateClassroom03> createState() => _CreateClassroom03State(); // สร้าง state
}

class _CreateClassroom03State extends State<CreateClassroom03> {
  final Color primaryColor = const Color(0xFFFFEAA7); // กำหนดสีหลักของ UI

  int _selectedItemCount = 1; // จำนวนเกณฑ์คะแนนที่ผู้ใช้ต้องการตั้งค่า (เริ่มต้น 1)
  final List<String> _itemCountOptions = ['1', '2', '3', '4', '5']; // option สำหรับจำนวนเกณฑ์

  // =======================
  // 🎯 ตัวเลือกคะแนนสะสม
  // =======================
  final List<String> _cumulativeScoreOptions = [
    '100 %',
    '90% ขึ้นไป',
    '80 % ขึ้นไป',
    '70 % ขึ้นไป',
    '60% ขึ้นไป',
    '50 % ขึ้นไป',
    '40 % ขึ้นไป',
    '30 % ขึ้นไป',
    '20 % ขึ้นไป',
    '10 % ขึ้นไป',
  ];

  // =======================
  // 🎯 ตัวเลือกคะแนนโบนัส
  // =======================
  final List<String> _bonusScoreOptions = List.generate(10, (index) => (index + 1).toString()); // 1-10

  // =======================
  // 🎯 ค่า selected ของ dropdown
  // =======================
  List<String?> _selectedCumulativeScores = List.filled(1, null); // ค่าเลือกคะแนนสะสม
  List<String?> _selectedBonusScores = List.filled(1, null); // ค่าเลือกคะแนนโบนัส

  // =======================
  // 🎯 Controller ของ TextField
  // =======================
  final TextEditingController _visitDaysController = TextEditingController(); // จำนวนวันที่ต้องเข้าเรียน
  final TextEditingController _scoreXController = TextEditingController(); // คะแนน X

  // =======================
  // 🎯 ตัวแปรตรวจสอบ error
  // =======================
  bool visitDaysError = false; // error จำนวนวัน
  bool scoreXError = false; // error คะแนน X
  List<bool> cumulativeError = List.filled(1, false); // error คะแนนสะสม
  List<bool> bonusError = List.filled(1, false); // error คะแนนโบนัส

  // =======================
  // 🎯 ตัวแปรรับ arguments จากหน้าก่อนหน้า
  // =======================
  late String nameSubject;
  late String roomNumber;
  late String academicYear;
  late String semester;
  late String startDateStr;
  late String endDateStr;
  late List<dynamic> schedules; // ตารางเรียน

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map; // ดึง arguments
    nameSubject = args['name_subject'];
    roomNumber = args['room_number'];
    academicYear = args['year'];
    semester = args['semester'];
    startDateStr = args['start_date'];
    endDateStr = args['end_date'];
    schedules = args['schedules'];
  }

  @override
  void dispose() { // ทำความสะอาด controller
    _visitDaysController.dispose();
    _scoreXController.dispose();
    super.dispose();
  }

  // =======================
  // 🎯 ฟังก์ชัน validate ข้อมูล และไปหน้าถัดไป
  // =======================
  void validateAndSave() {
    bool hasError = false; // flag ตรวจสอบ error

    setState(() {
      visitDaysError = _visitDaysController.text.isEmpty; // ถ้าไม่กรอกวัน -> error
      scoreXError = _scoreXController.text.isEmpty; // ถ้าไม่กรอกคะแนน X -> error

      cumulativeError = List.filled(_selectedItemCount, false); // รีเซ็ต error dropdown
      bonusError = List.filled(_selectedItemCount, false);

      // ตรวจสอบแต่ละ dropdown
      for (int i = 0; i < _selectedItemCount; i++) {
        if (_selectedCumulativeScores[i] == null) {
          cumulativeError[i] = true; // ถ้าไม่เลือกคะแนนสะสม -> error
          hasError = true;
        }
        if (_selectedBonusScores[i] == null) {
          bonusError[i] = true; // ถ้าไม่เลือกคะแนนโบนัส -> error
          hasError = true;
        }
      }

      if (visitDaysError || scoreXError) hasError = true; // ถ้า TextField ว่าง -> error
    });

    if (hasError) {
      // =======================
      // 🎯 แสดง snackbar แจ้งผู้ใช้
      // =======================
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return; // มี error หยุดทำงาน
    }

    // =======================
    // 🎯 สร้าง list ของ points สำหรับส่งไปหน้า 04
    // =======================
    final points = List.generate(
      _selectedItemCount,
      (i) => {
        "point_percent": parsePercent(_selectedCumulativeScores[i]), // แปลง string เป็น int
        "point_extra": int.tryParse(_selectedBonusScores[i] ?? '0') ?? 0, // แปลง string เป็น int
      },
    );

    // =======================
    // 🎯 ไปหน้าถัดไป /classroom_create04 พร้อม arguments
    // =======================
    Navigator.pushNamed(
      context,
      '/classroom_create04',
      arguments: {
        'name_subject': nameSubject,
        'room_number': roomNumber,
        'year': academicYear,
        'semester': semester,
        'start_date': startDateStr,
        'end_date': endDateStr,
        'schedules': schedules,
        "required_days": int.tryParse(_visitDaysController.text) ?? 0,
        "reward_points": int.tryParse(_scoreXController.text) ?? 0,
        "points": points,
      },
    );
  }

  // =======================
  // 🎯 ฟังก์ชันสร้าง TextField พร้อมตรวจสอบ error
  // =======================
  Widget _buildTextField(String hint, TextEditingController controller, bool error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(12),
            border: error ? Border.all(color: Colors.red, width: 2) : null, // ถ้ามี error -> border แดง
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint, // แสดง hint
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (error) // ถ้ามี error แสดงข้อความ
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              'กรุณากรอกข้อมูลให้ครบถ้วน',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  // =======================
  // 🎯 ฟังก์ชันสร้าง Dropdown พร้อมตรวจสอบ error
  // =======================
  Widget _buildDropdownField({
    required String hint,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool error = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(12),
            border: error ? Border.all(color: Colors.red, width: 2) : null, // ถ้ามี error -> border แดง
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: selectedValue, // ค่า default
            onChanged: onChanged, // เมื่อเลือกค่า
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            isExpanded: true,
            items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          ),
        ),
        if (error) // ถ้ามี error แสดงข้อความ
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              'กรุณาเลือกข้อมูล',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  // =======================
  // 🎯 แปลง string % เป็น int
  // =======================
  int parsePercent(String? s) {
    if (s == null) return 0; // ถ้า null -> 0
    final match = RegExp(r'\d+').firstMatch(s); // ดึงตัวเลข
    return match != null ? int.parse(match.group(0)!) : 0; // แปลงเป็น int
  }

  // =======================
  // 🎯 สร้าง header พร้อมปุ่มคู่มือ
  // =======================
  Widget buildHeader(String title) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87, size: 28),
            onPressed: () {
              showDialog(context: context, builder: (context) => const GuideDialog()); // แสดงคู่มือ
            },
            tooltip: "คู่มือการใช้งาน",
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; 
    // ดึงความสูงหน้าจอทั้งหมด เพื่อใช้กำหนดขนาด container แบบ responsive

    return Scaffold(
      backgroundColor: Colors.white, // กำหนดพื้นหลังของหน้าจอเป็นสีขาว
      body: SafeArea(
        // ป้องกัน UI ทับ status bar / notch / bottom bar
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 24), // เว้นระยะด้านบน 24
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, 
              // กำหนดความกว้าง container เป็น 90% ของหน้าจอ
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85), 
              // จำกัดความสูงสูงสุด 85% ของหน้าจอ
              decoration: BoxDecoration(
                color: const Color(0xFF91C8E4), // พื้นหลัง container สีฟ้าอ่อน
                borderRadius: BorderRadius.circular(16), // มุมโค้ง 16
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // เงาโปร่งใส 10%
                    blurRadius: 5, // ความเบลอเงา
                    spreadRadius: 1, // ขนาดการกระจายเงา
                    offset: const Offset(0, 3), // เงาลากลงด้านล่าง
                  ),
                ],
              ),
              child: Column(
                // จัด children เป็นแนวตั้ง
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: buildHeader('สร้างห้องเรียน'), 
                    // แสดง header + ปุ่มคู่มือ
                  ),
                  const Divider(height: 24, thickness: 1, color: Colors.grey), 
                  // เส้นแบ่ง section

                  // 👉 เพิ่มหัวข้อ "เกณฑ์การให้คะแนน"
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8), 
                    child: Text(
                      'เกณฑ์การให้คะแนน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20), 
                      // padding รอบด้านภายใน scrollview
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        // จัด children ชิดซ้าย
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('มาเรียนติดกัน : x วัน',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8), // เว้นระยะด้านล่าง
                                    _buildTextField('กรุณากรอกข้อมูล', _visitDaysController, visitDaysError),
                                    // TextField สำหรับจำนวนวันมาเรียนติดกัน พร้อม error highlight
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12), // ช่องว่างระหว่าง 2 column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ได้ x คะแนนสะสม',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    _buildTextField('กรุณากรอกข้อมูล', _scoreXController, scoreXError),
                                    // TextField สำหรับคะแนนสะสม พร้อม error highlight
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // เว้นระยะระหว่าง section

                          const Text('จำนวนรายการที่ใช้คำนวณคะแนนพิเศษท้ายเทอม',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),

                          _buildDropdownField(
                            hint: 'เลือกจำนวนรายการ',
                            options: _itemCountOptions, // dropdown สำหรับจำนวนรายการ
                            selectedValue: _selectedItemCount.toString(), // ค่า default
                            onChanged: (newValue) {
                              setState(() {
                                _selectedItemCount = int.parse(newValue!); // อัปเดตจำนวนรายการ
                                _selectedCumulativeScores = List.filled(_selectedItemCount, null); 
                                _selectedBonusScores = List.filled(_selectedItemCount, null); 
                                cumulativeError = List.filled(_selectedItemCount, false); 
                                bonusError = List.filled(_selectedItemCount, false); 
                                // รีเซ็ตค่า dropdown และ error ของแต่ละ item
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // =======================
                          // 🎯 Loop สำหรับแต่ละ item เกณฑ์คะแนนพิเศษ
                          // =======================
                          for (int i = 0; i < _selectedItemCount; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16), // เว้นระยะด้านล่าง
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('คะแนนสะสม(ร้อยละ)',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 8),
                                        _buildDropdownField(
                                          hint: 'คะแนนสะสม',
                                          options: _cumulativeScoreOptions, 
                                          selectedValue: _selectedCumulativeScores[i],
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedCumulativeScores[i] = newValue; 
                                              cumulativeError[i] = false; // clear error เมื่อเลือกแล้ว
                                            });
                                          },
                                          error: cumulativeError[i], // highlight error
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12), // ช่องว่างระหว่าง 2 column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('ได้คะแนนพิเศษท้ายเทอม',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 8),
                                        _buildDropdownField(
                                          hint: 'คะแนนพิเศษ',
                                          options: _bonusScoreOptions, 
                                          selectedValue: _selectedBonusScores[i],
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedBonusScores[i] = newValue;
                                              bonusError[i] = false; // clear error
                                            });
                                          },
                                          error: bonusError[i], // highlight error
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
                  ),

                  // =======================
                  // 🎯 ปุ่มยกเลิก / ถัดไป
                  // =======================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // ปุ่มยกเลิกสีแดง
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/classroom_create01', (r) => false),
                            // กลับไปหน้าแรก และ clear navigation stack
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('ยกเลิก', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFEAA7), // ปุ่มถัดไปสีเหลืองอ่อน
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: validateAndSave, // validate ข้อมูลและไปหน้าถัดไป
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('ถัดไป', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context), 
      // navbar ด้านล่างของ app พร้อมกำหนด currentIndex
    );
  }
}