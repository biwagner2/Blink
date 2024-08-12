import 'package:flutter/material.dart';

class LabeledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final double buttonSize;
  final double iconSize;

  const LabeledIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.buttonSize = 45, // Default size, adjust as needed
    this.iconSize = 30, // Default icon size, adjust as needed
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints.tightFor(
            width: buttonSize,
            height: buttonSize,
          ),
          child: FloatingActionButton(
            heroTag: label,
            onPressed: onPressed,
            backgroundColor: const Color.fromARGB(255, 183, 236, 236),
            elevation: 1,
            shape: const CircleBorder(),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
        SizedBox(height: screenHeight / 200),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }
}