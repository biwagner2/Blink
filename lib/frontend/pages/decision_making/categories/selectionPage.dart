import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class SelectionPage extends StatefulWidget {
  final String selectionName;

  const SelectionPage(this.selectionName, {super.key});

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();

    final player = AudioPlayer();
    player.play(AssetSource('sounds/orchestra-triumphant-trumpets-2285.wav'));

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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 40,
                maxBlastForce: 30,
                minBlastForce: 10,
                emissionFrequency: .05,
                gravity: 0.2,
                colors: [
                  Color.fromARGB(255, 72, 103, 131), 
                  Color.fromARGB(255, 235, 250, 250), 
                  Color.fromARGB(255, 109, 131, 242), 
                  Color.fromARGB(255, 134, 217, 247), 
                  Color.fromARGB(255, 145, 166, 166), 
                  Color.fromARGB(255, 140, 157, 157), 
                ],
                maximumSize: Size(15, 15),
                minimumSize: Size(15, 15),
                createParticlePath: (size) {
                  final shapePicker = Random().nextInt(3);
                  switch (shapePicker) {
                    case 0:
                      return drawStar(size);
                    case 1:
                      return drawTriangle(size);
                    case 2:
                    default:
                      return drawCircle(size);
                  }
                }
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.selectionName,
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
          ]
        ),
        backgroundColor: const Color.fromARGB(255, 183, 236, 236),
      ),
    );
  }
}

Path drawStar(Size size) {
  // Star shape
  const int numPoints = 5;
  final Path path = Path();
  final double halfWidth = size.width / 2;
  final double externalRadius = halfWidth;
  final double internalRadius = halfWidth / 2.5;
  final angle = pi / numPoints;

  for (int i = 0; i < numPoints * 2; i++) {
    final isEven = i % 2 == 0;
    final radius = isEven ? externalRadius : internalRadius;
    final x = halfWidth + radius * cos(i * angle);
    final y = halfWidth + radius * sin(i * angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

Path drawTriangle(Size size) {
  return Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

Path drawCircle(Size size) {
  return Path()..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
}