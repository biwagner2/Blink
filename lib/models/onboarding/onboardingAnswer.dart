class OnboardingAnswer{
  int questionId;
  String response;
  late int userId;
  
  // Constructor for setting questionId and answer during object creation
  OnboardingAnswer({required this.questionId, required this.response});

  // Additional constructor for setting userId later
  OnboardingAnswer.withUserId(int userId, {required this.questionId, required this.response}) 
  {
    this.userId = userId;
  }
}