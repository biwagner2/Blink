import 'package:blink_v1/models/onboarding/onboardingQuestion.dart';
import 'package:blink_v1/frontend/pages/onboarding/question_screens/questionScreen6.dart';
import 'package:flutter/material.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';


class QuestionScreen5 extends StatelessWidget
{
  const QuestionScreen5({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context)
  {
    String pageNum = "5";
    int index = int.parse(pageNum);
    String question = OnboardingQuestion.questions[index-1];
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 41, 41, 41),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60,),
             Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "$pageNum/10",
                 style: const TextStyle(
                          fontFamily: "OpenSans", 
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Colors.white,
                          ),
                  textAlign: TextAlign.center,
                  ),
            ),
            const SizedBox(height: 250,),
            Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Text(
                          question,
                          style: const TextStyle(
                            fontFamily: "HammersmithOne",
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
            const SizedBox(height: 35), // Adjust as needed
            Slider(
              value: 0.5, // Default value for the slider
              onChanged: (double value) {
                // Implement onChanged callback
              },
              min: 0,
              max: 10,
              divisions: 4, // Adjust divisions as needed
             // label: 'Value',
              activeColor: const Color.fromARGB(255, 183, 236, 236), // Change the color as needed
              inactiveColor: Colors.grey, // Change the color as needed
            ),
           const SizedBox(height: 100), // Adjust as needed
           
            ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuestionScreen6()),
                );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 183, 236, 236)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                       RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(50),
                        ),
            ),
            minimumSize: MaterialStateProperty.all(const Size(235, 50)), // Set minimum width
          ), 
            child: const Text(
              "Next",
              style: TextStyle(
                      fontFamily: "OpenSans-Bold",
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black, 
              ),
            ),
          )
          ],
        ),
      ),
    );
  }
}