import 'package:blink_v1/pages/onboarding/intro_screens/introScreen1.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen2.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen3.dart';
import 'package:blink_v1/pages/onboarding/intro_screens/introScreen4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreens extends StatelessWidget{

  final _controller = PageController();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              children: [
                IntroScreen1(),
                IntroScreen2(),
                IntroScreen3(),
              ],
            ),
          ),
         Container(
          alignment: Alignment(0, 0.9),
          child: SmoothPageIndicator(
            controller: _controller, 
            count: 3, 
            effect: SlideEffect(
                activeDotColor: Colors.black,
                dotColor: Color.fromARGB(255, 168, 168, 168),
                spacing: 20.0,
                dotHeight: 10,
                dotWidth: 10,
              ),
              )),
        ],
      ),
    );
  }
}