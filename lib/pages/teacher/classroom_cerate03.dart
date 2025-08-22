import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';

class CreateClassroom03 extends StatefulWidget {
  const CreateClassroom03({super.key});

  @override
  State<CreateClassroom03> createState() => _CreateClassroom03State();
}

class _CreateClassroom03State extends State<CreateClassroom03> {
  final Color primaryColor = const Color(0xFF3F8FAF);

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

  final List<String> _bonusScoreOptions =
      List.generate(10, (index) => (index + 1).toString());

  List<String?> _selectedCumulativeScores = List.filled(1, null);
  List<String?> _selectedBonusScores = List.filled(1, null);

  final TextEditingController _visitDaysController = TextEditingController();
  final TextEditingController _scoreXController = TextEditingController();

  void validateAndSave() {
    Navigator.pushNamed(context, '/classroom_create04');
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
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
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _visitDaysController.dispose();
    _scoreXController.dispose();
    super.dispose();
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
          onLogoutTap: () => Navigator.pushNamedAndRemoveUntil(
              context, '/login', (r) => false),
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
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const Divider(
                          height: 24, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('เกณฑ์คะแนน',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'มาเรียนกัน : x วัน',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                    'กรุณากรอกข้อมูล', _visitDaysController),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ได้ x คะแนน',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                    'กรุณากรอกข้อมูล', _scoreXController),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'จำนวนรายการที่ใช้คำนวณคะแนน',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        hint: 'เลือกจำนวนรายการ',
                        options: _itemCountOptions,
                        selectedValue: _selectedItemCount.toString(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedItemCount = int.parse(newValue!);
                            _selectedCumulativeScores =
                                List.filled(_selectedItemCount, null);
                            _selectedBonusScores =
                                List.filled(_selectedItemCount, null);
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
                                    const Text(
                                      'คะแนนสะสม',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDropdownField(
                                      hint: 'คะเเนนสะสม',
                                      options: _cumulativeScoreOptions,
                                      selectedValue:
                                          _selectedCumulativeScores[i],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCumulativeScores[i] =
                                              newValue;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ได้คะแนนพิเศษ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDropdownField(
                                      hint: 'คะแนนพิเศษ',
                                      options: _bonusScoreOptions,
                                      selectedValue: _selectedBonusScores[i],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedBonusScores[i] = newValue;
                                        });
                                      },
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
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        onPressed: validateAndSave,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'ถัดไป',
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
