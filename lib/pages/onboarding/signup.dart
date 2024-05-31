import 'dart:async';

import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/onboarding/legal/PrivacyPolicyPage.dart';
import 'package:blink_v1/pages/onboarding/legal/TermsAndConditionsPage.dart';
import 'package:blink_v1/pages/onboarding/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

final supabase = Supabase.instance.client;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to the login page when the "Log in" text is tapped
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8,),
              // Header
              const Text(
                'Welcome Blinker!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 42,
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Get ready to simplify everyday decision-making and make the most of your moments.',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password (8+ characters)',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              
              const SizedBox(height: 10),
              // Continue button
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if(emailController.text.isEmpty || passwordController.text.isEmpty || firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                          ),
                        );
                        return;
                      }
                      if(passwordController.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password must be at least 8 characters long'),
                          ),
                        );
                        return;
                      }
                     
                      final sm = ScaffoldMessenger.of(context);
                      try{
                        
                        //Sign up new user
                        final authResponse = await supabase.auth.signUp(email: emailController.text, password: passwordController.text);
                        
                        // Update the user's display name
                        await supabase.auth.updateUser(
                          UserAttributes(
                            data: {
                              'display_name': '${firstNameController.text} ${lastNameController.text}',
                            },
                          ),
                        );
                         sm.showSnackBar(SnackBar(
                          content: Text("An email has been sent to ${authResponse.user!.email!}. Please verify your email."),
                        ));
                        print("Email Confirmed at: ${authResponse.user?.emailConfirmedAt}");
                        AlertDialog(
                              title: const Text('Email Confirmation'),
                              content: Text("An email has been sent to ${authResponse.user!.email!}. Please verify your email."),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
      
                         // Periodically check the user's email confirmation status
                        Timer.periodic(const Duration(seconds: 5), (timer) async {
                          final user = supabase.auth.currentUser;
                          if (user != null && user.emailConfirmedAt != null) {
                            timer.cancel();
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CategoriesPage()),
                            );
                          }
                        });
                      }
                      catch(e) {
                        print(e.toString());
                        if(e.toString().contains("User already registered"))
                        {
                          sm.showSnackBar(const SnackBar(
                          content: Text("Sign-up failed. An account with that email already exists.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                        ));
                        }
                        else{
                          sm.showSnackBar(const SnackBar(
                          content: Text("Sign-up failed. Please try again.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                        ));
                        }
                        return;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 105),
                      child: Text('Continue',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // "Or" Spacer
              const Text('or',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20)
              ),
              const SizedBox(height: 5),
              // Other sign-up methods
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   // Icon for Apple sign-up
                  Icon(
                    FontAwesomeIcons.apple,
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 30.0,
                  ),
      
                  // Icon for Facebook sign-up
                  Icon(
                    FontAwesomeIcons.facebook,
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 30.0,
                  ),
      
                  // Icon for Google sign-up
                  Icon(
                    FontAwesomeIcons.google,
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 30.0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to Blink\'s '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      recognizer: TapGestureRecognizer()
                      // Navigate to the Terms & Conditions page
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TermsAndConditionsPage()),
                          );
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to the Privacy Policy page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                          );
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}