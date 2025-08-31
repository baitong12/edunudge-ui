import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // เขียว
              Color(0xFF009688), // teal
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'images/logo_notname.png',
            width: 300,
          ),
        ),
      ),
    );
  }
}
