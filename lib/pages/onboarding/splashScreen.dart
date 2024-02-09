import 'dart:async';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen1.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen2.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen3.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen4.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreens.dart';
import 'package:blink_v1/pages/onboarding/signup.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
{
    bool signedIn = false;

    @override
    void initState() 
    {
      super.initState();
      // Navigate to the intro screen or Categories screen after a delay
      Timer(
        Duration(seconds: 2), // Adjust the duration as needed
        () {
          Navigator.pushReplacement(
            context,
            signedIn 
            ?
            MaterialPageRoute(builder: (context) => CategoriesPage()) 
            :
            MaterialPageRoute(builder: (context) => IntroScreens()));
        },
      );
    }

    @override
    Widget build(BuildContext context)
    {
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




