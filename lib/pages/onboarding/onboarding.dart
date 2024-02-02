import 'dart:async';
import 'package:blink_v1/pages/onboarding/signup.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the login screen after a delay
    Timer(
      Duration(seconds: 2), // Adjust the duration as needed
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your company logo goes here
            Image.asset('assets/images/logo-white-transparent.png',
                width: 250, height: 250),
            SizedBox(height: 20),
            // Text('Blink'),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 183, 236, 236),
    );
  }
}