// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:blink_v1/pages/decision_making/Categories/Restaurants/RestaurantCuisineSurvey.dart';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/onboarding/question_screens/questionScreen1.dart';
import 'package:blink_v1/pages/onboarding/question_screens/questionScreen4.dart';
import 'package:blink_v1/pages/onboarding/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';


Future<void> main() async { //Link supabase to the project
  
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://yzjlrtmwaexnidnzkwjs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6amxydG13YWV4bmlkbnprd2pzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDY5MTA2NTAsImV4cCI6MjAyMjQ4NjY1MH0.Y7dy6Ba6_TwWglxid-fYsrlcO4fEDBqsS0DGPonGWUc',
  );

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