import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MovieInputPage extends StatefulWidget {
  const MovieInputPage({super.key});

  @override
  _MovieInputPageState createState() => _MovieInputPageState();
}

class _MovieInputPageState extends State<MovieInputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Enter your choices. We’ll pick one that’s data-driven by you.',
          softWrap: true,
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