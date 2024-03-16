import 'dart:async';

import 'package:blink_v1/pages/onboarding/question_screens/questionScreen1.dart';
import 'package:flutter/material.dart';

class transitionScreen2 extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
     // Use Timer to navigate after 5 seconds
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuestionScreen1()),
      );
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      body: Column(
        children: [
          SizedBox(height: 432,),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              "I see myself as someone who...",
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
      );
  }
}