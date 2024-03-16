import 'package:blink_v1/pages/onboarding/question_screens/transition_screen1.dart';
import 'package:flutter/material.dart';

class IntroScreen4 extends StatelessWidget{
  const IntroScreen4({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      body: Column(
        children: [
          SizedBox(height: 160,),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              "What kind of decision-maker are you?",
               style: TextStyle(
                        fontFamily: "HammersmithOne", 
                        fontSize: 38,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: Colors.white,
                        ),
                textAlign: TextAlign.center,
                ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 18),
            child: Text(
              "Answer a few questions to help us better inform your decision results.",
              style: TextStyle(
                      fontFamily: "OpenSans",
                      fontSize: 28,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      height: 1.05,
                      ),
              textAlign: TextAlign.center,
              ),
          ),

          SizedBox(height: 40),

          Padding(
            padding: EdgeInsets.only(left: 20, right: 40),
            child: Container(
              //color: Colors.blue,
             // padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset("assets/images/blink-icon-color.png",height: 50, width: 50,),
                  SizedBox(width: 20,),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Traits change",
                          style: TextStyle(
                            fontFamily: "OpenSans",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        Text(
                          "Your traits change as you make more decisions.",
                          style: TextStyle(
                            fontFamily: "OpenSans",
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 20,),

          Padding(
            padding: EdgeInsets.only(left: 20, right: 40),
            child: Container(
              //color: Colors.blue,
             // padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset("assets/images/blink-icon-color.png",height: 50, width: 50,),
                  SizedBox(width: 20,),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Inform future decisions",
                          style: TextStyle(
                            fontFamily: "OpenSans",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        Text(
                          "We’ll use your decision personality, friends’ decisions, and categorical data to make the best choices for you.",
                          style: TextStyle(
                            fontFamily: "OpenSans",
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

        SizedBox(height: 70,),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => transitionScreen1()),
                );
            }, 
            child: Text(
              "Continue",
              style: TextStyle(
                      fontFamily: "OpenSans-Bold",
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black, 
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 183, 236, 236)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                       RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(50),
                        ),
            ),
            minimumSize: MaterialStateProperty.all(Size(365, 50)), // Set minimum width
          ),
          )
        ],
      ),
      );
  }
}