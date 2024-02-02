
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/onboarding/login.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 41, 41, 41),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 41, 41),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the login page when the "Log in" text is tapped
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                'Log in',
                style: TextStyle(
                  color: Color.fromARGB(255, 183, 236, 236),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            // Header
            Text(
              'Create an account',
              style: TextStyle(
                color: Color.fromARGB(255, 183, 236, 236),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            SizedBox(height: 18),
            // Input bars
            SignUpInput(label: 'First Name'),
            SizedBox(height: 25),
            SignUpInput(label: 'Last Name'),
            SizedBox(height: 25),
            SignUpInput(label: 'Email Address'),
            SizedBox(height: 25),
            SignUpInput(label: 'Password (8+ characters)', isPassword: true),
            SizedBox(height: 20),
            // Continue button
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle continue button press and navigate to Category Selection screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CategoriesPage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 105),
                    child: Text('Continue',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 183, 236, 236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // "Or" Spacer
            Text('or',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(height: 10),
            // Other sign-up methods
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // TODO: Add icons for Apple, Facebook, and Google sign-up methods
                // Example: Icon(Icons.apple), Icon(Icons.facebook), Icon(Icons.google),
                 // Icon for Apple sign-up
          Icon(
            FontAwesomeIcons.apple,
            color: Colors.white,
            size: 30.0,
          ),

          // Icon for Facebook sign-up
          Icon(
            FontAwesomeIcons.facebook,
            color: Colors.white,
            size: 30.0,
          ),

          // Icon for Google sign-up
          Icon(
            FontAwesomeIcons.google,
            color: Colors.white,
            size: 30.0,
          ),
              ],
            ),
            SizedBox(height: 20),
            // Terms & Conditions and Privacy Policy
            Text(
              'By continuing, you agree to Blink’s ',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).primaryColor),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    // TODO: Add link handling for "Terms & Conditions"
                    // recognizer: ..., // TapGestureRecognizer for handling the link
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    // TODO: Add link handling for "Privacy Policy"
                    // recognizer: ..., // TapGestureRecognizer for handling the link
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpInput extends StatelessWidget {
  final String label;
  final bool isPassword;

  SignUpInput({required this.label, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color.fromARGB(255, 183, 236, 236),
          fontSize: 18,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 18,
      ),
    );
  }
}

