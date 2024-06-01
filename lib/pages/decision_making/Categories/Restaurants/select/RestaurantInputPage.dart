import 'package:flutter/material.dart';

class RestaurantInputPage extends StatefulWidget {
  const RestaurantInputPage({super.key});

  @override
  _RestaurantInputPageState createState() => _RestaurantInputPageState();
}

class _RestaurantInputPageState extends State<RestaurantInputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your choices. We’ll pick one that’s data-driven by you.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'HammerSmithOne-Regular',
          ),
          textAlign: TextAlign.center,
        ),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(
              'Coming Soon',
            ),
          ],
        ),
      ),
    );
  }
}