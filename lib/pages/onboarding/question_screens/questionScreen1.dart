import 'package:blink_v1/models/onboarding/onboardingQuestion.dart';
import 'package:blink_v1/pages/onboarding/question_screens/questionScreen2.dart';
import 'package:flutter/material.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';


class QuestionScreen1 extends StatefulWidget
{
  const QuestionScreen1({Key? key}) : super(key: key);
  
  @override
  _QuestionScreen1State createState() => _QuestionScreen1State();
}

 class _QuestionScreen1State extends State<QuestionScreen1> 
 {
    double sliderValue = 5; //Initial slider value...

    @override
    Widget build(BuildContext context)
    {
      String pageNum = "1";
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
              const SizedBox(height: 290,),
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
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 10,
                    thumbColor:  Colors.white, //Circle nob
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 13.5),
                    inactiveTrackColor: Color.fromARGB(255, 79, 79, 79),
                    activeTrackColor: Color.fromARGB(255, 183, 236, 236),
                    inactiveTickMarkColor: Color.fromARGB(255, 126, 126, 126),
                    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 8),
                    activeTickMarkColor: Colors.transparent, //All ticks to left of current tick.
                    overlayColor: Color.fromARGB(255, 183, 236, 236), //Outer circle
                  ),
                  child: Slider(
                    value: sliderValue,
                    onChanged: (double value) {
                      // Implement onChanged callback
                      setState(() {
                        sliderValue = value;
                      });
                    },
                    min: 0,
                    max: 10,
                    divisions: 4, // Adjust divisions as needed
                  // label: 'Value',
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Text("Disagree\nstrongly",
                    style: TextStyle(
                              fontFamily: "HammersmithOne",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 70,),
                    Text("Neither agree\nnor disagree",
                    style: TextStyle(
                              fontFamily: "HammersmithOne",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              color: Colors.white,),
                              textAlign: TextAlign.center,
                      ),
                    SizedBox(width: 60,),
                    Text("Agree\nstrongly",
                    style:  TextStyle(
                              fontFamily: "HammersmithOne",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              color: Colors.white,),
                              textAlign: TextAlign.center,
                    ),
                  ],
                ),
              
              ),
            const SizedBox(height: 100), // Adjust as needed
            
              ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionScreen2()),
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