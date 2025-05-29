import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LabeledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final String label;
  final double buttonSize;
  final double iconSize;
  final String? svgAsset; // Optional SVG asset path


  const LabeledIconButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.svgAsset,
    required this.label,
    this.buttonSize = 50, // Default size, adjust as needed
    this.iconSize = 32, // Default icon size, adjust as needed
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
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset!,
                    width: iconSize,
                    height: iconSize,
                    color: Colors.white, 
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: iconSize,
                  ),
          ),
        ),
        SizedBox(height: screenHeight / 200),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ],
    );
  }
}