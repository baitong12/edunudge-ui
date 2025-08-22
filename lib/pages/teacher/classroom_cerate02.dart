import 'package:flutter/material.dart';
import 'package:edunudge/shared/customappbar.dart';
import 'package:edunudge/pages/teacher/custombottomnav.dart';

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
  List<String> weekDays = ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'];
  List<String?> selectedWeekDays = List.filled(3, null);
  List<TimeOfDay?> startTimes = List.filled(3, null);
  List<TimeOfDay?> endTimes = List.filled(3, null);

  bool daysError = false;
  List<bool> weekDayError = [false, false, false];
  List<bool> startTimeError = [false, false, false];
  List<bool> endTimeError = [false, false, false];

  bool isSaving = false;

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
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const Divider(height: 24, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('จำนวนวันที่เรียนต่อสัปดาห์', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: daysError
                            ? BoxDecoration(border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(8))
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
                                  selectedWeekDays = List.filled(3, null);
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
                                            child: Text(day, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (selectedWeekDays.sublist(0, selectedDays!).contains(value)) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('ไม่สามารถเลือกวันซ้ำกันได้')),
                                            );
                                          } else {
                                            setState(() {
                                              selectedWeekDays[i] = value;
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
                              buildTimePickerButton(index: i, isStart: true, error: startTimeError[i]),
                              const SizedBox(height: 12),
                              buildTimePickerButton(index: i, isStart: false, error: endTimeError[i]),
                              const SizedBox(height: 24),
                            ],
                          ),
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
                        backgroundColor: Colors.red, 
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('ยกเลิก', style: TextStyle(color: Colors.white, fontSize: 16)), 
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
                        child: Text('ถัดไป', style: TextStyle(color: Colors.white, fontSize: 16)), 
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomBottomNav(currentIndex: 1, context: context),
          ]),
        ),
      ),
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
          _showAlertDialog('ข้อมูลไม่ถูกต้อง', 'เวลาจบคาบเรียนต้องมากกว่าเวลาเริ่มคาบเรียน');
          hasError = true;
        }
      }
    }

    if (!hasError) {
      Navigator.pushNamed(context, '/classroom_create03');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง')),
      );
    }
  }

  Future<void> pickTime(int index, bool isStart) async {
    final initial = isStart ? startTimes[index] : endTimes[index];
    TimeOfDay? pickedTime = await customTimePickerDialog(context, initialTime: initial);
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
      
      final start = startTimes[index];
      final end = endTimes[index];
      if (start != null && end != null) {
        if (start.hour == end.hour && start.minute == end.minute) {
          _showAlertDialog('ข้อมูลไม่ถูกต้อง', 'เวลาเริ่มและเวลาจบต้องไม่ตรงกัน');
          setState(() {
            if (isStart) {
              startTimes[index] = null;
              startTimeError[index] = true;
            } else {
              endTimes[index] = null;
              endTimeError[index] = true;
            }
          });
        } else if (isEndTimeBeforeStartTime(start, end)) {
          _showAlertDialog('ข้อมูลไม่ถูกต้อง', 'เวลาจบคาบเรียนต้องมากกว่าเวลาเริ่มคาบเรียน');
          setState(() {
            if (isStart) {
              startTimes[index] = null;
              startTimeError[index] = true;
            } else {
              endTimes[index] = null;
              endTimeError[index] = true;
            }
          });
        }
      }
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
}
