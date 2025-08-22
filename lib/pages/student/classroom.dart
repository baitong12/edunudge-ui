import 'package:flutter/material.dart';
import 'package:edunudge/pages/student/custombottomnav.dart';
import 'package:edunudge/pages/student/subject.dart'; 

class Classroom extends StatelessWidget {
  const Classroom({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ตัวอย่างห้องเรียน
    final classrooms = List.generate(8, (index) => {
          'subject': 'วิชา ${index + 1} : ชื่อวิชาตัวอย่าง',
          'room': 'ห้อง ${100 + index}',
          'teacher': 'อาจารย์ผู้สอน ${index + 1} ชื่อครูผู้สอน',
        });

    
    final cardColors = [
      const Color(0xFF1de9b6), 
      const Color(0xFFe040fb), 
      const Color(0xFFff4081), 
      const Color(0xFFffab40), 
      const Color(0xFF2979ff), 
      const Color(0xFF7c4dff), 
      const Color(0xFF00c853), 
      const Color(0xFFff1744), 
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, 
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
          body: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.05, 
              left: screenWidth * 0.04, 
              right: screenWidth * 0.04, 
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ห้องเรียน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.07, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), 
                Expanded(
                  child: ListView.builder(
                    itemCount: classrooms.length,
                    itemBuilder: (context, index) {
                      final classroom = classrooms[index];
                      final cardColor = cardColors[index % cardColors.length];

                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02), 
                        child: InkWell(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05), 
                          onTap: () {
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Subject(
                                  subject: classroom['subject'] ?? '',
                                  room: classroom['room'] ?? '',
                                  teacher: classroom['teacher'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(screenWidth * 0.05), 
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5, 
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.04), 
                                  child: Row(
                                    children: [
                                      Icon(Icons.class_,
                                          color: Colors.white,
                                          size: screenWidth * 0.07), 
                                      SizedBox(width: screenWidth * 0.03), 
                                      Expanded(
                                        child: Text(
                                          classroom['subject']!,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.05, 
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04), 
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.meeting_room,
                                              size: screenWidth * 0.05, 
                                              color: Colors.white),
                                          SizedBox(width: screenWidth * 0.02), 
                                          Text(
                                            classroom['room']!,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04, 
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.008), 
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              size: screenWidth * 0.05, 
                                              color: Colors.white),
                                          SizedBox(width: screenWidth * 0.02), 
                                          Expanded(
                                            child: Text(
                                              classroom['teacher']!,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.037, 
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNav(currentIndex: 2, context: context),
        ),
      ),
    );
  }
}
