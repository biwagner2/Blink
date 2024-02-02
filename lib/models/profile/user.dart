import 'package:blink_v1/models/profile/BioPicture.dart';

class User {
  
  int id; //Unique to each user
  String firstName;
  String lastName;
  String emailAddress;
  String password;

  // BioPicture bioPicture; 
  // String bio;
  // List<String> friendsList;
  // List<String> personalityTraits;
  // List<String> pastChoices;
  // List<String> preferences;
  // List<String> savedList;

  User({required this.id, required this.firstName, required this.lastName, required this.emailAddress, required this.password, })
  {
    this.firstName = firstName;
    this.lastName = lastName;
    this.emailAddress = emailAddress;
    this.password = password;
  }



}