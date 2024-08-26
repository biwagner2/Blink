import 'package:blink_v1/models/categories/Restaurant.dart';
import 'package:blink_v1/pages/decision_making/Categories/Restaurants/suggest/RestaurantSuggestionsPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';

class ReadingMindScreen extends StatefulWidget {
  final Future<List<Restaurant>?> recommendations;
  final Position userLocation;

  const ReadingMindScreen({
    super.key, 
    required this.recommendations,
    required this.userLocation,
  });

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

    _processRecommendations();
  }

  Future<void> _processRecommendations() async {
    List<Restaurant>? restaurants = await widget.recommendations;
    if (restaurants != null) {
      // Calculate ETAs for all restaurants
      await Future.wait(restaurants.map((restaurant) => 
        restaurant.calculateAndCacheEta(widget.userLocation)
      ));
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => RestaurantSuggestionsPage(recommendations: restaurants ?? []),
        ),
      );
    }
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