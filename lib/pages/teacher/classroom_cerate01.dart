import 'package:flutter/material.dart';
// ใช้สำหรับ UI หลักของ Flutter

import 'package:edunudge/pages/teacher/custombottomnav.dart';
// นำเข้า bottom navigation bar ที่ทำเอง

import 'package:table_calendar/table_calendar.dart';
// ใช้ widget ปฏิทิน TableCalendar

import 'package:edunudge/pages/teacher/manual.dart';
// นำเข้าคู่มือการใช้งาน (GuideDialog)

class CreateClassroom01 extends StatefulWidget {
  // สร้างหน้า StatefulWidget เพราะค่าต่าง ๆ สามารถเปลี่ยนได้ (stateful)
  const CreateClassroom01({super.key});

  @override
  State<CreateClassroom01> createState() => _CreateClassroom01State();
}

class _CreateClassroom01State extends State<CreateClassroom01> {
  // เก็บ state ของหน้า CreateClassroom01

  // controller เอาไว้ดักค่าที่กรอกใน TextField
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomNumberController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();

  // ตัวแปรสำหรับเลือกวัน
  DateTime? selectedStartDate; // วันเริ่มเทอม
  DateTime? selectedEndDate; // วันสุดท้ายของเทอม
  String? selectedSemester; // ภาคเรียนที่เลือก

  // รายการภาคเรียนให้เลือก
  final List<String> semesters = [
    'ภาคเรียนที่ 1',
    'ภาคเรียนที่ 2',
    'ภาคเรียนฤดูร้อน',
  ];

  // flag สำหรับ error (ใช้เช็คว่าผู้ใช้ยังไม่กรอก)
  bool subjectError = false;
  bool roomError = false;
  bool startDateError = false;
  bool endDateError = false;
  bool semesterError = false;

  @override
  void dispose() {
    // เคลียร์ controller ตอน widget หายไป เพื่อไม่ให้ memory รั่ว
    subjectController.dispose();
    roomNumberController.dispose();
    academicYearController.dispose();
    super.dispose();
  }

  String mapSemesterToBackend(String? semester) {
    // แปลงค่าที่ผู้ใช้เลือกให้ตรงกับ backend
    switch (semester) {
      case 'ภาคเรียนที่ 1':
        return '1';
      case 'ภาคเรียนที่ 2':
        return '2';
      case 'ภาคเรียนฤดูร้อน':
        return 'Summer';
      default:
        return '1'; // ถ้าไม่มีค่า ให้ default เป็นภาค 1
    }
  }

  void _validateAndNavigate() {
    // เซ็ตค่า error ถ้าไม่ได้กรอก
    setState(() {
      subjectError =
          subjectController.text.isEmpty || subjectController.text.length > 255;
      roomError =
          roomNumberController.text.isEmpty ||
          roomNumberController.text.length > 255;
      startDateError = selectedStartDate == null;
      endDateError = selectedEndDate == null;
      semesterError = selectedSemester == null;
    });

    // เช็คเงื่อนไขต่าง ๆ
    if (subjectError) {
      _showSnackBar('กรุณากรอกชื่อวิชา');
      return;
    }
    if (roomError) {
      _showSnackBar('กรุณากรอกเลขห้องเรียน');
      return;
    }
    if (semesterError) {
      _showSnackBar('กรุณาเลือกภาคการศึกษา');
      return;
    }
    if (academicYearController.text.isEmpty) {
      _showSnackBar('กรุณากรอกปีการศึกษา');
      return;
    }
    if (startDateError || endDateError) {
      _showSnackBar('กรุณาเลือกวันแรกและวันสุดท้ายของเทอม');
      return;
    }
    if (selectedStartDate != null &&
        selectedEndDate != null &&
        selectedEndDate!.isBefore(selectedStartDate!)) {
      _showSnackBar('วันสุดท้ายของเทอมต้องไม่อยู่ก่อนวันแรกของเทอม');
      setState(() {
        endDateError = true;
      });
      return;
    }

    // เช็คปีการศึกษา
    int year = int.tryParse(academicYearController.text) ?? 0;
    if (year > 2100) {
      year -= 543; // เผื่อผู้ใช้ใส่เป็น พ.ศ. ต้องแปลงเป็น ค.ศ.
    }
    if (year < 2000 || year > 2100) {
      _showSnackBar('ปีการศึกษาต้องอยู่ระหว่าง 2000 ถึง 2100');
      return;
    }

    // เช็คภาคเรียนให้ตรง backend
    String semesterBackend = mapSemesterToBackend(selectedSemester);
    if (!(semesterBackend == '1' ||
        semesterBackend == '2' ||
        semesterBackend.toLowerCase() == 'summer')) {
      _showSnackBar('ภาคการศึกษาต้องเป็น 1, 2 หรือ summer');
      return;
    }

    // ถ้าผ่านทุกอย่าง → ไปหน้าถัดไป พร้อมส่ง arguments
    Navigator.pushReplacementNamed(
      context,
      '/classroom_create02',
      arguments: {
        'name_subject': subjectController.text,
        'room_number': roomNumberController.text,
        'year': year.toString(),
        'semester': semesterBackend,
        'start_date': selectedStartDate,
        'end_date': selectedEndDate,
      },
    );
  }

  void _showSnackBar(String message) {
    // แสดง SnackBar ข้อความ error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // เอาความสูงของหน้าจอมาใช้คำนวณ layout
    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังหลักสีขาว
      body: SafeArea(
        // ป้องกัน UI ชนขอบบน (notch / status bar)
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ), // เว้นระยะด้านบน-ล่าง
          child: Center(
            child: Container(
              width:
                  MediaQuery.of(context).size.width *
                  0.9, // กำหนดความกว้าง = 90% ของหน้าจอ
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.85, // จำกัดความสูงไม่เกิน 85% ของจอ
              ),
              padding: const EdgeInsets.all(20), // ระยะห่างในกล่อง
              decoration: BoxDecoration(
                color: const Color(0xFF91C8E4), // พื้นหลังฟ้าอ่อน
                borderRadius: BorderRadius.circular(16), // มุมโค้งมน
                boxShadow: [
                  // ใส่เงา
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
                  Stack(
                    // ใช้ซ้อน widget 2 อันบนกัน
                    children: [
                      Align(
                        alignment: Alignment.centerRight, // วางชิดขวา
                        child: IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: Colors.black87,
                            size: 26,
                          ),
                          onPressed: () {
                            // กดแล้วเปิดคู่มือ GuideDialog
                            showDialog(
                              context: context,
                              builder: (context) => const GuideDialog(),
                            );
                          },
                          tooltip: "คู่มือการใช้งาน", // ข้อความ tooltip
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center, // ข้อความอยู่กลาง
                        child: Text(
                          'สร้างห้องเรียน', // หัวข้อใหญ่
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    //เส้นคั่น
                    height: 24,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    // ทำให้ขยายพื้นที่เหลือ
                    child: SingleChildScrollView(
                      // เลื่อนหน้าได้ถ้าข้อมูลเกิน
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabeledField(
                            'ชื่อวิชา',
                            subjectController,
                            'กรุณากรอกชื่อวิชา',
                            error: subjectError,
                          ),
                          const SizedBox(height: 16),
                          buildLabeledField(
                            'เลขห้องเรียน',
                            roomNumberController,
                            'กรุณากรอกเลขห้องเรียน',
                            error: roomError,
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'ภาคการศึกษา',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSemesterDropdownField(error: semesterError),
                          const SizedBox(height: 16),
                          buildLabeledField(
                            'ปีการศึกษา',
                            academicYearController,
                            'กรุณากรอกปีการศึกษา',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'วันแรกของเทอม',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDatePickerButton(
                            'เลือกวันแรกของเทอม',
                            selectedStartDate,
                            true,
                            error: startDateError,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'วันสุดท้ายของเทอม',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDatePickerButton(
                            'เลือกวันสุดท้ายของเทอม',
                            selectedEndDate,
                            false,
                            error: endDateError,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/home_teacher'),
                          // กดยกเลิก → กลับหน้า home_teacher
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
                            backgroundColor: Color(0xFFFFEAA7), // เหลืองอ่อน
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _validateAndNavigate, // กดแล้วตรวจสอบ → ไปหน้าถัดไป
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'ถัดไป',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
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
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
      // แสดง bottom nav (index = 1 คือหน้า "สร้างห้องเรียน")
    );
  }

   Widget buildLabeledField(
      String label, TextEditingController controller, String hintText,
      {bool error = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความไปทางซ้าย
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87)), // label เช่น "ชื่อวิชา"
        const SizedBox(height: 8),
        TextField(
          controller: controller, // ใช้ TextEditingController ที่ส่งเข้ามา
          keyboardType: keyboardType, // ประเภทคีย์บอร์ด เช่น number, text
          style: const TextStyle(fontSize: 16, color: Colors.black87), // สไตล์ข้อความ
          decoration: InputDecoration(
            hintText: hintText, // ข้อความ hint เช่น "กรุณากรอกชื่อวิชา"
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true, // พื้นหลังสี
            fillColor: Colors.grey[200],
            border: OutlineInputBorder( // เส้นกรอบ
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
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorText: error ? 'กรุณากรอกข้อมูล' : null, // ถ้ามี error แสดงข้อความนี้
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
      value: selectedSemester, // ค่า semester ที่เลือกไว้
      items: semesters.map((String item) { // แปลง List<String> → DropdownMenuItem
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedSemester = newValue; // อัพเดตค่า semester ที่เลือก
          semesterError = false; // รีเซ็ต error
        });
      },
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 28),
    );
  }

    Widget _buildDatePickerButton(
      String hintText, DateTime? selectedDate, bool isStartDate,
      {bool error = false}) {
    return InkWell(
      onTap: () => _selectDate(context, isStartDate), // กดแล้วเปิด calendar
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
                    : 'วันที่ ${selectedDate.day}/${selectedDate.month}/${selectedDate.year + 543}', 
                // ถ้าเลือกแล้ว แสดงวันที่ (ปีบวก 543 → แปลงเป็น พ.ศ.)
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
  // ฟังก์ชันเลือกวัน (ทั้งวันแรกของเทอม หรือวันสุดท้ายของเทอม)
  // คืนค่าเป็น Future<void> เพราะใช้ async/await

  DateTime? temp = isStartDate ? selectedStartDate : selectedEndDate;
  // temp = ค่าวันที่เลือกไว้ชั่วคราว
  // ถ้าเป็นวันเริ่ม → ใช้ selectedStartDate, ถ้าเป็นวันจบ → ใช้ selectedEndDate

  DateTime focusedDay = temp ?? DateTime.now();
  // focusedDay = วันที่ที่ปฏิทินจะโฟกัสเริ่มต้น
  // ถ้ายังไม่เลือก ให้ใช้วันปัจจุบัน

      await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // ทำมุมโค้งมน
        ),

                  child: StatefulBuilder(
          builder: (context, setStateDialog) {
            // StatefulBuilder ทำให้สามารถ setState ได้ภายใน Dialog โดยไม่กระทบ widget หลัก
                          return Container(
              width: 300, // กว้าง 300px
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ขนาดพอดีกับเนื้อหา
                children: [
                    Text(
                      isStartDate
                          ? 'เลือกวันแรกของเทอม'
                          : 'เลือกวันสุดท้ายของเทอม',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                                      Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // พื้นหลังเทาอ่อน
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: TableCalendar(
                      locale: 'th_TH', // ใช้ locale ภาษาไทย
                      focusedDay: focusedDay, // วันที่โฟกัสปัจจุบัน
                      firstDay: DateTime.utc(2020), // วันเริ่มเลือกได้
                      lastDay: DateTime.utc(2035),  // วันสุดท้ายที่เลือกได้
                      calendarFormat: CalendarFormat.month, // แสดงแบบเดือน
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month', // บังคับให้เลือกแบบเดือนเท่านั้น
                      },
                      rowHeight: 36, // ความสูงแต่ละแถวของวัน
                                             selectedDayPredicate: (day) =>
                          temp != null && isSameDay(temp, day),
                      // เช็คว่ามีการเลือกวันหรือไม่ → ไฮไลท์วันนั้น

                      onDaySelected: (day, _) {
                        setStateDialog(() {
                          temp = isSameDay(temp, day) ? null : day;
                          // ถ้ากดวันเดิม → ยกเลิกเลือก
                          // ถ้าเลือกวันใหม่ → เก็บค่าใหม่
                          focusedDay = day;
                        });
                      },
                        onPageChanged: (newFocusedDay) {
                        setStateDialog(() {
                          focusedDay = newFocusedDay; // อัพเดตเดือนที่โฟกัส
                        });
                      },
                                              calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle, // วันนี้วงกลมสีดำโปร่ง
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                        weekendTextStyle: const TextStyle(
                          color: Colors.redAccent), // เสาร์–อาทิตย์ สีแดง
                        defaultTextStyle: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                        outsideDaysVisible: false, // วันนอกเดือนซ่อน
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false, // ไม่โชว์ปุ่มเปลี่ยน format
                        titleCentered: true, // ชื่อเดือนอยู่กลาง
                        titleTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                        leftChevronIcon: Icon(Icons.chevron_left,
                            color: Colors.black, size: 28),
                        rightChevronIcon: Icon(Icons.chevron_right,
                            color: Colors.black, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                                      Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context), // ปิด dialog
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // ปิด dialog
                            setState(() {
                              if (isStartDate) { // ถ้าเลือกวันแรกของเทอม
                                if (temp != null &&
                                    selectedEndDate != null &&
                                    temp!.isAfter(selectedEndDate!)) {
                                  _showSnackBar(
                                    'วันแรกของเทอมต้องไม่มากกว่าวันสุดท้ายของเทอม',
                                  );
                                } else {
                                  selectedStartDate = temp;
                                  startDateError = false;
                                }
                              } else { // ถ้าเลือกวันสุดท้ายของเทอม
                                if (temp != null &&
                                    selectedStartDate != null &&
                                    temp!.isBefore(selectedStartDate!)) {
                                  _showSnackBar(
                                    'วันสุดท้ายของเทอมต้องไม่อยู่ก่อนวันแรกของเทอม',
                                  );
                                } else {
                                  selectedEndDate = temp;
                                  endDateError = false;
                                }
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFEAA7), // เหลืองอ่อน
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'ตกลง',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
}