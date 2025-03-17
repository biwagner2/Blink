import 'dart:async';

import 'package:blink/frontend/pages/onboarding/transition_screens/transition_screen2.dart';
import 'package:flutter/material.dart';

class transitionScreen1 extends StatelessWidget{
  const transitionScreen1({super.key});

  @override
  Widget build(BuildContext context)
  {
    // Use Timer to navigate after 5 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const transitionScreen2()),
      );
    });

    return const PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 41, 41, 41),
        body: Column(
          children: [
            SizedBox(height: 390,),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "How well do the following statements describe your personality?",
                 style: TextStyle(
                          fontFamily: "HammersmithOne", 
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Colors.white,
                          ),
                  textAlign: TextAlign.center,
                  ),
            ),
          ],
        )
        ),
    );
  }
}