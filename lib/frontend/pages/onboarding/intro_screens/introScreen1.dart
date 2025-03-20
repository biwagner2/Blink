//Make custom svg files for the triple blink circle and the double blink circle images.
//Then just use a simple List view or stack to display the images with text underneath.

import 'package:flutter/material.dart';

class IntroScreen1 extends StatelessWidget{
  const IntroScreen1({super.key});

  @override
  Widget build(BuildContext context)
  {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white, 
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: 
          [
            const SizedBox(height: 60,),
            Image.asset("assets/images/Triple Blink.png",height: 500, width: 500,),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "Make decisions that matter.",
                 style: TextStyle(
                          fontFamily: "HammersmithOne", 
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          height: 1.2),
                  textAlign: TextAlign.center,
                  ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 18),
              child: Text(
                "Blink is an app that simplifies your everyday decision-making so that you can focus on the time you get back.",
                style: TextStyle(
                        fontFamily: "OpenSans",
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
                ),
            ),
          ]
            ),
      ),
    );
  }
}