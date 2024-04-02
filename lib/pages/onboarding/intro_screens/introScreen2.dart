import 'package:flutter/material.dart';

class IntroScreen2 extends StatelessWidget{
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: 
        [
          const SizedBox(height: 100,),
          Image.asset("assets/images/Double Blink.png",height: 500, width: 500,),
          const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              "Data-backed recommendations.",
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
              "Each decision you make informs the next.",
              style: TextStyle(
                      fontFamily: "OpenSans",
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
              ),
          ),
        ]
          ),
    );
  }
}