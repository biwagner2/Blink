import 'dart:async';
import 'package:blink_v1/frontend/pages/decision_making/category_selection.dart';
import 'package:blink_v1/frontend/pages/onboarding/intro_screens/introScreens.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
{
    bool signedIn = false; //need to make it so that if a user is signed in on device 
                           //they are taken to Categories Page.

   @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                signedIn ? const CategoriesPage() : IntroScreens(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;

              var tween = Tween(begin: begin, end: end);

              var fadeAnimation = tween.animate(animation);

              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }

    @override
    Widget build(BuildContext context)
    {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo-white-transparent.png',
                    width: 250, height: 250),
                const SizedBox(height: 20),
                // Text('Blink'),
              ],
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 183, 236, 236),
        ),
      );
    }
}




