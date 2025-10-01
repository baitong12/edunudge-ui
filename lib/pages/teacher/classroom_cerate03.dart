import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:edunudge/pages/teacher/manual.dart';

class CreateClassroom03 extends StatefulWidget {
  const CreateClassroom03({super.key});

  @override
  State<CreateClassroom03> createState() => _CreateClassroom03State();
}

class _CreateClassroom03State extends State<CreateClassroom03> {
  final Color primaryColor = const Color(0xFFFFEAA7);

  int _selectedItemCount = 1;
  final List<String> _itemCountOptions = ['1', '2', '3', '4', '5'];

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

  final List<String> _bonusScoreOptions = List.generate(10, (index) => (index + 1).toString());

  List<String?> _selectedCumulativeScores = List.filled(1, null);
  List<String?> _selectedBonusScores = List.filled(1, null);

  final TextEditingController _visitDaysController = TextEditingController();
  final TextEditingController _scoreXController = TextEditingController();

  bool visitDaysError = false;
  bool scoreXError = false;
  List<bool> cumulativeError = List.filled(1, false);
  List<bool> bonusError = List.filled(1, false);

  late String nameSubject;
  late String roomNumber;
  late String academicYear;
  late String semester;
  late String startDateStr;
  late String endDateStr;
  late List<dynamic> schedules;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    nameSubject = args['name_subject'];
    roomNumber = args['room_number'];
    academicYear = args['year'];
    semester = args['semester'];
    startDateStr = args['start_date'];
    endDateStr = args['end_date'];
    schedules = args['schedules'];
  }

  @override
  void dispose() {
    _visitDaysController.dispose();
    _scoreXController.dispose();
    super.dispose();
  }

  void validateAndSave() {
    bool hasError = false;

    setState(() {
      visitDaysError = _visitDaysController.text.isEmpty;
      scoreXError = _scoreXController.text.isEmpty;

      cumulativeError = List.filled(_selectedItemCount, false);
      bonusError = List.filled(_selectedItemCount, false);

      for (int i = 0; i < _selectedItemCount; i++) {
        if (_selectedCumulativeScores[i] == null) {
          cumulativeError[i] = true;
          hasError = true;
        }
        if (_selectedBonusScores[i] == null) {
          bonusError[i] = true;
          hasError = true;
        }
      }

      if (visitDaysError || scoreXError) hasError = true;
    });

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final points = List.generate(
      _selectedItemCount,
      (i) => {
        "point_percent": parsePercent(_selectedCumulativeScores[i]),
        "point_extra": int.tryParse(_selectedBonusScores[i] ?? '0') ?? 0,
      },
    );

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

  Widget _buildTextField(String hint, TextEditingController controller, bool error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(12),
            border: error ? Border.all(color: Colors.red, width: 2) : null,
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (error)
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
            border: error ? Border.all(color: Colors.red, width: 2) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            isExpanded: true,
            items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          ),
        ),
        if (error)
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

  int parsePercent(String? s) {
    if (s == null) return 0;
    final match = RegExp(r'\d+').firstMatch(s);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  Widget buildHeader(String title) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87, size: 28),
            onPressed: () {
              showDialog(context: context, builder: (context) => const GuideDialog());
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: buildHeader('สร้างห้องเรียน'),
                  ),
                  const Divider(height: 24, thickness: 1, color: Colors.grey),

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('มาเรียนติดกัน : x วัน',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    _buildTextField('กรุณากรอกข้อมูล', _visitDaysController, visitDaysError),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ได้ x คะแนนสะสม',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    _buildTextField('กรุณากรอกข้อมูล', _scoreXController, scoreXError),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('จำนวนรายการที่ใช้คำนวณคะแนนพิเศษท้ายเทอม',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            hint: 'เลือกจำนวนรายการ',
                            options: _itemCountOptions,
                            selectedValue: _selectedItemCount.toString(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedItemCount = int.parse(newValue!);
                                _selectedCumulativeScores = List.filled(_selectedItemCount, null);
                                _selectedBonusScores = List.filled(_selectedItemCount, null);
                                cumulativeError = List.filled(_selectedItemCount, false);
                                bonusError = List.filled(_selectedItemCount, false);
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          for (int i = 0; i < _selectedItemCount; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
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
                                              cumulativeError[i] = false;
                                            });
                                          },
                                          error: cumulativeError[i],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                              bonusError[i] = false;
                                            });
                                          },
                                          error: bonusError[i],
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/classroom_create01', (r) => false),
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
                              backgroundColor: Color(0xFFFFEAA7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: validateAndSave,
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
    );
  }
}
