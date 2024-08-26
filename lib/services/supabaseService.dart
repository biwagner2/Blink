import 'package:blink_v1/models/onboarding/onboardingAnswer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Get a reference your Supabase client
  final supabase = Supabase.instance.client;

  Future<void> storeUserOnboardingAnswer(OnboardingAnswer userAnswer) async
  {
    final response = await supabase.from('onboardingAnswers').insert(
      {
        'questionId' : userAnswer.questionId,
        'response' : userAnswer.response,
        'userId' : userAnswer.userId,
        });
  }

    Future<String> getUserId() async {
    final user = supabase.auth.currentUser;
    return user?.id ?? '';
  }

  Future<void> saveCuisinePreferences({required String userId, required List<String> cuisines,}) async 
  {
    await supabase.from('user_cuisine_preferences')
        .upsert({
          'user_id': userId,
          'cuisines': cuisines,
        });
  }

  
  }