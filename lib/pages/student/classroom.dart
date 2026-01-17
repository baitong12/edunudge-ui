import 'package:flutter/material.dart'; // นำเข้าไลบรารีพื้นฐานของ Flutter สำหรับการสร้าง UI
import 'package:edunudge/pages/student/custombottomnav.dart'; // นำเข้า CustomBottomNav สำหรับแถบนำทางด้านล่าง
import 'package:edunudge/shared/customappbar.dart'; // นำเข้า CustomAppBar สำหรับแถบด้านบนที่กำหนดเอง
import 'package:edunudge/services/api_service.dart'; // นำเข้า ApiService สำหรับการเรียก API

class Classroom extends StatefulWidget { // ประกาศคลาส Classroom ซึ่งเป็น StatefulWidget
  const Classroom({super.key}); // คอนสตรักเตอร์ของ Classroom พร้อม key

  @override
  State<Classroom> createState() => _ClassroomState(); // สร้าง State object สำหรับคลาสนี้
}

class _ClassroomState extends State<Classroom> { // ประกาศคลาส State ที่เกี่ยวข้องกับ Classroom
  List<Map<String, String>> classrooms = []; // สร้างลิสต์ว่างสำหรับเก็บข้อมูลห้องเรียน (เป็น Map ของ String:String)
  bool isLoading = true; // ตัวแปรสถานะเพื่อระบุว่ากำลังโหลดข้อมูลหรือไม่, เริ่มต้นเป็น true
  String? error; // ตัวแปรสำหรับเก็บข้อความแสดงข้อผิดพลาด (ถ้ามี)

  @override
  void initState() { // เมธอดที่ถูกเรียกเมื่อ State object ถูกสร้างขึ้น
    super.initState(); // เรียก initState ของคลาสแม่
    fetchClassrooms(); // เรียกฟังก์ชันสำหรับดึงข้อมูลห้องเรียนทันที
  }

  Future<void> fetchClassrooms() async { // ฟังก์ชันแบบ async สำหรับดึงข้อมูลห้องเรียนจาก API
    setState(() { // อัปเดตสถานะของ widget
      isLoading = true; // ตั้งค่าให้แสดงสถานะกำลังโหลด
      error = null; // ล้างข้อความแสดงข้อผิดพลาดเดิม
    });
    try { // บล็อกสำหรับจัดการข้อผิดพลาด
      final data = await ApiService.getStudentClassrooms(); // เรียก API เพื่อรับข้อมูลห้องเรียนของนักเรียน
      setState(() { // อัปเดตสถานะเมื่อดึงข้อมูลสำเร็จ
        classrooms = data.map<Map<String, String>>((c) { // แปลงข้อมูลที่ได้จาก API ให้อยู่ในรูปแบบ List<Map<String, String>>
          return { // สร้าง Map ใหม่จากข้อมูลห้องเรียนแต่ละรายการ
            'id': c['id'].toString(), // เก็บ ID ของห้องเรียน
            'subject': c['name_subject'] ?? '', // เก็บชื่อวิชา, ถ้าเป็น null ให้เป็นสตริงว่าง
            'room': c['room_number'] ?? '', // เก็บหมายเลขห้อง, ถ้าเป็น null ให้เป็นสตริงว่าง
            'teacher': c['teachers'] ?? '', // เก็บชื่อครูผู้สอน, ถ้าเป็น null ให้เป็นสตริงว่าง
          };
        }).toList(); // แปลงผลลัพธ์ทั้งหมดให้เป็นลิสต์
        isLoading = false; // ตั้งค่าเป็น false เพื่อหยุดแสดงสถานะกำลังโหลด
      });
    } catch (e) { // ดักจับข้อผิดพลาดที่เกิดขึ้นระหว่างการเรียก API
      setState(() { // อัปเดตสถานะเมื่อเกิดข้อผิดพลาด
        error = e.toString(); // เก็บข้อความแสดงข้อผิดพลาด
        isLoading = false; // ตั้งค่าเป็น false เพื่อหยุดแสดงสถานะกำลังโหลด
      });
    }
  }

  @override
  Widget build(BuildContext context) { // เมธอดสำหรับสร้าง UI ของ widget
    final screenWidth = MediaQuery.of(context).size.width; // รับความกว้างของหน้าจอ
    final screenHeight = MediaQuery.of(context).size.height; // รับความสูงของหน้าจอ

    final cardColors = [Color(0xFF00B894)]; // กำหนดลิสต์ของสีสำหรับบัตรห้องเรียน (ปัจจุบันมีเพียงสีเดียว: เขียวมิ้นท์)

    return Scaffold( // ส่งกลับ Scaffold หลัก
      backgroundColor: Colors.transparent, // ตั้งค่าพื้นหลังเป็นโปร่งใส (เพื่อใช้สีพื้นหลังจาก Container ด้านใน)
      body: Container( // สร้าง Container สำหรับจัดการพื้นหลังและ UI ทั้งหมด
        decoration: const BoxDecoration( // กำหนดการตกแต่งของ Container
          color: Color.fromARGB(255, 255, 255, 255), // ตั้งค่าสีพื้นหลังเป็นสีขาวทึบ
        ),

        child: Scaffold( // Scaffold ซ้อนด้านในเพื่อใช้ AppBar และ BottomNavigationBar
          backgroundColor: Colors.transparent, // ตั้งค่าพื้นหลังเป็นโปร่งใส (เพื่อให้ Container ด้านนอกกำหนดสีพื้นหลัง)
          appBar: PreferredSize( // ใช้ PreferredSize เพื่อกำหนดขนาด AppBar
            preferredSize: const Size.fromHeight(80), // กำหนดความสูงของ AppBar
            child: CustomAppBar( // ใช้ CustomAppBar ที่กำหนดเอง
              onProfileTap: () { // กำหนดสิ่งที่เกิดขึ้นเมื่อกดไอคอนโปรไฟล์
                Navigator.pushNamed(context, '/profile'); // นำทางไปยังหน้าโปรไฟล์
              },
              onLogoutTap: () { // กำหนดสิ่งที่เกิดขึ้นเมื่อกดไอคอนออกจากระบบ
                Navigator.pushNamedAndRemoveUntil( // นำทางไปยังหน้า login และล้าง stack เส้นทางทั้งหมด
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
          body: Padding( // ใช้ Padding เพื่อเว้นขอบรอบเนื้อหาหลัก
            padding: EdgeInsets.symmetric( // กำหนดขอบด้านซ้าย/ขวา และบน/ล่าง
              horizontal: screenWidth * 0.04, // ขอบแนวนอน 4% ของความกว้างหน้าจอ
              vertical: screenHeight * 0.02, // ขอบแนวตั้ง 2% ของความสูงหน้าจอ
            ),
            child: isLoading // ตรวจสอบสถานะ: กำลังโหลดหรือไม่
                ? const Center(child: CircularProgressIndicator()) // ถ้ากำลังโหลด, แสดงวงกลมโหลดกลางจอ
                : error != null // ตรวจสอบสถานะ: มีข้อผิดพลาดหรือไม่
                ? Center( // ถ้ามีข้อผิดพลาด, แสดงข้อความผิดพลาด
                    child: Text(
                      error!, // แสดงข้อความผิดพลาด
                      style: TextStyle(
                        color: Colors.white, // สีข้อความ (อาจต้องเปลี่ยนสีเพื่อให้มองเห็นได้บนพื้นหลังขาว)
                        fontSize: screenWidth * 0.045, // ขนาดตัวอักษร
                      ),
                      textAlign: TextAlign.center, // จัดตำแหน่งข้อความตรงกลาง
                    ),
                  )
                : classrooms.isEmpty // ตรวจสอบสถานะ: มีข้อมูลห้องเรียนหรือไม่
                ? Center( // ถ้าไม่มีข้อมูลห้องเรียน, แสดงข้อความแจ้งเตือน
                    child: Text(
                      'ไม่พบห้องเรียน\nกรุณาเข้าร่วมห้องเรียน', // ข้อความแจ้งเตือนเป็นภาษาไทย
                      textAlign: TextAlign.center, // จัดตำแหน่งข้อความตรงกลาง
                      style: TextStyle(
                        color: Colors.white, // สีข้อความ (อาจต้องเปลี่ยนสีเพื่อให้มองเห็นได้บนพื้นหลังขาว)
                        fontSize: screenWidth * 0.05, // ขนาดตัวอักษร
                        fontWeight: FontWeight.bold, // ตัวหนา
                      ),
                    ),
                  )
                : RefreshIndicator( // ถ้ามีข้อมูล, แสดงรายการห้องเรียนใน RefreshIndicator
                    onRefresh: fetchClassrooms, // กำหนดฟังก์ชันที่จะถูกเรียกเมื่อผู้ใช้ดึงเพื่อรีเฟรช
                    color: Colors.white, // สีของวงกลมโหลดเมื่อรีเฟรช (อาจต้องเปลี่ยนสี)
                    child: ListView.builder( // สร้างรายการด้วย ListView.builder เพื่อประสิทธิภาพ
                      itemCount: classrooms.length, // จำนวนรายการเท่ากับจำนวนห้องเรียน
                      itemBuilder: (context, index) { // ฟังก์ชันสำหรับสร้าง widget ในแต่ละรายการ
                        final classroom = classrooms[index]; // ดึงข้อมูลห้องเรียนปัจจุบัน
                        final cardColor = cardColors[index % cardColors.length]; // วนสีบัตรตามลำดับ

                        return Padding( // ใส่ Padding ด้านล่างให้กับบัตรแต่ละใบ
                          padding: EdgeInsets.only(bottom: screenHeight * 0.02), // เว้นระยะห่างด้านล่าง 2% ของความสูงหน้าจอ
                          child: InkWell( // ใช้ InkWell เพื่อให้บัตรสามารถกดได้
                            borderRadius: BorderRadius.circular( // กำหนดรัศมีมุมโค้งมน
                              screenWidth * 0.05, // รัศมี 5% ของความกว้างหน้าจอ
                            ),
                            onTap: () { // สิ่งที่เกิดขึ้นเมื่อกดที่บัตร
                              Navigator.pushNamed( // นำทางไปยังหน้า '/subject'
                                context,
                                '/subject',
                                arguments: {'id': classroom['id'] ?? ''}, // ส่ง ID ห้องเรียนเป็น argument
                              );
                            },
                            child: Container( // Container สำหรับออกแบบบัตรห้องเรียน
                              decoration: BoxDecoration( // กำหนดการตกแต่งของบัตร
                                color: cardColor, // ใช้สีที่กำหนดไว้
                                borderRadius: BorderRadius.circular( // กำหนดรัศมีมุมโค้งมน
                                  screenWidth * 0.05,
                                ),
                                border: Border.all( // กำหนดเส้นขอบสีขาว
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [ // กำหนดเงาให้กับบัตร
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15), // สีเงา
                                    blurRadius: 6, // รัศมีความเบลอ
                                    offset: const Offset(0, 3), // ตำแหน่งเงา (เลื่อนลง 3 พิกเซล)
                                  ),
                                ],
                              ),
                              child: Padding( // Padding ภายในบัตร
                                padding: EdgeInsets.all(screenWidth * 0.04), // Padding 4% ของความกว้างหน้าจอทุกด้าน
                                child: Column( // จัดเรียงเนื้อหาภายในบัตรแบบแนวตั้ง
                                  crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความให้อยู่ชิดซ้าย
                                  children: [
                                    Row( // แถวสำหรับไอคอนและชื่อวิชา
                                      children: [
                                        Icon( // ไอคอนรูปห้องเรียน
                                          Icons.class_,
                                          color: Colors.white, // สีไอคอน
                                          size: screenWidth * 0.07, // ขนาดไอคอน
                                        ),
                                        SizedBox(width: screenWidth * 0.03), // เว้นระยะห่างเล็กน้อย
                                        Expanded( // ใช้ Expanded เพื่อให้ Text ครอบคลุมพื้นที่ที่เหลือและจัดการข้อความยาว
                                          child: Text(
                                            classroom['subject']!, // ชื่อวิชา
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.05, // ขนาดตัวอักษร
                                              fontWeight: FontWeight.bold, // ตัวหนา
                                              color: Colors.white, // สีข้อความ
                                            ),
                                            maxLines: 2, // จำกัดจำนวนบรรทัดสูงสุดเป็น 2
                                            overflow: TextOverflow.ellipsis, // แสดงจุดไข่ปลาถ้าข้อความเกิน
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01), // เว้นระยะห่างแนวตั้ง 1%
                                    Row( // แถวสำหรับไอคอนและหมายเลขห้อง
                                      children: [
                                        Icon( // ไอคอนรูปห้องประชุม
                                          Icons.meeting_room,
                                          size: screenWidth * 0.05, // ขนาดไอคอน
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: screenWidth * 0.02), // เว้นระยะห่าง
                                        Text(
                                          classroom['room']!, // หมายเลขห้อง
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.008), // เว้นระยะห่างแนวตั้งเล็กน้อย
                                    Row( // แถวสำหรับไอคอนและชื่อครู
                                      children: [
                                        Icon( // ไอคอนรูปบุคคล
                                          Icons.person,
                                          size: screenWidth * 0.05,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: screenWidth * 0.02), // เว้นระยะห่าง
                                        Expanded( // ใช้ Expanded เพื่อจัดการชื่อครูที่ยาว
                                          child: Text(
                                            classroom['teacher']!, // ชื่อครูผู้สอน
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.037,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1, // จำกัดจำนวนบรรทัดเป็น 1
                                            overflow: TextOverflow.ellipsis, // แสดงจุดไข่ปลาถ้าข้อความเกิน
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
                      },
                    ),
                  ),
          ),
          bottomNavigationBar: CustomBottomNav( // แถบนำทางด้านล่างที่กำหนดเอง
            currentIndex: 2, // กำหนด index ปัจจุบัน (ปกติจะเป็น index ของหน้า 'Classroom')
            context: context, // ส่ง context ไปยัง CustomBottomNav
          ),
        ),
      ),
    );
  }
}