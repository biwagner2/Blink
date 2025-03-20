import 'dart:async';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:flutter/material.dart';

class SelectionPage extends StatefulWidget {
  final String restaurantName;

  const SelectionPage(this.restaurantName, {super.key});

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CategoriesPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              var tween = Tween(begin: begin, end: end);
              var fadeAnimation = tween.animate(animation);
              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.restaurantName,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Decision made. We're proud of you.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'OpenSans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 183, 236, 236),
      ),
    );
  }
}