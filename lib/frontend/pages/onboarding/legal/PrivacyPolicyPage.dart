import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget{
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
          automaticallyImplyLeading: true,
        ),
        body: const Center(
          child: Text('Privacy Policy'),
        ),
      ),
    );
  }
}