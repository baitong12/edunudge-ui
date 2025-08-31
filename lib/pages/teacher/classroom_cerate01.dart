import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateClassroom01 extends StatefulWidget {
  const CreateClassroom01({super.key});

  @override
  State<CreateClassroom01> createState() => _CreateClassroom01State();
}

class _CreateClassroom01State extends State<CreateClassroom01> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomNumberController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedSemester;
  final List<String> semesters = [
    'ภาคเรียนที่ 1',
    'ภาคเรียนที่ 2',
    'ภาคเรียนฤดูร้อน'
  ];

  bool subjectError = false;
  bool roomError = false;
  bool startDateError = false;
  bool endDateError = false;
  bool semesterError = false;

  @override
  void dispose() {
    subjectController.dispose();
    roomNumberController.dispose();
    academicYearController.dispose();
    super.dispose();
  }

  String mapSemesterToBackend(String? semester) {
    switch (semester) {
      case 'ภาคเรียนที่ 1':
        return '1';
      case 'ภาคเรียนที่ 2':
        return '2';
      case 'ภาคเรียนฤดูร้อน':
        return 'Summer';
      default:
        return '1';
    }
  }

  void _validateAndNavigate() {
    setState(() {
      subjectError = subjectController.text.isEmpty;
      roomError = roomNumberController.text.isEmpty;
      startDateError = selectedStartDate == null;
      endDateError = selectedEndDate == null;
      semesterError = selectedSemester == null;
    });

    if (!subjectError &&
        !roomError &&
        !startDateError &&
        !endDateError &&
        !semesterError) {
      if (selectedStartDate != null &&
          selectedEndDate != null &&
          selectedEndDate!.isBefore(selectedStartDate!)) {
        _showInvalidDateAlert();
        setState(() {
          endDateError = true;
        });
      } else {
        // แปลงปี พ.ศ. → ค.ศ.
        int year = int.tryParse(academicYearController.text) ?? DateTime.now().year;
        if (year > 2100) {
          year -= 543; // พ.ศ. → ค.ศ.
        }

        Navigator.pushReplacementNamed(
          context,
          '/classroom_create02',
          arguments: {
            'name_subject': subjectController.text,
            'room_number': roomNumberController.text,
            'year': year.toString(), // ส่งเป็น ค.ศ.
            'semester': mapSemesterToBackend(selectedSemester),
            'start_date': selectedStartDate,
            'end_date': selectedEndDate,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                      const Text(
                        'สร้างห้องเรียน',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const Divider(height: 24, thickness: 1, color: Colors.grey),
                      buildLabeledField(
                          'ชื่อวิชา', subjectController, 'กรุณากรอกชื่อวิชา',
                          error: subjectError),
                      const SizedBox(height: 16),
                      buildLabeledField(
                          'ห้องเรียน', roomNumberController, 'กรุณากรอกเลขห้อง',
                          error: roomError),
                      const SizedBox(height: 16),
                      const Text(
                        'ภาคการศึกษา',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      _buildSemesterDropdownField(error: semesterError),
                      const SizedBox(height: 16),
                      buildLabeledField('ปีการศึกษา', academicYearController,
                          'กรุณากรอกปีการศึกษา',
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      const Text('วันแรกของเทอม',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                      const SizedBox(height: 8),
                      _buildDatePickerButton(
                          'เลือกวันแรกของเทอม', selectedStartDate, true,
                          error: startDateError),
                      const SizedBox(height: 16),
                      const Text('วันสุดท้ายของเทอม',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                      const SizedBox(height: 8),
                      _buildDatePickerButton(
                          'เลือกวันสุดท้ายของเทอม', selectedEndDate, false,
                          error: endDateError),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pushReplacementNamed(context, '/home_teacher'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'ยกเลิก',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
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
                              onPressed: _validateAndNavigate,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'ถัดไป',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
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
          bottomNavigationBar:
              CustomBottomNav(currentIndex: 1, context: context),
        ),
      ),
    );
  }

  Widget buildLabeledField(
      String label, TextEditingController controller, String hintText,
      {bool error = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: error ? Colors.red : Colors.transparent, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: error ? Colors.red : Colors.transparent, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorText: error ? 'กรุณากรอกข้อมูล' : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterDropdownField({bool error = false}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: 'กรุณาเลือกภาคการศึกษา',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: error ? Colors.red : Colors.transparent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: error ? Colors.red : Colors.transparent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorText: error ? 'กรุณาเลือกภาคการศึกษา' : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      value: selectedSemester,
      items: semesters.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child:
              Text(item, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedSemester = newValue;
          semesterError = false;
          // *** ลบโค้ด auto update selectedEndDate ออก ***
        });
      },
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 28),
    );
  }

  Widget _buildDatePickerButton(
      String hintText, DateTime? selectedDate, bool isStartDate,
      {bool error = false}) {
    return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: selectedDate == null ? Colors.grey[400] : Colors.black,
                size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate == null
                    ? hintText
                    : 'วันที่ ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: TextStyle(
                  color:
                      selectedDate == null ? Colors.grey[400] : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? temp = isStartDate ? selectedStartDate : selectedEndDate;
    DateTime focusedDay = temp ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(builder: (context, setStateDialog) {
            return Container(
              width: 300,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  isStartDate ? 'เลือกวันแรกของเทอม' : 'เลือกวันสุดท้ายของเทอม',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    locale: 'th_TH',
                    focusedDay: focusedDay,
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2035),
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month'
                    },
                    rowHeight: 36,
                    selectedDayPredicate: (day) =>
                        temp != null && isSameDay(temp, day),
                    onDaySelected: (day, _) {
                      setStateDialog(() {
                        temp = isSameDay(temp, day) ? null : day;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      weekendTextStyle:
                          const TextStyle(color: Colors.redAccent),
                      defaultTextStyle: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.black, size: 28),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.black, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('ยกเลิก',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (isStartDate) {
                            // เพิ่มเงื่อนไขนี้
                            if (temp != null && selectedEndDate != null && temp!.isAfter(selectedEndDate!)) {
                              _showInvalidStartDateAlert();
                            } else {
                              selectedStartDate = temp;
                              startDateError = false;
                            }
                          } else {
                            if (temp != null &&
                                selectedStartDate != null &&
                                temp!.isAfter(selectedStartDate!)) {
                              selectedEndDate = temp;
                              endDateError = false;
                            } else if (temp != null && selectedStartDate == null) {
                              selectedEndDate = temp;
                              endDateError = false;
                            } else {
                              _showInvalidDateAlert();
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('ตกลง',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ])
              ]),
            );
          }),
        );
      },
    );
  }

  void _showInvalidDateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('วันไม่ถูกต้อง'),
        content: const Text('วันสุดท้ายของเทอมต้องไม่อยู่ก่อนวันแรกของเทอม'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  void _showInvalidStartDateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('วันไม่ถูกต้อง'),
        content: const Text('วันแรกของเทอมต้องไม่มากกว่าวันสุดท้ายของเทอม'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }
}