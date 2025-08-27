import 'package:flutter/material.dart';
// Removed http and dart:convert imports as backend call is moved to Register02
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class Register01 extends StatefulWidget {
  @override
  _Register01State createState() => _Register01State();
}

class _Register01State extends State<Register01> {
  // Controllers to get text from TextFields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController = TextEditingController();

  // State variable for displaying client-side error messages
  String? _errorMessage; 

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  // Function to handle client-side validation and navigate to Register02
  void _navigateToRegister02() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    // Basic client-side validation for empty fields
    if (nameController.text.isEmpty || 
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmationController.text.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบทุกช่อง'; // Please fill in all fields
      });
      return;
    }

    // Client-side validation for password match
    if (passwordController.text != passwordConfirmationController.text) {
      setState(() {
        _errorMessage = 'รหัสผ่านไม่ตรงกัน'; // Passwords do not match
      });
      return; // Stop navigation
    }

    // Pass all collected data to Register02
    Navigator.pushNamed(
      context,
      '/register02',
      arguments: {
        'name': nameController.text,
        'lastname': lastnameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'password_confirmation': passwordConfirmationController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00C853),
              Color(0xFF00BCD4),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black38,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('ชื่อ', controller: nameController),
                  _buildTextField('นามสกุล', controller: lastnameController),
                  _buildTextField('อีเมล', controller: emailController, keyboardType: TextInputType.emailAddress),
                  _buildTextField('เบอร์โทรศัพท์', controller: phoneController, keyboardType: TextInputType.phone),
                  _buildTextField('รหัสผ่าน', obscureText: true, controller: passwordController),
                  _buildTextField('ยืนยันรหัสผ่าน', obscureText: true, controller: passwordConfirmationController),
                  const SizedBox(height: 20),
                  // Display error message if any
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      // Only navigate, actual registration happens in Register02
                      onPressed: _navigateToRegister02,
                      child: const Text(
                        'ถัดไป',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent TextFields
  Widget _buildTextField(String hint, {bool obscureText = false, TextEditingController? controller, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFF221B64), width: 2), // Highlight when focused
          ),
        ),
      ),
    );
  }
}
