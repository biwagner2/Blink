import 'dart:convert';
import 'package:blink_v1/models/categories/Restaurant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class YelpRestaurantService {
  final String _apiKey;
  final String _baseUrl = dotenv.env['YELP_URL'] ?? '';
  Position? _userLocation;
  final Map<String, List<Restaurant>> _cache = {};

  YelpRestaurantService() : _apiKey = dotenv.env['YELP_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('YELP_API_KEY not found in .env file');
    }
  }

  void setUserLocation(Position location) {
    _userLocation = location;
  }

  Future<List<Restaurant>?> getRestaurantRecommendations({
  List<String>? cuisines,
  String? pricing,
  String? distance,
  double? rating,
  String? occasion,
}) async {
  if (_userLocation == null) {
    throw Exception('User location not set');
  }

  List<String> termCuisines = [];
  List<String> categoryCuisines = [];

  final specialCuisines = ['bakery', 'east asian', 'fast food', 'healthy', 'indian', 'sweet'];

  cuisines?.forEach((cuisine) {
    if (specialCuisines.contains(cuisine.toLowerCase())) {
      termCuisines.add(cuisine);
    } else {
      categoryCuisines.add(cuisine);
    }
  });

  String term = termCuisines.isNotEmpty ? termCuisines.join(', ') : '';
  if (occasion != null) {
    term += ' ${_convertOccasion(occasion)}';
  }

  term += ' restaurant';

  final queryParameters = {
    'term': term,
    'latitude': _userLocation!.latitude.toString(),
    'longitude': _userLocation!.longitude.toString(),
    'categories': categoryCuisines.isNotEmpty ? categoryCuisines.join(',') : null,
    'price': _convertPricing(pricing),
    'radius': _convertDistance(distance),
    'sort_by': 'best_match',
    'limit': '10',
  };

  print(_userLocation!.latitude.toString());
  print(_userLocation!.longitude.toString());

  queryParameters.removeWhere((key, value) => value == null);

  final uri = Uri.parse('$_baseUrl/businesses/search').replace(queryParameters: queryParameters);
  final cacheKey = uri.toString();

  if (_cache.containsKey(cacheKey)) {
    return _cache[cacheKey];
  }

  print(uri);

  try {
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    if (response.statusCode == 200) 
    {
      final data = json.decode(response.body);
      final businesses = data['businesses'] as List;
      final results = businesses.map((business) => Restaurant.fromJson(business)).toList();
      _cache[cacheKey] = results;
      return results;
    } 
    else if (response.statusCode == 429) 
    {
      throw Exception('API rate limit exceeded. Please try again later.');
    } 
    else {
      throw Exception('Failed to get recommendations: ${response.body}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

  Future<List<Restaurant>?> getNearbyRestaurants() async {
    return getRestaurantRecommendations();
  }

  String? _convertPricing(String? pricing) {
    switch (pricing?.toLowerCase()) {
      case 'inexpensive':
        return '1';
      case 'moderate':
        return '1,2';
      case 'expensive':
        return '3,4';
      default:
        return null;
    }
  }

  String? _convertDistance(String? distance) {
  switch (distance) {
    case '<10 min':
      return '5000';  // 5 km in meters
    case '10-30 min':
      return '15000'; // 15 km in meters
    case '30+ min':
      return '40000'; // 40 km in meters
    default:
      return null;
  }
}

  String? _convertOccasion(String? occasion) {
    switch (occasion?.toLowerCase()) {
      case 'breakfast/brunch':
        return 'breakfast_brunch';
      case 'lunch':
        return 'lunch';
      case 'dinner':
        return 'dinner';
      case 'take-out':
        return 'takeout';
      case 'late-night':
        return 'late night';
      default:
        return null;
    }
  }

  void clearCache() 
  {
    _cache.clear();
  }
}

// Future<Restaurant> getRestaurantDetails(String id) async {
//   final uri = Uri.parse('$_baseUrl/businesses/$id');
  
//   try {
//     final response = await http.get(
//       uri,
//       headers: {'Authorization': 'Bearer $_apiKey'},
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return Restaurant.fromJson(data);
//     } else {
//       throw Exception('Failed to get restaurant details: ${response.body}');
//     }
//   } catch (e) {
//     throw Exception('Network error: $e');
//   }
// }