// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:blink_v1/pages/decision_making/Categories/Restaurants/RestaurantCuisineSurvey.dart';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/onboarding/question_screens/questionScreen1.dart';
import 'package:blink_v1/pages/onboarding/question_screens/questionScreen4.dart';
import 'package:blink_v1/pages/onboarding/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

Future<void> main() async { //Link supabase to the project

 await dotenv.load(fileName: "/Users/brianwagner/Desktop/Blink/blink_v1/.env"); // Load the .env file first
  WidgetsFlutterBinding.ensureInitialized();
  
  final supaApiKey = dotenv.env['SUPABASE_API_KEY'];

  await Supabase.initialize(
    url: 'https://yzjlrtmwaexnidnzkwjs.supabase.co',
    anonKey: "$supaApiKey");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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