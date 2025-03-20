import 'package:blink/frontend/pages/onboarding/intro_screens/introScreen1.dart';
import 'package:blink/frontend/pages/onboarding/intro_screens/introScreen2.dart';
import 'package:blink/frontend/pages/onboarding/intro_screens/introScreen3.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreens extends StatelessWidget{

  final _controller = PageController();

  IntroScreens({super.key});

  @override
  Widget build(BuildContext context)
  {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                children: const [
                  IntroScreen1(),
                  IntroScreen2(),
                  IntroScreen3(),
                ],
              ),
           Container(
            alignment: const Alignment(0, 0.9),
            child: SmoothPageIndicator(
              controller: _controller, 
              count: 3, 
              effect: const SlideEffect(
                  activeDotColor: Colors.black,
                  dotColor: Color.fromARGB(255, 168, 168, 168),
                  spacing: 20.0,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
                )),
          ],
        ),
      ),
    );
  }
}