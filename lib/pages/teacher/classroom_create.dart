import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateClassroom extends StatefulWidget {
  const CreateClassroom({super.key});

  @override
  State<CreateClassroom> createState() => _CreateClassroomState();
}

bool isEndTimeBeforeStartTime(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return endMinutes <= startMinutes;
}

class _CreateClassroomState extends State<CreateClassroom> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomNumberController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  int? selectedDays;
  final List<String> weekDays = [
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์',
  ];
  List<String?> selectedWeekDays = [null, null, null];
  List<TimeOfDay?> startTimes = [null, null, null];
  List<TimeOfDay?> endTimes = [null, null, null];

  final Color primaryColor = const Color(0xFF3F8FAF);

  // เพิ่มตัวแปร error state ใน _CreateClassroomState
  bool subjectError = false;
  bool roomError = false;
  bool startDateError = false;
  bool endDateError = false;
  bool daysError = false;
  List<bool> weekDayError = [false, false, false];
  List<bool> startTimeError = [false, false, false];
  List<bool> endTimeError = [false, false, false];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF221B64),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          onProfileTap: () => Navigator.pushNamed(context, '/profile'),
          onLogoutTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
        ),
      ),
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
                color: Colors.white, borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('สร้างห้องเรียน',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Divider(height: 24, thickness: 1),
                  buildLabeledField('ชื่อวิชา', subjectController, 'กรุณากรอกชื่อวิชา', error: subjectError),
                  const SizedBox(height: 16),
                  buildLabeledField('เลขห้อง', roomNumberController, 'กรุณากรอกเลขห้อง', error: roomError),
                  const SizedBox(height: 16),
                  const Text('วันแรกของเทอม', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildDatePickerButton('เลือกวันแรกของเทอม', selectedStartDate, true, error: startDateError),
                  const SizedBox(height: 16),
                  const Text('วันสุดท้ายของเทอม', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildDatePickerButton('เลือกวันสุดท้ายของเทอม', selectedEndDate, false, error: endDateError),
                  const SizedBox(height: 24),
                  const Text('จำนวนวันที่เรียนต่อสัปดาห์', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: daysError
                        ? BoxDecoration(border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(8))
                        : null,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // ถ้ากว้างเกิน 400 แสดงแนวนอน, ถ้าแคบแสดงแนวตั้ง
                        bool isWide = constraints.maxWidth > 400;
                        return Wrap(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          spacing: 12,
                          runSpacing: 8,
                          children: [1, 2, 3].map((value) {
                            return SizedBox(
                              width: isWide ? (constraints.maxWidth - 24) / 3 : double.infinity,
                              child: RadioListTile<int>(
                                value: value,
                                groupValue: selectedDays,
                                activeColor: primaryColor,
                                onChanged: (val) => setState(() => selectedDays = val),
                                title: Text('$value วัน'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedDays != null)
                    for (int i = 0; i < selectedDays!; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('วันที่ ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('วันที่เรียน: '), const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: weekDayError[i]
                                      ? BoxDecoration(border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(8))
                                      : null,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: const Text('เลือกวัน'),
                                    value: selectedWeekDays[i],
                                    items: weekDays.map((day) {
                                      return DropdownMenuItem(
                                        value: day,
                                        child: Text(
                                          day,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (selectedWeekDays.contains(value)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('ไม่สามารถเลือกวันซ้ำกันได้')),
                                        );
                                      } else {
                                        setState(() => selectedWeekDays[i] = value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          buildTimePickerButton(index: i, isStart: true, error: startTimeError[i]),
                          const SizedBox(height: 12),
                          buildTimePickerButton(index: i, isStart: false, error: endTimeError[i]),
                          const SizedBox(height: 24),
                        ],
                      ),
                  Row(
                    children: const [
                      Icon(Icons.add_location_alt, color: Colors.red),
                      SizedBox(width: 8),
                      Text('ระบุตำแหน่งห้องเรียน',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://www.nsm.or.th/nsm/sites/default/files/2021-12/20200204-2PNG.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        height: 200,
                        child: Center(child: Text('ไม่สามารถโหลดภาพได้', style: TextStyle(color: Colors.red[700]))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('ยกเลิก', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                 onPressed: () async {
  setState(() {
    subjectError = subjectController.text.isEmpty;
    roomError = roomNumberController.text.isEmpty;
    startDateError = selectedStartDate == null;
    endDateError = selectedEndDate == null;
    daysError = selectedDays == null;
    for (int i = 0; i < 3; i++) {
      weekDayError[i] = (selectedDays != null && i < selectedDays!) ? selectedWeekDays[i] == null : false;
      startTimeError[i] = (selectedDays != null && i < selectedDays!) ? startTimes[i] == null : false;
      endTimeError[i] = (selectedDays != null && i < selectedDays!) ? endTimes[i] == null : false;
    }
  });

  bool hasError = subjectError || roomError || startDateError || endDateError || daysError;
  if (selectedDays != null) {
    for (int i = 0; i < selectedDays!; i++) {
      if (weekDayError[i] || startTimeError[i] || endTimeError[i]) {
        hasError = true;
        break;
      }
    }
  }

  if (hasError) {
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('ข้อมูลไม่ครบถ้วน'),
        content: const Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
            ),
            child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
    return;
  }

  // ตรวจสอบเวลาจบต้องมากกว่าเวลาเริ่ม
  for (int i = 0; i < selectedDays!; i++) {
    if (startTimes[i] != null && endTimes[i] != null) {
      if (isEndTimeBeforeStartTime(startTimes[i]!, endTimes[i]!)) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('ข้อมูลไม่ถูกต้อง'),
                content: Text('วันที่ ${i + 1}: เวลาจบคาบเรียนต้องมากกว่าเวลาเริ่มคาบเรียน'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ตกลง'),
                  ),
                ],
              );
            },
          );
        }
        return; // <-- ออกจากฟังก์ชันทันที
      }
    }
  }

  // ตรวจสอบเวลาเรียนไม่ซ้ำกันในวันเดียวกัน
  for (int i = 0; i < selectedDays!; i++) {
    for (int j = i + 1; j < selectedDays!; j++) {
      if (selectedWeekDays[i] == selectedWeekDays[j] &&
          startTimes[i] != null && endTimes[i] != null &&
          startTimes[j] != null && endTimes[j] != null) {

        final s1 = startTimes[i]!;
        final e1 = endTimes[i]!;
        final s2 = startTimes[j]!;
        final e2 = endTimes[j]!;

        final s1m = s1.hour * 60 + s1.minute;
        final e1m = e1.hour * 60 + e1.minute;
        final s2m = s2.hour * 60 + s2.minute;
        final e2m = e2.hour * 60 + e2.minute;

        final isOverlap = s1m < e2m && s2m < e1m;

        if (isOverlap) {
          await showDialog( // <-- เพิ่ม await
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ข้อมูลไม่ถูกต้อง'),
              content: Text(
                'เวลาเรียนของวันที่ ${i + 1} ซ้ำกับวันที่ ${j + 1} (${selectedWeekDays[i]}) กรุณาเปลี่ยนเวลา'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                  child: const Text('ตกลง'),
                )
              ],
            ),
          );
          return;
        }
      }
    }
  }

  Navigator.pushNamed(context, '/classroom');
},

                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('เสร็จสิ้น', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
        CustomBottomNav(currentIndex: 1, context: context),
      ]),
    );
  }
Future<void> pickTime(int index, bool isStart) async {
  final initial = isStart ? startTimes[index] : endTimes[index];
  TimeOfDay? pickedTime = await customTimePickerDialog(context, initialTime: initial);
  if (pickedTime != null) {
    setState(() {
      if (isStart) {
        startTimes[index] = pickedTime;
      } else {
        endTimes[index] = pickedTime;
      }
    });

    // ตรวจสอบเวลาทันทีหลังเลือก
    final start = startTimes[index];
    final end = endTimes[index];
    if (start != null && end != null) {
      if (start.hour == end.hour && start.minute == end.minute) {
        // เวลาเริ่มและจบตรงกัน
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('ข้อมูลไม่ถูกต้อง'),
            content: const Text('เวลาเริ่มและเวลาจบต้องไม่ตรงกัน'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF3F8FAF),
                ),
                child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
        setState(() {
          if (isStart) {
            startTimes[index] = null;
          } else {
            endTimes[index] = null;
          }
        });
      } else if (isEndTimeBeforeStartTime(start, end)) {
        // เวลาจบต้องมากกว่าเวลาเริ่ม
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('ข้อมูลไม่ถูกต้อง'),
            content: const Text('เวลาจบคาบเรียนต้องมากกว่าเวลาเริ่มคาบเรียน'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF3F8FAF),
                ),
                child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
        setState(() {
          if (isStart) {
            startTimes[index] = null;
          } else {
            endTimes[index] = null;
          }
        });
      }
    }
  }
}


  Widget buildTimePickerButton({
    required int index,
    required bool isStart,
    bool error = false,
  }) {
    return Row(
      children: [
        Text(isStart ? 'เวลาเริ่ม: ' : 'เวลาจบ: '),
        const SizedBox(width: 12),
        Container(
          decoration: error
              ? BoxDecoration(border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(8))
              : null,
          child: ElevatedButton(
            onPressed: () => pickTime(index, isStart),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              formatTimeOfDay(isStart ? startTimes[index] : endTimes[index]),
              style: const TextStyle(color: Colors.white),
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

Future<TimeOfDay?> customTimePickerDialog(BuildContext context, {TimeOfDay? initialTime}) async {
  int selectedHour = initialTime?.hour ?? TimeOfDay.now().hour;
  int selectedMinute = initialTime?.minute ?? TimeOfDay.now().minute;

  return await showDialog<TimeOfDay>(context: context, builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(builder: (context, setStateDialog) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Text('เลือกเวลา', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3F8FAF))),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 150,
                width: 80,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.003,
                  controller: FixedExtentScrollController(initialItem: selectedHour),
                  onSelectedItemChanged: (v) => setStateDialog(() => selectedHour = v),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (_, idx) => Center(child: Text(idx.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 20))),
                    childCount: 24,
                  ),
                ),
              ),
              const Text(':', style: TextStyle(fontSize: 24)),
              SizedBox(
                height: 150,
                width: 80,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.003,
                  controller: FixedExtentScrollController(initialItem: selectedMinute),
                  onSelectedItemChanged: (v) => setStateDialog(() => selectedMinute = v),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (_, idx) => Center(child: Text(idx.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 20))),
                    childCount: 60,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, TimeOfDay(hour: selectedHour, minute: selectedMinute)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F8FAF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ]);
        }),
      ),
    );
  });
}


  Widget _buildDatePickerButton(String placeholder, DateTime? selectedDate, bool isStartDate, {bool error = false}) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: error ? Colors.red : primaryColor, width: 1.5),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          selectedDate == null
              ? placeholder
              : '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year + 543}',
          style: TextStyle(
            fontSize: 16,
            color: selectedDate == null
                ? (error ? Colors.red : primaryColor.withOpacity(0.7))
                : primaryColor,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? temp = isStartDate ? selectedStartDate : selectedEndDate;
    DateTime focusedDay = temp ?? DateTime.now();

    await showDialog(context: context, builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(builder: (context, setStateDialog) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(isStartDate ? 'เลือกวันแรกของเทอม' : 'เลือกวันสุดท้ายของเทอม',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B8BAF))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF0F7FB), borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  locale: 'th_TH',
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2035),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const { CalendarFormat.month: 'Month' },
                  rowHeight: 36,
                  selectedDayPredicate: (day) => temp != null && isSameDay(temp, day),
                  onDaySelected: (day, _) {
                    setStateDialog(() {
                      temp = isSameDay(temp, day) ? null : day;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Color(0xFF3F8FAF), shape: BoxShape.circle),
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    defaultTextStyle: TextStyle(color: Colors.black),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3F8FAF)),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF3F8FAF)),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF3F8FAF)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('ยกเลิก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        if (isStartDate) {
                          selectedStartDate = temp;
                          if (selectedEndDate != null && (temp == null || selectedEndDate!.isBefore(temp!))) {
                            selectedEndDate = null;
                          }
                        } else {
                          if (temp != null && selectedStartDate != null && temp!.isAfter(selectedStartDate!)) {
                            selectedEndDate = temp;
                          } else {
                            _showInvalidDateAlert();
                          }
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F8FAF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ]),
          );
        }),
      );
    });
  }

  void _showInvalidDateAlert() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('ข้อมูลไม่ถูกต้อง'),
        content: const Text('วันสุดท้ายของเทอมต้องอยู่หลังวันแรกของเทอม'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF3F8FAF),
            ),
            child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  String _monthName(int month) {
    const monthNames = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return monthNames[month];
  }

  Widget buildLabeledField(String label, TextEditingController controller, String hint, {bool error = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: error ? Colors.red : primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade400, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
