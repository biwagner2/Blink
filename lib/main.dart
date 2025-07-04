// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:blink/frontend/pages/onboarding/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async { //Link supabase to the project

  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
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
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}