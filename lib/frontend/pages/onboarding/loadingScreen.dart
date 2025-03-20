import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget{
  const LoadingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 41, 41, 41),
        body: Column(
          children: [
            SizedBox(height: 350,),
            Padding(
              padding: EdgeInsets.only(left: 50),
              child: Text(
                "Reading your mind...",
                 style: TextStyle(
                          fontFamily: "HammersmithOne", 
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Colors.white,
                          ),
                  textAlign: TextAlign.center,
                  ),
            ),
          ],
        )
        ),
    );
  }

}
