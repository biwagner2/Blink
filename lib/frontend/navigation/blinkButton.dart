import 'package:flutter/material.dart';

class BlinkButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isEnlarged;

  const BlinkButton({
    super.key,
    required this.onTap,
    required this.isEnlarged,
  });

  @override
  _BlinkButtonState createState() => _BlinkButtonState();
}

class _BlinkButtonState extends State<BlinkButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(_animationController);

    if (widget.isEnlarged) {
      _animationController.repeat(reverse: true);
    }
  }

   @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 20, bottom: 0),
            child: Transform.scale(
              scale: widget.isEnlarged ? _animation.value : 1.0,
              child: Image.asset(
                "assets/images/blink-icon-color.png",
                height: widget.isEnlarged ? 100 : 40,
              ),
            ),
          );
        },
      ),
    );
  }
}