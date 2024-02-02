// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:blink_v1/pages/onboarding/onboarding.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blink',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 183, 236, 236)),
        //scaffoldBackgroundColor: Color.fromARGB(255, 183, 236, 236),
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}