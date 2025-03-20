import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: onTap,
          items: items,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              final index = items.indexOf(item);
              return Expanded(
                child: Container(
                  height: 2,
                  alignment: Alignment.center,
                  child: Container(
                    width: 30, // Adjust the width of the black line
                    height: 2,
                    color: selectedIndex == index ? Colors.black : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}