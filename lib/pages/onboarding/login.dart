import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement your login screen here
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your login UI goes here
            Text('Login Screen Content'),
          ],
        ),
      ),
    );
  }
}