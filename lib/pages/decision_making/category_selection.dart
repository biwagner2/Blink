import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget
{
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: Center(
        child: Text('Categories Page'),
      ),
    );
  }
}