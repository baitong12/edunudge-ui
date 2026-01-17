import 'package:flutter/material.dart'; 
//  นำเข้า Material Design ของ Flutter เพื่อใช้งาน widget พื้นฐาน เช่น Text, Button, Column, Container, Dialog

class GuideDialog extends StatelessWidget {
  const GuideDialog({super.key}); 
  //  ประกาศ class GuideDialog เป็น StatelessWidget (เพราะเนื้อหาภายในไม่เปลี่ยนค่า)
  //  ใช้ const constructor เพื่อลดการ build widget ซ้ำๆ เมื่อค่าภายในไม่เปลี่ยน

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    //  ใช้ MediaQuery เพื่อดึงขนาดหน้าจอของอุปกรณ์ (ความสูง/ความกว้าง)
    //  เก็บลงตัวแปร screenHeight, screenWidth เพื่อใช้คำนวณขนาด UI ภายใน dialog

    return Dialog(
      insetPadding: const EdgeInsets.all(16), 
      //  ระยะห่างรอบๆ dialog จากขอบหน้าจอ (padding ด้านนอก)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
      //  กำหนดรูปทรงของ dialog เป็นสี่เหลี่ยมมุมโค้ง 16px

      child: Container(
        width: screenWidth * 0.9, 
        height: screenHeight * 0.85,
        //  กำหนดขนาดกล่องตามสัดส่วนหน้าจอ (90% ของกว้าง, 85% ของสูง)

        padding: const EdgeInsets.all(20), 
        //  ระยะห่างด้านในของกล่อง

        decoration: BoxDecoration(
          color: Colors.white, 
          //  พื้นหลังสีขาว

          borderRadius: BorderRadius.circular(16), 
          //  มุมโค้งเหมือนกันกับ dialog

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              blurRadius: 5, 
              spreadRadius: 1, 
              offset: const Offset(0, 3),
            ),
            //  เงาด้านหลังกล่อง: สีดำโปร่งใส, เบลอ 5px, กระจาย 1px, ขยับลง 3px
          ],
        ),

        child: Column(
          children: [
            //  รูปภาพคู่มือ (สามารถซูม/เลื่อนได้)
            ClipRRect(
              borderRadius: BorderRadius.circular(12), 
              //  ทำให้รูปภาพมีมุมโค้ง

              child: InteractiveViewer(
                panEnabled: true, //  เปิดให้เลื่อนภาพได้ (ลากซ้ายขวา/ขึ้นลง)
                minScale: 1.0, //  ขนาดเล็กสุดที่ซูมได้ = 1 เท่า (100%)
                maxScale: 4.0, //  ขนาดใหญ่สุดที่ซูมได้ = 4 เท่า (400%)

                child: Image.asset(
                  'images/K.png', 
                  //  ดึงรูปจาก assets (ต้องไปกำหนดใน pubspec.yaml ด้วย)

                  fit: BoxFit.contain, 
                  //  แสดงรูปให้พอดีกับกรอบ โดยไม่ถูกตัดขอบ
                  
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.45,
                  //  กำหนดสัดส่วนรูปภาพจากขนาดหน้าจอ
                ),
              ),
            ),

            const SizedBox(height: 16), 
            //  เว้นช่องว่างระหว่างรูปภาพกับข้อความ

            //  เนื้อหาข้อความ (สามารถเลื่อนอ่านได้ถ้ายาวเกิน)
            Expanded(
              child: SingleChildScrollView(
                //  ทำให้สามารถเลื่อนข้อความได้ถ้ายาวเกินพื้นที่

                child: Container(
                  padding: const EdgeInsets.all(16), 
                  //  ระยะห่างข้อความจากขอบกล่อง

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, 
                    //  พื้นหลังสีเทาอ่อน

                    borderRadius: BorderRadius.circular(12), 
                    //  มุมโค้ง
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    //  จัดข้อความชิดซ้าย

                    children: const [
                      Text(
                        """ขั้นตอนการสร้างห้องเรียน
                        
1. คลิกที่เมนูสร้างห้องเรียน ระบบจะนำไปยังหน้าสร้างห้องเรียน
2. กรอกข้อมูลรายวิชาให้ครบ และข้อมูลเกี่ยวการศึกษาให้ครบถ้วน จากนั้นคลิกถัดไป
3. กรุณาเลือกจำนวนวันที่เรียนต่อสัปดาห์ก่อน จากนั้นกรอกข้อมูลวันและเวลาที่เรียนให้ครบถ้วน จากนั้นคลิกถัดไป
4. กรุณากรอกเกณฑ์การให้คะแนน แบ่งออกเป็น 2 ส่วน

ส่วนที่ 1
  - ช่องที่ 1 มาเรียนติดกัน x วัน หมายถึง นักศึกษาต้องมาเรียนตรงเวลาติดกัน x วัน 
  - ช่องที่ 2 ได้ x คะแนนสะสม หมายถึง ถ้ามาเรียนติดกัน x วัน จะได้คะแนนสะสมในแอปฯ

  ตัวอย่าง: มาเรียนติดกัน 3 วัน ได้ 5 คะแนน

ส่วนที่ 2
  - ช่องที่ 1 เลือกจำนวนรายการที่ใช้คำนวณคะแนนพิเศษ
  - ช่องที่ 2 เลือกการให้คะแนนสะสม (ร้อยละ)
  - ช่องที่ 3 เลือกการให้คะแนนพิเศษท้ายเทอม (จำนวนเต็ม)

  ตัวอย่าง:
   1. ถ้าคะแนนสะสม = 100% ได้ 10 คะแนนท้ายเทอม
   2. ถ้าคะแนนสะสม ≥ 70% ได้ 7 คะแนนท้ายเทอม
   3. ถ้าคะแนนสะสม ≥ 40% ได้ 4 คะแนนท้ายเทอม    

ทุกครั้งที่เช็คชื่อ ระบบจะคำนวณคะแนนพิเศษให้อัตโนมัติ
อาจารย์สามารถดูผลได้ในหน้ารายละเอียดรายวิชา และใช้จริงตอนสิ้นเทอม

5. เลือกตำแหน่งของห้องเรียน และคลิกตกลง เป็นอันเสร็จสิ้น""",
                        //  ข้อความคู่มือหลัก (แบบ multi-line string """...""")

                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 16), 
                      //  เว้นระยะห่างก่อนหมายเหตุ

                      Text(
                        "หมายเหตุ:หลังจากสร้างห้องเสร็จสิ้นกรุณาตั้งค่าเวลาการเเจ้งเตือน\nระดับสีเขียวคือก่อนถึงเวลาเรียน\nระดับสีแดงคือ เลยเวลาเรียน",
                        //  ข้อความหมายเหตุ (สีแดง)

                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16), 
            //  เว้นช่องว่างก่อนปุ่มปิด

            //  ปุ่มปิด dialog
            Align(
              alignment: Alignment.centerRight, 
              //  จัดปุ่มไว้ด้านขวาล่าง

              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), 
                //  กดแล้วปิด dialog (pop ออกจาก navigation stack)

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  //  ปุ่มพื้นหลังสีดำ

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                    //  มุมปุ่มโค้ง
                  ),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  //  padding ในปุ่ม (ซ้ายขวา 20, บนล่าง 12)
                ),

                child: const Text(
                  "ปิด",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
