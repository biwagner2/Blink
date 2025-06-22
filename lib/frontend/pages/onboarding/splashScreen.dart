import 'dart:async';
import 'package:blink/frontend/pages/onboarding/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/onboarding/intro_screens/introScreens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool introSeen = prefs.getBool('intro_seen') ?? false;

    final user = Supabase.instance.client.auth.currentUser;
    final bool isSignedIn = user != null;

    Widget destination;

    if (!introSeen) {
      destination = IntroScreens(); // first-time user
    } else if (isSignedIn) {
      destination = const CategoriesPage(); // returning user
    } else {
      destination = const LoginScreen(); // seen intro, but not signed in
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
            return FadeTransition(opacity: fadeAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 183, 236, 236),
      ),
    );
  }
}
