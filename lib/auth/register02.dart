import 'package:flutter/material.dart';

class Register02 extends StatefulWidget {
  @override
  State<Register02> createState() => _Register02State();
}

class _Register02State extends State<Register02> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF221B64),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ลงทะเบียน',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black38)
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('สาขาวิชา'),
              _buildDropdown(),
              SizedBox(height: 20),
              _buildRegisterButton(context),
              SizedBox(height: 10),
              _buildButton(context, 'ยกเลิก', Color.fromARGB(255, 255, 255, 255), Colors.black, '/login', isOutlined: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: ['นักศึกษา', 'อาจารย์'].map((String category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
          hint: Text('สถานะ', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 25, 120, 197),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (_selectedRole == 'นักศึกษา') {
            Navigator.pushNamed(context, '/home_student');
          } else if (_selectedRole == 'อาจารย์') {
            Navigator.pushNamed(context, '/home_teacher');
          }
        },
        child: Text('ลงทะเบียน', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor, String route, {bool isOutlined = false}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: bgColor,
                side: BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pushNamed(context, route),
              child: Text(text, style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pushNamed(context, route),
              child: Text(text, style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold)),
            ),
    );
  }
}
