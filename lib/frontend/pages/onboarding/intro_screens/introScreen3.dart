import 'package:blink/frontend/pages/onboarding/intro_screens/introScreen4.dart';
import 'package:blink/frontend/pages/onboarding/signup.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen3 extends StatelessWidget{
  const IntroScreen3({super.key});

  @override
  Widget build(BuildContext context)
  {
    return  PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 200,),
            const Padding(
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
            const Padding(
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
            const SizedBox(height: 50,),
            Transform.scale(
              scale: 3.0, // Adjust the scale factor for zoom level
              child: Lottie.asset('assets/icons/Bouncing-Arrow.json', height: 100, width: 100,),
            ),
            const SizedBox(height: 40,),
            GestureDetector(
              child: Image.asset("assets/images/blink-icon-color.png",height: 220, width: 220, fit: BoxFit.cover,),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('intro_seen', true); // mark intro complete

                if (!context.mounted) return;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SignUp(),
                    transitionDuration: const Duration(milliseconds: 600),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = 0.0;
                      const end = 1.0;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      var scaleAnimation = animation.drive(tween);

                      return ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}