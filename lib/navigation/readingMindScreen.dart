import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

// Import all category models
import 'package:blink_v1/models/categories/Restaurant.dart';
import 'package:blink_v1/models/categories/Movie.dart';
// import 'package:blink_v1/models/categories/Recipe.dart';
// import 'package:blink_v1/models/categories/Book.dart';
// import 'package:blink_v1/models/categories/Outfit.dart';
// import 'package:blink_v1/models/categories/College.dart';

// Import all suggestion pages
import 'package:blink_v1/pages/decision_making/Categories/Restaurants/suggest/RestaurantSuggestionsPage.dart';
import 'package:blink_v1/pages/decision_making/Categories/Movies/suggest/MovieSuggestionsPage.dart';
// import 'package:blink_v1/pages/decision_making/Categories/Recipes/suggest/RecipeSuggestionsPage.dart';
// import 'package:blink_v1/pages/decision_making/Categories/Books/suggest/BookSuggestionsPage.dart';
// import 'package:blink_v1/pages/decision_making/Categories/Outfits/suggest/OutfitSuggestionsPage.dart';
// import 'package:blink_v1/pages/decision_making/Categories/Colleges/suggest/CollegeSuggestionsPage.dart';

class ReadingMindScreen<T> extends StatefulWidget {
  final Future<List<T>?> recommendations;
  final Position? userLocation;
  final String category;
  final Future<void> Function(List<T>, Position?)? processRecommendations;

  const ReadingMindScreen({
    super.key, 
    required this.recommendations,
    this.userLocation,
    required this.category,
    this.processRecommendations,
  });

  @override
  _ReadingMindScreenState<T> createState() => _ReadingMindScreenState<T>();
}

class _ReadingMindScreenState<T> extends State<ReadingMindScreen<T>> with SingleTickerProviderStateMixin {
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
    List<T>? items = await widget.recommendations;
    if (items != null && widget.processRecommendations != null) {
      await widget.processRecommendations!(items, widget.userLocation);
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => _buildSuggestionsPage(items ?? []),
        ),
      );
    }
  }

  Widget _buildSuggestionsPage(List<T> items) {
    switch (widget.category) {
      case 'Restaurants':
        return RestaurantSuggestionsPage(recommendations: items as List<Restaurant>);
      case 'Movies':
        return MovieSuggestionsPage(recommendations: items as List<Movie>);
      case 'Recipes':
       // return RecipeSuggestionsPage(recommendations: items as List<Recipe>);
      case 'Books':
       // return BookSuggestionsPage(recommendations: items as List<Book>);
      case 'Outfits':
       // return OutfitSuggestionsPage(recommendations: items as List<Outfit>);
      case 'Colleges':
       // return CollegeSuggestionsPage(recommendations: items as List<College>);
      default:
        throw Exception('Unknown category: ${widget.category}');
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