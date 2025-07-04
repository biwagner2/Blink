import 'dart:async';
import 'package:blink/backend/services/categories/Movies/TMDBMovieService.dart';
import 'package:blink/backend/services/utility/LocationService.dart';
import 'package:blink/frontend/pages/onboarding/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_directions_api/google_directions_api.dart';
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
  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();

  }

  Future<void> _navigateAfterSplash() async {

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showLoader = true;
        });
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final bool introSeen = prefs.getBool('intro_seen') ?? false;

    final supaApiKey = dotenv.env['SUPABASE_API_KEY'];
    final supaUrl = dotenv.env['SUPABASE_URL'];

    await Supabase.initialize(
      url: '$supaUrl',
      anonKey: "$supaApiKey",
    );

    await LocationService().initializeLocationServices();

    final googleApiKey = dotenv.env['GOOGLE_API_KEY'];
    DirectionsService.init(googleApiKey!);

    await TMDBMovieService().initializeGenreMap();
    await TMDBMovieService().loadOmdbCache();

    await Future.delayed(const Duration(milliseconds: 500));
    
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
              if (showLoader)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 183, 236, 236),
      ),
    );
  }
}
