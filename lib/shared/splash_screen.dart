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
            colors: [Color(0xFF00B894),  Color(0xFF91C8E4),],
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
