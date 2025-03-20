// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

//import 'package:blink/pages/decision_making/Categories/Restaurants/RestaurantCuisineSurvey.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
//import 'package:blink/pages/onboarding/question_screens/questionScreen1.dart';
//import 'package:blink/pages/onboarding/question_screens/questionScreen4.dart';
//import 'package:blink/pages/onboarding/signup.dart';
import 'package:blink/frontend/pages/onboarding/splashScreen.dart';
import 'package:blink/backend/services/utility/LocationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

Future<void> main() async { //Link supabase to the project

  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  
  final supaApiKey = dotenv.env['SUPABASE_API_KEY'];
  final supaUrl = dotenv.env['SUPABASE_URL'];

  await Supabase.initialize(
    url: '$supaUrl',
    anonKey: "$supaApiKey");

  // Initialize location services
  final locationService = LocationService();
  await locationService.initializeLocationServices();

  final googleApiKey = dotenv.env['GOOGLE_API_KEY'];
  DirectionsService.init(googleApiKey!);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blink',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "HammersmithOne",
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 183, 236, 236)),
      ),
      home: CategoriesPage(), // Set SplashScreen as the initial screen
    );
  }
}