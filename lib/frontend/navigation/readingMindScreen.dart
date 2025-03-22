import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

// Import all category models
import 'package:blink/models/categories/Restaurant.dart';
import 'package:blink/models/categories/Movie.dart';

// Import all suggestion pages
import 'package:blink/frontend/pages/decision_making/categories/Restaurants/suggest/RestaurantSuggestionsPage.dart';
import 'package:blink/frontend/pages/decision_making/categories/Movies/suggest/MovieSuggestionsPage.dart';

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
  bool _isError = false;
  String _errorMessage = '';

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
    try {
      List<T>? items = await widget.recommendations.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );
      
      if (items == null || items.isEmpty) {
        setState(() {
          _isError = true;
          _errorMessage = 'No results found for your criteria. Try adjusting your filters.';
        });
        return;
      }
      
      if (widget.processRecommendations != null) {
        await widget.processRecommendations!(items, widget.userLocation);
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => _buildSuggestionsPage(items),
          ),
        );
      }
    } catch (e) {
      print('Error processing recommendations: $e');
      setState(() {
        _isError = true;
        _errorMessage = 'Something went wrong: ${e.toString().split('\n')[0]}';
      });
    }
  }

  Widget _buildSuggestionsPage(List<T> items) {
    switch (widget.category) {
      case 'Restaurants':
        return RestaurantSuggestionsPage(recommendations: items as List<Restaurant>);
      case 'Movies':
        return MovieSuggestionsPage(recommendations: items as List<Movie>);
      case 'Shows':
        return MovieSuggestionsPage(recommendations: items as List<Movie>);
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
            if (_isError) ...[
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    fontFamily: "HammersmithOne",
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    "Go Back",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ] else ...[
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
          ],
        ),
      ),
    );
  }
}