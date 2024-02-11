import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your login screen here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in'),
      ),
      body: const Center(
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