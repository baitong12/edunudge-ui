import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:edunudge/pages/teacher/manual.dart';

class CreateClassroom02 extends StatefulWidget { // สร้าง StatefulWidget สำหรับหน้ากำหนดวันและเวลาเรียน
  const CreateClassroom02({super.key}); // constructor ของ widget

  @override
  State<CreateClassroom02> createState() => _CreateClassroom02State(); // เชื่อม State ของ widget
}

// =======================
// 🎯 ฟังก์ชันตรวจสอบเวลา: วันสิ้นสุดต้องไม่ก่อนเวลาเริ่ม
// =======================
bool isEndTimeBeforeStartTime(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute; // แปลงเวลาเริ่มเป็นนาทีรวม
  final endMinutes = end.hour * 60 + end.minute; // แปลงเวลาสิ้นสุดเป็นนาทีรวม
  return endMinutes <= startMinutes; // true = เวลาสิ้นสุด <= เวลาเริ่ม
}

class _CreateClassroom02State extends State<CreateClassroom02> {
  final Color primaryColor = const Color(0xFF3F8FAF); // กำหนดสีหลักของ UI

  // =======================
  // 🎯 ตัวแปรสำหรับการเลือกวันเรียนและเวลา
  // =======================
  int? selectedDays; // จำนวนวันที่เรียนต่อสัปดาห์ (1-3 วัน)
  List<String> weekDays = [ // รายชื่อวันในสัปดาห์
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'
  ];
  List<String?> selectedWeekDays = List.filled(3, null); // วันที่เลือกสำหรับแต่ละ session
  List<TimeOfDay?> startTimes = List.filled(3, null); // เวลาเริ่มเรียนของแต่ละ session
  List<TimeOfDay?> endTimes = List.filled(3, null); // เวลาสิ้นสุดเรียนของแต่ละ session

  // =======================
  // 🎯 ตัวแปรตรวจสอบความถูกต้อง (Validation)
  // =======================
  bool daysError = false; // true = ไม่เลือกจำนวนวัน
  List<bool> weekDayError = [false, false, false]; // true = เลือกวันซ้ำหรือไม่ถูกต้อง
  List<bool> startTimeError = [false, false, false]; // true = เวลาเริ่มผิด
  List<bool> endTimeError = [false, false, false]; // true = เวลาสิ้นสุดผิด

  // =======================
  // 🎯 ตัวแปรรับค่าจากหน้าก่อนหน้า (CreateClassroom01)
  // =======================
  late String nameSubject; // ชื่อวิชา
  late String roomNumber; // เลขห้องเรียน
  late String academicYear; // ปีการศึกษา
  late String semester; // ภาคเรียน
  late DateTime startDate; // วันเริ่มต้นของเทอม
  late DateTime endDate; // วันสิ้นสุดของเทอม

  // =======================
  // 🎯 รับค่าจาก ModalRoute (arguments จากหน้าก่อน)
  // =======================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map; // รับ argument
    nameSubject = args['name_subject']; // กำหนดค่าชื่อวิชา
    roomNumber = args['room_number']; // กำหนดค่าเลขห้อง
    academicYear = args['year']; // กำหนดค่าปีการศึกษา
    semester = args['semester']; // กำหนดค่าภาคเรียน
    startDate = args['start_date']; // กำหนดค่าวันเริ่มต้นเทอม
    endDate = args['end_date']; // กำหนดค่าวันสิ้นสุดเทอม
  }

  // =======================
  // 🎯 ฟังก์ชัน build UI หลัก
  // =======================
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // เอาสูงของหน้าจอ

    return Scaffold(
      body: Container(
        color: Colors.white, // พื้นหลังสีขาว
        child: SafeArea( // ป้องกัน UI ซ้อนกับ notch/status bar
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20), // padding บน-ล่าง
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // กว้าง 90% ของหน้าจอ
                height: screenHeight * 0.85, // สูง 85% ของหน้าจอ
                padding: const EdgeInsets.all(20), // padding ขอบด้านใน
                decoration: BoxDecoration(
                  color: const Color(0xFF91C8E4), // สีพื้นหลัง container
                  borderRadius: BorderRadius.circular(16), // มุมโค้ง
                  boxShadow: [ // เงาเล็กๆ
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // ขยายเต็มแนวนอน
                  children: [
                    // =======================
                    // 🎯 ส่วน header
                    // =======================
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight, // ปุ่ม help อยู่ขวา
                          child: IconButton(
                            icon: const Icon(Icons.help_outline,
                                color: Colors.black87, size: 26),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const GuideDialog(), // แสดง Dialog คู่มือ
                              );
                            },
                            tooltip: "คู่มือการใช้งาน",
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center, // ชื่อ header อยู่กลาง
                          child: Text(
                            'สร้างห้องเรียน',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1, color: Colors.grey), // divider

                    // =======================
                    // 🎯 ส่วน form ข้อมูล
                    // =======================
                    Expanded(
                      child: SingleChildScrollView( // scroll ได้ถ้าสูงเกิน container
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('จำนวนวันที่เรียนต่อสัปดาห์', // label จำนวนวัน
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: daysError // ถ้ามี error ใส่ border สีแดง
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(8))
                                  : null,
                              child: Wrap(
                                spacing: 12, // เว้นระยะแต่ละ option
                                children: [1, 2, 3].map((value) {
                                  return SizedBox(
                                    width: 100, // กว้างแต่ละ Radio
                                    child: RadioListTile<int>(
                                      value: value, // ค่าแต่ละ Radio
                                      groupValue: selectedDays, // group ค่าเดียวกัน
                                      activeColor: primaryColor, // สีเมื่อเลือก
                                      onChanged: (val) => setState(() {
                                        selectedDays = val; // กำหนดจำนวนวัน
                                        selectedWeekDays =
                                            List.filled(3, null); // reset วันที่เลือก
                                        startTimes = List.filled(3, null); // reset เวลาเริ่ม
                                        endTimes = List.filled(3, null); // reset เวลา สิ้นสุด
                                        daysError = false; // clear error
                                      }),
                                      title: Text('$value วัน'), // แสดงข้อความ
                                      dense: true, // compact layout
                                      contentPadding: EdgeInsets.zero, // ไม่มี padding
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (daysError) // ถ้า error
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, left: 8),
                                child: Text('กรุณาเลือกจำนวนวัน', // ข้อความแจ้งเตือน
                                    style: TextStyle(
                                        color: Colors.red[700], fontSize: 12)),
                              ),
                            const SizedBox(height: 16),

                            // =======================
                            // 🎯 แสดงฟิลด์วันและเวลาเรียนแต่ละ session
                            // =======================
                            if (selectedDays != null) // ถ้ามีการเลือกจำนวนวัน
                              for (int i = 0; i < selectedDays!; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('วันที่ ${i + 1}', // label session
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text('วันที่เรียน: '),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            decoration: weekDayError[i] // error border
                                                ? BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8))
                                                : null,
                                            child: DropdownButton<String>( // dropdown เลือกวัน
                                              isExpanded: true, // กว้างเต็ม container
                                              hint: const Text('เลือกวัน'),
                                              value: selectedWeekDays[i], // ค่าวันที่เลือก
                                              items: weekDays.map((day) {
                                                return DropdownMenuItem(
                                                  value: day,
                                                  child: Text(day,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                // ตรวจสอบวันซ้ำ
                                                if (selectedWeekDays
                                                    .sublist(
                                                        0, selectedDays!)
                                                    .contains(value)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'ไม่สามารถเลือกวันซ้ำกันได้'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    selectedWeekDays[i] =
                                                        value; // กำหนดวัน
                                                    weekDayError[i] = false; // clear error
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    buildTimePickerButton(
                                        index: i,
                                        isStart: true,
                                        error: startTimeError[i]), // เวลาเริ่มเรียน
                                    const SizedBox(height: 12),
                                    buildTimePickerButton(
                                        index: i,
                                        isStart: false,
                                        error: endTimeError[i]), // เวลาสิ้นสุดเรียน
                                    const SizedBox(height: 24),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ),

                    // =======================
                    // 🎯 ส่วนปุ่ม action: ยกเลิก / ถัดไป
                    // =======================
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            onPressed: () => Navigator.popAndPushNamed(
                                context, '/classroom_create01'), // กลับหน้าก่อนหน้า
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('ยกเลิก',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12), // เว้นระยะปุ่ม
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFEAA7),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              shadowColor: Colors.black.withOpacity(0.5),
                            ),
                            onPressed: validateAndSave, // ตรวจสอบข้อมูลและไปหน้าถัดไป
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('ถัดไป',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
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
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context), // navigation bar
    );
  }

void validateAndSave() { // ฟังก์ชันตรวจสอบความถูกต้องของการเลือกวันและเวลา และไปหน้าถัดไป
  bool hasError = false; // ตัวแปร flag สำหรับตรวจสอบว่ามี error หรือไม่

  // =======================
  // 🎯 ตรวจสอบว่าผู้ใช้เลือกจำนวนวันที่เรียนต่อสัปดาห์หรือไม่
  // =======================
  if (selectedDays == null) {
    setState(() {
      daysError = true; // ถ้าไม่เลือก ให้แสดง error
    });
    hasError = true; // mark มี error
  }

  // =======================
  // 🎯 ตรวจสอบแต่ละ session ของวันเรียน
  // =======================
  for (int i = 0; i < (selectedDays ?? 0); i++) {
    // ตรวจสอบว่ามีการเลือกวันเรียนหรือไม่
    if (selectedWeekDays[i] == null) {
      setState(() {
        weekDayError[i] = true; // ถ้าไม่เลือกวัน ให้แสดง error
      });
      hasError = true;
    }
    // ตรวจสอบว่ามีการเลือกเวลาเริ่มเรียนหรือไม่
    if (startTimes[i] == null) {
      setState(() {
        startTimeError[i] = true; // ถ้าไม่เลือกเวลาเริ่ม ให้แสดง error
      });
      hasError = true;
    }
    // ตรวจสอบว่ามีการเลือกเวลาสิ้นสุดหรือไม่
    if (endTimes[i] == null) {
      setState(() {
        endTimeError[i] = true; // ถ้าไม่เลือกเวลาสิ้นสุด ให้แสดง error
      });
      hasError = true;
    }

    // =======================
    // 🎯 ตรวจสอบว่าเวลาสิ้นสุดหลังเวลาเริ่มหรือไม่
    // =======================
    if (startTimes[i] != null && endTimes[i] != null) {
      if (isEndTimeBeforeStartTime(startTimes[i]!, endTimes[i]!)) {
        hasError = true; // mark error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('เวลาจบคาบเรียนต้องมากกว่าเวลาเริ่มคาบเรียน'), // แจ้ง error
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // =======================
  // 🎯 ถ้าไม่มี error ให้สร้าง schedule list และไปหน้าถัดไป
  // =======================
  if (!hasError) {
    List<Map<String, dynamic>> schedules = []; // เก็บข้อมูลตารางเรียน

    for (int i = 0; i < selectedDays!; i++) {
      final day = selectedWeekDays[i]!; // วันเรียน
      final start = startTimes[i]!; // เวลาเริ่ม
      final end = endTimes[i]!; // เวลาสิ้นสุด

      // เพิ่ม schedule ลงใน list
      schedules.add({
        "day_of_week": capitalizeFirstLetter(thaiToEnglishDay(day)), // แปลงชื่อวันไทย -> อังกฤษ + capitalize
        "time_start":
            "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}", // แปลงเวลาเริ่มเป็น HH:mm
        "time_end":
            "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}", // แปลงเวลาสิ้นสุดเป็น HH:mm
      });
    }

    // แปลงวันเริ่มต้น-สิ้นสุดเทอมเป็น string แบบ YYYY-MM-DD
    String startDateStr =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String endDateStr =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    // =======================
    // 🎯 ไปหน้าถัดไป (/classroom_create03) พร้อม arguments
    // =======================
    Navigator.pushNamed(
      context,
      '/classroom_create03',
      arguments: {
        'name_subject': nameSubject,
        'room_number': roomNumber,
        'year': academicYear,
        'semester': semester,
        'start_date': startDateStr,
        'end_date': endDateStr,
        'schedules': schedules,
      },
    );
  } else {
    // =======================
    // 🎯 ถ้ามี error แจ้งผู้ใช้
    // =======================
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // ให้ pop-up ลอย
      ),
    );
  }
}

// =======================
// 🎯 ฟังก์ชันแปลงวันภาษาไทยเป็นอังกฤษ
// =======================
String thaiToEnglishDay(String day) {
  switch (day) {
    case 'จันทร์':
      return 'Monday';
    case 'อังคาร':
      return 'Tuesday';
    case 'พุธ':
      return 'Wednesday';
    case 'พฤหัสบดี':
      return 'Thursday';
    case 'ศุกร์':
      return 'Friday';
    case 'เสาร์':
      return 'Saturday';
    case 'อาทิตย์':
      return 'Sunday';
    default:
      return ''; // ถ้าไม่เจอชื่อวัน
  }
}

// =======================
// 🎯 ฟังก์ชันเลือกเวลา (TimeOfDay) ผ่าน dialog
// =======================
Future<void> pickTime(int index, bool isStart) async {
  final initial = isStart ? startTimes[index] : endTimes[index]; // เวลาเริ่มต้นของ picker
  TimeOfDay? pickedTime =
      await customTimePickerDialog(context, initialTime: initial); // เรียก dialog
  if (pickedTime != null) { // ถ้าเลือกเวลา
    setState(() {
      if (isStart) {
        startTimes[index] = pickedTime; // กำหนดเวลาเริ่ม
        startTimeError[index] = false; // clear error
      } else {
        endTimes[index] = pickedTime; // กำหนดเวลาสิ้นสุด
        endTimeError[index] = false; // clear error
      }
    });
  }
}

// =======================
// 🎯 สร้างปุ่มเลือกเวลา
// =======================
Widget buildTimePickerButton(
    {required int index, required bool isStart, bool error = false}) {
  return Row(
    children: [
      Text(isStart ? 'เวลาเริ่ม: ' : 'เวลาจบ: '), // แสดง label
      const SizedBox(width: 12),
      Expanded(
        child: Container(
          decoration: error // ถ้ามี error ใส่ border สีแดง
              ? BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8))
              : null,
          child: ElevatedButton(
            onPressed: () => pickTime(index, isStart), // กดเลือกเวลา
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
                formatTimeOfDay(isStart ? startTimes[index] : endTimes[index]), // แสดงเวลา
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    ],
  );
}

// =======================
// 🎯 แปลง TimeOfDay เป็น string HH:mm
// =======================
String formatTimeOfDay(TimeOfDay? time) {
  if (time == null) return 'เลือกเวลา'; // ถ้ายังไม่เลือก
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

// =======================
// 🎯 custom dialog สำหรับเลือกเวลาแบบ ListWheelScrollView
// =======================
Future<TimeOfDay?> customTimePickerDialog(BuildContext context,
    {TimeOfDay? initialTime}) async {
  int selectedHour = initialTime?.hour ?? TimeOfDay.now().hour; // ชั่วโมงเริ่มต้น
  int selectedMinute = initialTime?.minute ?? TimeOfDay.now().minute; // นาทีเริ่มต้น

  return await showDialog<TimeOfDay>(
    context: context,
    builder: (context) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // มุมโค้ง
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setStateDialog) { // ใช้ setState ภายใน dialog
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('เลือกเวลา',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F8FAF))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // =======================
                      // 🎯 เลือกชั่วโมง
                      // =======================
                      SizedBox(
                        height: 150,
                        width: 80,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 40,
                          perspective: 0.003,
                          physics: const FixedExtentScrollPhysics(),
                          controller:
                              FixedExtentScrollController(initialItem: selectedHour),
                          onSelectedItemChanged: (v) =>
                              setStateDialog(() => selectedHour = v % 24), // update ชั่วโมง
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(
                                24,
                                (idx) => Center(
                                        child: Text(idx.toString().padLeft(2, '0'),
                                            style: const TextStyle(fontSize: 20))))),
                          ),
                      ),
                      const Text(':', style: TextStyle(fontSize: 24)),
                      // =======================
                      // 🎯 เลือกนาที
                      // =======================
                      SizedBox(
                        height: 150,
                        width: 80,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 40,
                          perspective: 0.003,
                          physics: const FixedExtentScrollPhysics(),
                          controller:
                              FixedExtentScrollController(initialItem: selectedMinute),
                          onSelectedItemChanged: (v) =>
                              setStateDialog(() => selectedMinute = v % 60), // update นาที
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(
                                60,
                                (idx) => Center(
                                        child: Text(idx.toString().padLeft(2, '0'),
                                            style: const TextStyle(fontSize: 20))))),
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // =======================
                      // 🎯 ปุ่มยกเลิก
                      // =======================
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context), // ปิด dialog
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('ยกเลิก',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // =======================
                      // 🎯 ปุ่มตกลง
                      // =======================
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(
                              context, TimeOfDay(hour: selectedHour, minute: selectedMinute)), // return เวลาเลือก
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F8FAF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('ตกลง',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

  // =======================
  // 🎯 capitalize ตัวอักษรแรกของ string
  // =======================
  String capitalizeFirstLetter(String s) {
    if (s.isEmpty) return s; // ถ้า string ว่าง return ว่าง
    return s[0].toUpperCase() + s.substring(1).toLowerCase(); // แปลงตัวแรกเป็นตัวใหญ่ ตัวอื่นตัวเล็ก
  }
}