import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edunudge/services/api_service.dart';

class ClassroomSettingsPage extends StatefulWidget {
  final int classroomId;

  const ClassroomSettingsPage({super.key, required this.classroomId});

  @override
  _ClassroomSettingsPageState createState() => _ClassroomSettingsPageState();
}

class _ClassroomSettingsPageState extends State<ClassroomSettingsPage> {
  TimeOfDay greenTime = TimeOfDay(hour: 0, minute: 1);
  TimeOfDay redTime = TimeOfDay(hour: 0, minute: 1);
  bool isOpen = true;
  List<DateTime> selectedHolidays = [];

  Future<void> _selectTime(String level, TimeOfDay current) async {
    int tempMinute = current.minute;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInner) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: EdgeInsets.all(20),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              height: 300,
              child: Column(
                children: [
                  Text(
                    'เลือกนาทีแจ้งเตือน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F8FAF),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                          initialItem: tempMinute - 1),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setInner(() {
                          tempMinute = index + 1;
                        });
                      },
                      children: List<Widget>.generate(
                        60,
                        (index) => Center(
                          child: Text('${index + 1} นาที',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF3F8FAF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (level == 'green')
                                greenTime =
                                    TimeOfDay(hour: 0, minute: tempMinute);
                              if (level == 'red')
                                redTime =
                                    TimeOfDay(hour: 0, minute: tempMinute);
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              color: Colors.white,
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
            ),
          ),
        );
      },
    );
  }

  void _selectStatus() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('เปิด', style: TextStyle(fontSize: 18)),
              trailing:
                  isOpen ? Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                setState(() => isOpen = true);
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('ปิด', style: TextStyle(fontSize: 18)),
              trailing:
                  !isOpen ? Icon(Icons.check_circle, color: Colors.red) : null,
              onTap: () {
                setState(() => isOpen = false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickHolidaysDialog() async {
    final now = DateTime.now();
    List<DateTime> tempSelected = List.from(selectedHolidays);

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInner) => Dialog(
          insetPadding: EdgeInsets.all(12),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            width: 380,
            constraints: BoxConstraints(maxHeight: 640, minWidth: 340),
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'เลือกวันหยุด',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F8FAF),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F8FA),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(8),
                  child: TableCalendar(
                    locale: 'th_TH',
                    firstDay: DateTime(now.year - 1, 1, 1),
                    lastDay: DateTime(now.year + 2, 12, 31),
                    focusedDay:
                        tempSelected.isNotEmpty ? tempSelected.last : now,
                    selectedDayPredicate: (day) => tempSelected.any((d) =>
                        d.year == day.year &&
                        d.month == day.month &&
                        d.day == day.day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setInner(() {
                        if (tempSelected.any((d) =>
                            d.year == selectedDay.year &&
                            d.month == selectedDay.month &&
                            d.day == selectedDay.day)) {
                          tempSelected.removeWhere((d) =>
                              d.year == selectedDay.year &&
                              d.month == selectedDay.month &&
                              d.day == selectedDay.day);
                        } else {
                          tempSelected.add(selectedDay);
                        }
                      });
                    },
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      todayDecoration: BoxDecoration(
                        color: Color(0xFFFFD54F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFD54F).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF3F8FAF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3F8FAF).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      weekendTextStyle: TextStyle(color: Colors.redAccent),
                      defaultTextStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF222222),
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: Color(0xFF3F8FAF), size: 28),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: Color(0xFF3F8FAF), size: 28),
                      titleTextFormatter: (date, locale) =>
                          DateFormat.yMMMM('th').format(date),
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F8FAF),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFFEAF6FA),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      weekdayStyle: TextStyle(
                        color: Color(0xFF3F8FAF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ยกเลิก',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3F8FAF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedHolidays = tempSelected;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
    );
  }

  /// ✅ ฟังก์ชันลบห้องเรียน
void _confirmDeleteClassroom() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('ยืนยันการลบห้องเรียน',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบห้องเรียนนี้? การดำเนินการนี้ไม่สามารถย้อนกลับได้'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ยกเลิก', style: TextStyle(color: Color(0xFF3F8FAF))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            Navigator.pop(context); // ปิด dialog ก่อน
            try {
              await ApiService.deleteClassroom(widget.classroomId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบห้องเรียนเรียบร้อยแล้ว')),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home_teacher',
                (route) => false,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
              );
            }
          },
          child: Text('ลบ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  String formatTime(TimeOfDay t) {
    return '${t.minute} นาที';
  }

  String holidaysText() {
    if (selectedHolidays.isEmpty) {
      return 'แตะเพื่อเลือก';
    } else {
      final formattedDates = selectedHolidays
          .map((d) => DateFormat('d MMM', 'th').format(d))
          .join(', ');
      return formattedDates;
    }
  }

  Future<void> _saveSettings() async {
    try {
      await Future.wait([
        ApiService.updateWarnTimes(
          widget.classroomId,
          warnGreen: greenTime.minute.toString(),
          warnRed: redTime.minute.toString(),
        ),
        ApiService.updateClassroomStatus(
          widget.classroomId,
          isOpen ? 1 : 0,
        ),
        ApiService.updateHolidays(
          widget.classroomId,
          selectedHolidays,
        ),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกการตั้งค่าห้องเรียนเรียบร้อยแล้ว')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xFF00C853),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก',
                    style: TextStyle(color: Colors.grey[300], fontSize: 16)),
              ),
            ),
            Center(
              child: Text('การตั้งค่า',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saveSettings,
                child: Text('เสร็จสิ้น',
                    style: TextStyle(
                        color: Color.fromARGB(255, 12, 12, 12), fontSize: 16)),
              ),
            ),
          ],
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
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เวลาการแจ้งเตือน',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                            fontSize: 16)),
                    SizedBox(height: 10),
                    _buildSettingTile(
                        '🟢 แจ้งเตือนระดับสีเขียว',
                        formatTime(greenTime),
                        () => _selectTime('green', greenTime)),
                    _buildSettingTile('🔴 แจ้งเตือนระดับสีแดง',
                        formatTime(redTime), () => _selectTime('red', redTime)),
                    SizedBox(height: 30),
                    Text('สถานะห้องเรียน',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                            fontSize: 16)),
                    SizedBox(height: 10),
                    _buildSettingTile('สถานะห้องเรียน', isOpen ? 'เปิด' : 'ปิด',
                        _selectStatus),
                    SizedBox(height: 30),
                    Text('วันหยุดแจ้งเตือน',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                            fontSize: 16)),
                    SizedBox(height: 10),
                    _buildSettingTile(
                        'เลือกวันหยุด', holidaysText(), _pickHolidaysDialog),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _confirmDeleteClassroom,
                            icon: Icon(Icons.delete, color: Colors.white),
                            label: Text(
                              'ลบห้องเรียน',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
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
    );
  }

  Widget _buildSettingTile(String title, String value, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: TextStyle(color: Colors.grey[600], fontSize: 15)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
