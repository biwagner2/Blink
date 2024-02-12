import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroScreen3 extends StatelessWidget{
  const IntroScreen3({super.key});

  @override
  Widget build(BuildContext context)
  {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 200,),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              "Ready to own your options?",
               style: TextStyle(
                        fontFamily: "HammersmithOne", 
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        height: 1.2),
                textAlign: TextAlign.center,
                ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 18),
            child: Text(
              "All you got to do is blink it.",
              style: TextStyle(
                      fontFamily: "OpenSans",
                      fontSize: 26,
                      fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
              ),
          ),
          SizedBox(height: 50,),
          Transform.scale(
            scale: 3.0, // Adjust the scale factor for zoom level
            child: Lottie.asset('assets/icons/Bouncing-Arrow.json', height: 100, width: 100,),
          ),
          SizedBox(height: 30,),
          GestureDetector(
            child: Image.asset("assets/images/blink-icon-color.png",height: 250, width: 250,),
           // onTap: () => ,
          )
        ],
      ),
    );
  }
}