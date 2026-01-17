import 'package:flutter/material.dart'; // นำเข้าไลบรารีพื้นฐานของ Flutter สำหรับการสร้าง UI
import 'package:edunudge/services/api_service.dart'; // นำเข้า ApiService สำหรับการเรียก API
import 'package:dio/dio.dart'; // นำเข้า Dio สำหรับการจัดการ HTTP requests (โดยเฉพาะการดาวน์โหลดไฟล์)
import 'package:path_provider/path_provider.dart'; // นำเข้า path_provider สำหรับจัดการพาธของระบบไฟล์
import 'package:open_file/open_file.dart'; // นำเข้า open_file สำหรับเปิดไฟล์ที่ดาวน์โหลดมา

class Attendance extends StatefulWidget { // ประกาศคลาส Attendance ซึ่งเป็น StatefulWidget
  const Attendance({super.key}); // คอนสตรักเตอร์ของ Attendance พร้อม key

  @override
  State<Attendance> createState() => _AttendanceState(); // สร้าง State object สำหรับคลาสนี้
}

class _AttendanceState extends State<Attendance> { // ประกาศคลาส State ที่เกี่ยวข้องกับ Attendance
  List<Map<String, dynamic>> attendanceData = []; // สร้างลิสต์สำหรับเก็บข้อมูลสรุปการเข้าเรียนรายวิชา
  bool isLoadingTable = true; // ตัวแปรสถานะเพื่อระบุว่ากำลังโหลดตารางสรุปหรือไม่

  String selectedSubject = ''; // ตัวแปรสำหรับเก็บชื่อวิชาที่ถูกเลือกจาก Dropdown
  Map<String, int> subjectIds = {}; // Map สำหรับเก็บชื่อวิชาและ ID ห้องเรียนที่เกี่ยวข้อง

  Map<String, dynamic> selectedSubjectDetail = {}; // Map สำหรับเก็บข้อมูลรายละเอียดของวิชาที่เลือก
  bool isLoadingDetail = false; // ตัวแปรสถานะเพื่อระบุว่ากำลังโหลดรายละเอียดวิชาหรือไม่

  @override
  void initState() { // เมธอดที่ถูกเรียกเมื่อ State object ถูกสร้างขึ้น
    super.initState(); // เรียก initState ของคลาสแม่
    fetchAttendanceData(); // เรียกฟังก์ชันสำหรับดึงข้อมูลสรุปการเข้าเรียนทันที
  }

  Future<void> downloadAndOpenPDF(String url, {String? fileName}) async { // ฟังก์ชันสำหรับดาวน์โหลดและเปิดไฟล์ PDF
    try { // บล็อกสำหรับจัดการข้อผิดพลาด
      final dir = await getTemporaryDirectory(); // รับพาธของไดเรกทอรีชั่วคราวสำหรับเก็บไฟล์
      final name = // กำหนดชื่อไฟล์ ถ้าไม่มีชื่อไฟล์ให้ใช้ชื่อเริ่มต้นพร้อมเวลาปัจจุบัน
          fileName ?? 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$name'; // สร้างพาธแบบเต็มของไฟล์

      await Dio().download(url, filePath); // ใช้ Dio เพื่อดาวน์โหลดไฟล์จาก URL ไปยัง filePath
      await OpenFile.open(filePath); // ใช้ OpenFile เพื่อเปิดไฟล์ที่ดาวน์โหลดมา
    } catch (e) { // ดักจับข้อผิดพลาดที่เกิดขึ้นระหว่างการดาวน์โหลด/เปิดไฟล์
      ScaffoldMessenger.of(context).showSnackBar( // แสดง SnackBar แจ้งข้อผิดพลาด
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดาวน์โหลด PDF: $e')),
      );
    }
  }

  Future<void> fetchAttendanceData() async { // ฟังก์ชันสำหรับดึงข้อมูลสรุปการเข้าเรียน
    setState(() { // อัปเดตสถานะของ widget
      isLoadingTable = true; // ตั้งค่าให้แสดงสถานะกำลังโหลดตาราง
      isLoadingDetail = false; // หยุดแสดงสถานะกำลังโหลดรายละเอียด
      selectedSubjectDetail = {}; // ล้างข้อมูลรายละเอียดเดิม
    });

    try { // บล็อกสำหรับจัดการข้อผิดพลาด
      final data = await ApiService.homeAttendanceSummary(); // เรียก API เพื่อรับข้อมูลสรุป
      final classrooms = List<Map<String, dynamic>>.from(data['classrooms']); // ดึงข้อมูลห้องเรียนจากผลลัพธ์

      subjectIds = { // สร้าง Map ชื่อวิชา: ID ห้องเรียน
        for (var cls in classrooms)
          cls['name_subject'] as String: cls['classroom_id'] as int,
      };

      setState(() { // อัปเดตสถานะเมื่อดึงข้อมูลสรุปสำเร็จ
        attendanceData = classrooms; // เก็บข้อมูลสรุปการเข้าเรียน
        selectedSubject = subjectIds.isNotEmpty ? subjectIds.keys.first : ''; // กำหนดวิชาแรกเป็นวิชาที่ถูกเลือกเริ่มต้น
        isLoadingTable = false; // หยุดแสดงสถานะกำลังโหลดตาราง
      });

      if (selectedSubject.isNotEmpty) { // ถ้ามีวิชาที่ถูกเลือก
        await fetchSubjectDetail(selectedSubject); // ดึงข้อมูลรายละเอียดของวิชาที่เลือก
      } else { // ถ้าไม่มีวิชาเลย
        setState(() { // อัปเดตสถานะให้เป็นค่าว่างและหยุดโหลด
          selectedSubjectDetail = {};
          isLoadingDetail = false;
        });
      }
    } catch (e) { // ดักจับข้อผิดพลาดในการดึงข้อมูลสรุป
      print('Error fetching attendance: $e'); // พิมพ์ข้อผิดพลาดในคอนโซล
      setState(() { // หยุดแสดงสถานะกำลังโหลดทั้งหมด
        isLoadingTable = false;
        isLoadingDetail = false;
      });
    }
  }

  Future<void> fetchSubjectDetail(String subjectName) async { // ฟังก์ชันสำหรับดึงข้อมูลรายละเอียดวิชา
    final classroomId = subjectIds[subjectName]; // ดึง ID ห้องเรียนจากชื่อวิชา
    if (classroomId == null) return; // ถ้าไม่พบ ID ให้หยุดทำงาน

    setState(() { // อัปเดตสถานะก่อนเริ่มโหลดรายละเอียด
      isLoadingDetail = true; // ตั้งค่าให้แสดงสถานะกำลังโหลดรายละเอียด
      selectedSubjectDetail = {}; // ล้างข้อมูลรายละเอียดเดิม
    });

    try { // บล็อกสำหรับจัดการข้อผิดพลาด
      final data = await ApiService.homeSubjectDetail(classroomId); // เรียก API เพื่อรับข้อมูลรายละเอียดวิชา

      setState(() { // อัปเดตสถานะเมื่อดึงข้อมูลสำเร็จ
        selectedSubject = subjectName; // อัปเดตชื่อวิชาที่เลือก
        selectedSubjectDetail = data; // เก็บข้อมูลรายละเอียดวิชา
        isLoadingDetail = false; // หยุดแสดงสถานะกำลังโหลดรายละเอียด
      });
    } catch (e) { // ดักจับข้อผิดพลาดในการดึงข้อมูลรายละเอียด
      print('Error fetching subject detail: $e'); // พิมพ์ข้อผิดพลาดในคอนโซล
      setState(() { // หยุดแสดงสถานะกำลังโหลดรายละเอียด
        isLoadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) { // เมธอดสำหรับสร้าง UI ของ widget
    final screenWidth = MediaQuery.of(context).size.width; // รับความกว้างของหน้าจอ
    final screenHeight = MediaQuery.of(context).size.height; // รับความสูงของหน้าจอ

    return Scaffold( // ส่งกลับ Scaffold หลัก
      extendBody: true, // อนุญาตให้ body ขยายไปด้านล่าง bottom navigation bar (ถ้ามี)
      backgroundColor: Colors.white, // ตั้งค่าสีพื้นหลังเป็นสีขาว
      appBar: AppBar( // AppBar ส่วนหัวของหน้า
        backgroundColor: const Color(0xFF00B894), // ตั้งค่าสีพื้นหลังของ AppBar เป็นสีเขียวมิ้นท์
        elevation: 0, // ยกเลิกเงาใต้ AppBar
        leading: IconButton( // ปุ่มนำทางด้านซ้าย (ย้อนกลับ)
          icon: const Icon(Icons.arrow_back, color: Colors.white), // ไอคอนลูกศรย้อนกลับสีขาว
          onPressed: () => Navigator.pop(context), // เมื่อกดให้กลับไปยังหน้าก่อนหน้า
        ),
        title: const Text( // หัวข้อของ AppBar
          'ข้อมูลการเข้าเรียน', // ข้อความหัวข้อ
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // ลักษณะข้อความ
        ),
        centerTitle: true, // จัดหัวข้อให้อยู่ตรงกลาง
      ),
      body: SingleChildScrollView( // ทำให้เนื้อหาสามารถเลื่อนได้
        padding: EdgeInsets.symmetric( // เว้นขอบรอบเนื้อหา
          horizontal: screenWidth * 0.04, // ขอบแนวนอน 4% ของความกว้าง
          vertical: screenHeight * 0.02, // ขอบแนวตั้ง 2% ของความสูง
        ),
        child: Column( // จัดเรียง Widget แบบแนวตั้ง
          crossAxisAlignment: CrossAxisAlignment.start, // จัดเนื้อหาให้อยู่ชิดซ้าย
          children: [ // รายการของ Widget ใน Column
            isLoadingTable // ตรวจสอบสถานะ: กำลังโหลดตารางสรุปหรือไม่
                ? const Center(child: CircularProgressIndicator()) // ถ้ากำลังโหลด, แสดงวงกลมโหลดกลางจอ
                : Container( // Container สำหรับตารางสรุป
                    width: double.infinity, // ความกว้างเต็มที่
                    decoration: BoxDecoration( // ตกแต่งกล่องตาราง
                      color: const Color(0xFF00B894).withOpacity(0.08), // สีพื้นหลังจางๆ
                      borderRadius: BorderRadius.circular(20), // มุมโค้งมน
                      border: Border.all( // ขอบตาราง
                          color: const Color(0xFF00B894), width: 1.5),
                      boxShadow: [ // เงาตาราง
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column( // จัดเรียงส่วนหัวและแถวข้อมูลของตาราง
                      children: [
                        Container( // Container สำหรับส่วนหัวตาราง
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B894), // สีพื้นหลังส่วนหัว
                            borderRadius: BorderRadius.only( // มุมโค้งมนเฉพาะด้านบน
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12), // Padding แนวตั้ง
                          child: Row( // แถวสำหรับหัวข้อตาราง
                            children: const [
                              Expanded( // หัวข้อ 'ชื่อวิชา'
                                flex: 2, // สัดส่วนความกว้าง 2 ส่วน
                                child: Center(
                                  child: Text(
                                    'ชื่อวิชา',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded( // หัวข้อ 'มา'
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'มา',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded( // หัวข้อ 'มาสาย'
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'มาสาย',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded( // หัวข้อ 'ขาด'
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'ขาด',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded( // หัวข้อ 'ลา'
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    'ลา',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded( // หัวข้อ 'รวมทั้งหมด' (เปอร์เซ็นต์)
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    'รวมทั้งหมด',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...attendanceData.asMap().entries.map((entry) { // วนลูปสร้างแถวข้อมูลจาก attendanceData
                          int idx = entry.key; // ดัชนีของรายการ
                          final val = entry.value; // ข้อมูลของรายการ
                          final bool isLast = // ตรวจสอบว่าเป็นรายการสุดท้ายหรือไม่
                              idx == attendanceData.length - 1;

                          return Container( // Container สำหรับแต่ละแถวข้อมูล
                            decoration: BoxDecoration(
                              color: idx % 2 == 0 // สลับสีพื้นหลังระหว่างแถว
                                  ? Colors.white
                                  : const Color(0xFFE8FDF7), // สีพื้นหลังแถวคู่/คี่
                              border: Border( // ขอบด้านข้างและด้านล่าง
                                left: BorderSide(color: Colors.grey.shade300),
                                right: BorderSide(color: Colors.grey.shade300),
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                              borderRadius: isLast // กำหนดมุมโค้งมนด้านล่างเฉพาะแถวสุดท้าย
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12), // Padding แนวตั้ง
                            child: Row( // แถวสำหรับแสดงข้อมูลการเข้าเรียน
                              children: [
                                Expanded( // ช่อง 'ชื่อวิชา'
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      val['name_subject'] ?? '', // แสดงชื่อวิชา
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded( // ช่อง 'มา'
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      val['present']?.toString() ?? '0', // จำนวนครั้งที่มา
                                      style: const TextStyle(
                                        color: Colors.green, // สีเขียว
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded( // ช่อง 'มาสาย'
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      val['late']?.toString() ?? '0', // จำนวนครั้งที่มาสาย
                                      style: const TextStyle(
                                        color: Colors.orange, // สีส้ม
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded( // ช่อง 'ขาด'
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      val['absent']?.toString() ?? '0', // จำนวนครั้งที่ขาด
                                      style: const TextStyle(
                                        color: Colors.red, // สีแดง
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded( // ช่อง 'ลา'
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      val['leave_count']?.toString() ?? '0', // จำนวนครั้งที่ลา
                                      style: const TextStyle(
                                        color: Colors.blue, // สีน้ำเงิน
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded( // ช่อง 'รวมทั้งหมด' (เปอร์เซ็นต์)
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      '${val['percent']?.toString() ?? '0'}%', // เปอร์เซ็นต์การเข้าเรียน
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(), // แปลงผลลัพธ์การวนลูปเป็นลิสต์ของ Widgets
                      ],
                    ),
                  ),
            const SizedBox(height: 16), // เว้นระยะห่างแนวตั้ง
            Align( // จัดตำแหน่ง DropdownButton
              alignment: Alignment.centerLeft, // จัดให้อยู่ชิดซ้าย
              child: Container( // Container สำหรับ Dropdown
                padding: // Padding ภายใน Dropdown
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration( // ตกแต่งกล่อง Dropdown
                  color: const Color(0xFF00B894).withOpacity(0.08), // สีพื้นหลังจางๆ
                  borderRadius: BorderRadius.circular(24), // มุมโค้งมน
                  border: Border.all(color: const Color(0xFF00B894), width: 1.5), // ขอบสีเขียว
                ),
                child: DropdownButtonHideUnderline( // ซ่อนเส้นใต้ Dropdown
                  child: DropdownButton<String>( // Dropdown สำหรับเลือกวิชา
                    value: selectedSubject.isNotEmpty ? selectedSubject : null, // ค่าที่เลือกในปัจจุบัน
                    icon: const Icon(Icons.arrow_drop_down), // ไอคอนลูกศร
                    dropdownColor: Colors.white, // สีพื้นหลังของเมนู Dropdown
                    borderRadius: BorderRadius.circular(16), // มุมโค้งมนของเมนู Dropdown
                    style: const TextStyle(color: Colors.black, fontSize: 16), // ลักษณะข้อความ
                    onChanged: (String? newValue) { // เมื่อมีการเลือกค่าใหม่
                      if (newValue == null) return; // ถ้าเป็น null ให้ออก
                      setState(() { // อัปเดตสถานะวิชาที่เลือก
                        selectedSubject = newValue;
                      });
                      fetchSubjectDetail(newValue); // ดึงข้อมูลรายละเอียดของวิชาใหม่
                    },
                    items: subjectIds.keys.map((value) { // สร้างรายการ (DropdownMenuItem) จากชื่อวิชาทั้งหมด
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, textAlign: TextAlign.center),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8), // เว้นระยะห่างแนวตั้ง
            Container( // Container สำหรับแสดงรายละเอียดวิชาที่เลือก
              width: double.infinity, // ความกว้างเต็มที่
              margin: const EdgeInsets.only(top: 8), // Margin ด้านบน
              padding: const EdgeInsets.all(16), // Padding ภายใน
              decoration: BoxDecoration( // ตกแต่งกล่องรายละเอียด
                color: const Color(0xFF00B894).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00B894), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: isLoadingDetail // ตรวจสอบสถานะ: กำลังโหลดรายละเอียดหรือไม่
                  ? const Center(child: CircularProgressIndicator()) // ถ้ากำลังโหลด, แสดงวงกลมโหลดกลางจอ
                  : Text( // แสดงรายละเอียดวิชา
                      'ชื่อวิชา: ${selectedSubjectDetail['name_subject'] ?? '-'}\n'
                      'อาคารเรียน: ${selectedSubjectDetail['room_number'] ?? '-'}\n'
                      'อาจารย์ผู้สอน: ${selectedSubjectDetail['teacher_name'] ?? '-'}\n'
                      'คณะ: ${selectedSubjectDetail['faculty'] ?? '-'}\n'
                      'สาขา: ${selectedSubjectDetail['department'] ?? '-'}\n'
                      'เบอร์ติดต่อ: ${selectedSubjectDetail['contact'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
            ),
            const SizedBox(height: 24), // เว้นระยะห่างแนวตั้ง
            Center( // จัดปุ่มดาวน์โหลดให้อยู่ตรงกลาง
              child: ElevatedButton.icon( // ปุ่มสำหรับดาวน์โหลดเอกสาร PDF
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEAA7), // สีพื้นหลังปุ่ม (สีเหลืองอ่อน)
                  shape: RoundedRectangleBorder( // รูปร่างปุ่ม: มุมโค้งมน
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric( // Padding ภายในปุ่ม
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 3, // เงาปุ่ม
                ),
                onPressed: () async { // สิ่งที่เกิดขึ้นเมื่อกดปุ่ม
                  try {
                    final token = await ApiService.getToken(); // ดึง Token สำหรับใช้ใน URL
                    final url = // สร้าง URL สำหรับดาวน์โหลด PDF โดยใช้ Token
                        'http://52.63.155.211/student/home-attendance-pdf/$token';

                    await downloadAndOpenPDF( // เรียกฟังก์ชันดาวน์โหลดและเปิด PDF
                      url,
                      fileName: 'attendance_${selectedSubject}.pdf', // กำหนดชื่อไฟล์ PDF
                    );
                  } catch (e) { // ดักจับข้อผิดพลาด
                    ScaffoldMessenger.of(context).showSnackBar( // แสดง SnackBar แจ้งข้อผิดพลาด
                      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                    );
                  }
                },
                icon: const Icon( // ไอคอนรูป PDF
                  Icons.picture_as_pdf,
                  color: Colors.black87,
                  size: 22,
                ),
                label: const Text( // ข้อความบนปุ่ม
                  'ดาวน์โหลดเอกสาร (pdf.)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}