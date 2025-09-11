import 'package:flutter/material.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:edunudge/pages/teacher/manual.dart';

class CreateClassroom02 extends StatefulWidget {
  const CreateClassroom02({super.key});

  @override
  State<CreateClassroom02> createState() => _CreateClassroom02State();
}

bool isEndTimeBeforeStartTime(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return endMinutes <= startMinutes;
}

class _CreateClassroom02State extends State<CreateClassroom02> {
  final Color primaryColor = const Color(0xFF3F8FAF);

  int? selectedDays;
  List<String> weekDays = [
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์'
  ];
  List<String?> selectedWeekDays = List.filled(3, null);
  List<TimeOfDay?> startTimes = List.filled(3, null);
  List<TimeOfDay?> endTimes = List.filled(3, null);

  bool daysError = false;
  List<bool> weekDayError = [false, false, false];
  List<bool> startTimeError = [false, false, false];
  List<bool> endTimeError = [false, false, false];

  // ข้อมูลที่รับจากหน้า 01
  late String nameSubject;
  late String roomNumber;
  late String academicYear;
  late String semester;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    nameSubject = args['name_subject'];
    roomNumber = args['room_number'];
    academicYear = args['year'];
    semester = args['semester'];
    startDate = args['start_date'];
    endDate = args['end_date'];
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: screenHeight * 0.85,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header แบบ Stack (ไอคอนคู่มือซ้าย, ข้อความกลาง)
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.help_outline,
                                color: Colors.black87, size: 26),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const GuideDialog(),
                              );
                            },
                            tooltip: "คู่มือการใช้งาน",
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
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
                    const Divider(height: 24, thickness: 1, color: Colors.grey),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('จำนวนวันที่เรียนต่อสัปดาห์',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: daysError
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(8))
                                  : null,
                              child: Wrap(
                                spacing: 12,
                                children: [1, 2, 3].map((value) {
                                  return SizedBox(
                                    width: 100,
                                    child: RadioListTile<int>(
                                      value: value,
                                      groupValue: selectedDays,
                                      activeColor: primaryColor,
                                      onChanged: (val) => setState(() {
                                        selectedDays = val;
                                        selectedWeekDays =
                                            List.filled(3, null);
                                        startTimes = List.filled(3, null);
                                        endTimes = List.filled(3, null);
                                        daysError = false;
                                      }),
                                      title: Text('$value วัน'),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (daysError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, left: 8),
                                child: Text('กรุณาเลือกจำนวนวัน',
                                    style: TextStyle(
                                        color: Colors.red[700], fontSize: 12)),
                              ),
                            const SizedBox(height: 16),
                            if (selectedDays != null)
                              for (int i = 0; i < selectedDays!; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('วันที่ ${i + 1}',
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
                                            decoration: weekDayError[i]
                                                ? BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8))
                                                : null,
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              hint: const Text('เลือกวัน'),
                                              value: selectedWeekDays[i],
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
                                                        value;
                                                    weekDayError[i] = false;
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
                                        index: i, isStart: true, error: startTimeError[i]),
                                    const SizedBox(height: 12),
                                    buildTimePickerButton(
                                        index: i, isStart: false, error: endTimeError[i]),
                                    const SizedBox(height: 24),
                                  ],
                                ),
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
                              elevation: 3,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            onPressed: () => Navigator.popAndPushNamed(
                                context, '/classroom_create01'),
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
                              elevation: 3,
                              shadowColor: Colors.black.withOpacity(0.5),
                            ),
                            onPressed: validateAndSave,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('ถัดไป',
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
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, context: context),
    );
  }

  void validateAndSave() {
    bool hasError = false;

    if (selectedDays == null) {
      setState(() {
        daysError = true;
      });
      hasError = true;
    }

    for (int i = 0; i < (selectedDays ?? 0); i++) {
      if (selectedWeekDays[i] == null) {
        setState(() {
          weekDayError[i] = true;
        });
        hasError = true;
      }
      if (startTimes[i] == null) {
        setState(() {
          startTimeError[i] = true;
        });
        hasError = true;
      }
      if (endTimes[i] == null) {
        setState(() {
          endTimeError[i] = true;
        });
        hasError = true;
      }

      if (startTimes[i] != null && endTimes[i] != null) {
        if (isEndTimeBeforeStartTime(startTimes[i]!, endTimes[i]!)) {
          hasError = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เวลาจบคาบเรียนต้องมากกว่าเวลาเริ่มคาบเรียน'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    if (!hasError) {
      List<Map<String, dynamic>> schedules = [];
      for (int i = 0; i < selectedDays!; i++) {
        final day = selectedWeekDays[i]!;
        final start = startTimes[i]!;
        final end = endTimes[i]!;

        schedules.add({
          "day_of_week": capitalizeFirstLetter(thaiToEnglishDay(day)),
          "time_start":
              "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
          "time_end":
              "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
        });
      }

      String startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      String endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String thaiToEnglishDay(String day) {
    switch (day) {
      case 'จันทร์':
        return 'monday';
      case 'อังคาร':
        return 'tuesday';
      case 'พุธ':
        return 'wednesday';
      case 'พฤหัสบดี':
        return 'thursday';
      case 'ศุกร์':
        return 'friday';
      case 'เสาร์':
        return 'saturday';
      case 'อาทิตย์':
        return 'sunday';
      default:
        return '';
    }
  }

  Future<void> pickTime(int index, bool isStart) async {
    final initial = isStart ? startTimes[index] : endTimes[index];
    TimeOfDay? pickedTime =
        await customTimePickerDialog(context, initialTime: initial);
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startTimes[index] = pickedTime;
          startTimeError[index] = false;
        } else {
          endTimes[index] = pickedTime;
          endTimeError[index] = false;
        }
      });
    }
  }

  Widget buildTimePickerButton(
      {required int index, required bool isStart, bool error = false}) {
    return Row(
      children: [
        Text(isStart ? 'เวลาเริ่ม: ' : 'เวลาจบ: '),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: error
                ? BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8))
                : null,
            child: ElevatedButton(
              onPressed: () => pickTime(index, isStart),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(formatTimeOfDay(isStart ? startTimes[index] : endTimes[index]),
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'เลือกเวลา';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<TimeOfDay?> customTimePickerDialog(BuildContext context,
      {TimeOfDay? initialTime}) async {
    int selectedHour = initialTime?.hour ?? TimeOfDay.now().hour;
    int selectedMinute = initialTime?.minute ?? TimeOfDay.now().minute;

    return await showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
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
                                setStateDialog(() => selectedHour = v % 24),
                            childDelegate: ListWheelChildLoopingListDelegate(
                              children: List.generate(
                                  24,
                                  (idx) => Center(
                                          child: Text(idx.toString().padLeft(2, '0'),
                                              style: const TextStyle(fontSize: 20))))),
                            ),
                        ),
                        const Text(':', style: TextStyle(fontSize: 24)),
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
                                setStateDialog(() => selectedMinute = v % 60),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(
                                context, TimeOfDay(hour: selectedHour, minute: selectedMinute)),
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
}

String capitalizeFirstLetter(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
