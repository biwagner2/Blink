import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiRestaurantService {
  late final GenerativeModel _model;

  GeminiRestaurantService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<List<String>> getRestaurantRecommendations({
    List<String>? cuisines,
    String? occasion,
    String? pricing,
    String? distance,
    double? minRating,
    double? maxRating,
  }) async {
    final prompt = _buildPrompt(
      cuisines: cuisines,
      occasion: occasion,
      pricing: pricing,
      distance: distance,
      minRating: minRating,
      maxRating: maxRating,
    );

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response.text == null) {
      throw Exception('No recommendations generated');
    }

    // Parse the response and extract restaurant names
    final recommendations = response.text!.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(10)
        .toList();

    return recommendations;
  }

  String _buildPrompt({
    List<String>? cuisines,
    String? occasion,
    String? pricing,
    String? distance,
    double? minRating,
    double? maxRating,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Recommend 10 restaurants based on the following criteria:');

    if (cuisines != null && cuisines.isNotEmpty) {
      buffer.writeln('Cuisines: ${cuisines.join(", ")}');
    }
    if (occasion != null) buffer.writeln('Occasion: $occasion');
    if (pricing != null) buffer.writeln('Pricing: $pricing');
    if (distance != null) buffer.writeln('Distance: $distance');
    if (minRating != null && maxRating != null) {
      buffer.writeln('Rating range: $minRating - $maxRating');
    }

    buffer.writeln('Please provide a list of 10 restaurant names, one per line.');
    return buffer.toString();
  }

   Future<List<String>> getNearbyRestaurants() async {
    const prompt = 'Recommend 10 nearby restaurants. Please provide a list of 10 restaurant names, one per line.';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response.text == null) {
      throw Exception('No recommendations generated');
    }

    final recommendations = response.text!.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(10)
        .toList();

    return recommendations;
  }


}