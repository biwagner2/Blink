import 'package:flutter/material.dart';

class IntroScreen2 extends StatelessWidget{
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/Double Blink.png")
        ],
      )
    );
  }
}