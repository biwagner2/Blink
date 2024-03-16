import 'package:flutter/material.dart';


class QuestionScreen1 extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 60,),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "1/10",
                 style: TextStyle(
                          fontFamily: "OpenSans", 
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Colors.white,
                          ),
                  textAlign: TextAlign.center,
                  ),
            ),
            SizedBox(height: 250,),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "...is reserved",
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
        ),
      )
      );
  }
}