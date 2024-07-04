import 'package:blink_v1/pages/decision_making/Categories/Restaurants/suggest/RestaurantSuggestionsPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ReadingMindScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recommendations;

  const ReadingMindScreen({super.key, required this.recommendations});

  @override
  _ReadingMindScreenState createState() => _ReadingMindScreenState();
}

class _ReadingMindScreenState extends State<ReadingMindScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => RestaurantSuggestionsPage(recommendations: widget.recommendations),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Reading your mind...",
              style: TextStyle(
                fontFamily: "HammersmithOne",
                fontSize: 36,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            RotationTransition(
              turns: _controller,
              child: Image.asset(
                "assets/images/blink-icon-color.png",
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}