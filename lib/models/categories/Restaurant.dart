import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  bool isClosed;
  final String url;
  final int reviewCount;
  final List<String> categories;
  final double? rating;
  final String? price;
  final String address;
  final String phone;
  final double distance;
  
  // Additional fields
  String? _cachedDescription;
  List<String>? additionalImages;
  String? _cachedEta;
  Map<String, String>? businessHours;
  String? menuUrl;
  String? reservationUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isClosed,
    required this.url,
    required this.reviewCount,
    required this.categories,
    this.rating,
    required this.price,
    required this.address,
    required this.phone,
    required this.distance,
    this.additionalImages,
    this.businessHours,
    this.menuUrl,
    this.reservationUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    print('Restaurant: ${json['name']}, Price: ${json['price']}, Address: ${json['location']['display_address'].join(', ')}, Distance: ${json['distance']}');

    return Restaurant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      isClosed: json['is_closed'],
      url: json['url'],
      reviewCount: json['review_count'],
      categories: (json['categories'] as List).map((c) => c['title'] as String).toList(),
      rating: json['rating'].toDouble(),
      price: json['price'],
      address: json['location']['display_address'].join(', '),
      phone: json['phone'],
      distance: json['distance'],
    );
  }

 String getFormattedDistance() {
    return '${(distance / 1609.34).toStringAsFixed(1)} mi';
  }

  Future<void> calculateAndCacheEta(Position userLocation) async {
    if (_cachedEta != null) return;

    try {
      final directionsService = DirectionsService();
      final request = DirectionsRequest(
        origin: '${userLocation.latitude},${userLocation.longitude}',
        destination: address,
        travelMode: TravelMode.driving,
      );

      DirectionsResult? result;
      DirectionsStatus? status;

      await directionsService.route(request, (DirectionsResult r, DirectionsStatus? s) {
        result = r;
        status = s;
      });

      if (status == DirectionsStatus.ok && result!.routes!.isNotEmpty) {
        final duration = result!.routes![0].legs![0].duration;
        _cachedEta = duration!.text!.replaceAll('mins', 'min');
      } else {
        throw Exception('Failed to get directions: $status');
      }
    } catch (e) {
      print('Error getting ETA: $e');
      // Fallback to estimation
      final miles = distance / 1609.34;
      final minutes = (miles / 0.2).ceil();
      _cachedEta = '$minutes min (est.)';
    }
  }

  String get formattedEta => _cachedEta ?? 'N/A';

  Future<void> getDetails() async 
  {
    final String apiKey = dotenv.env['YELP_API_KEY'] ?? '';
    final String baseUrl = dotenv.env['YELP_URL'] ?? '';
    final Uri uri = Uri.parse('$baseUrl/businesses/$id');

    try 
    {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (response.statusCode == 200) 
      {
        final data = json.decode(response.body);
        
        // Set additional images
        additionalImages = List<String>.from(data['photos']);

        // Set business hours
        if (data['hours'] != null && data['hours'].isNotEmpty) 
        {
          final openHours = data['hours'][0]['open'];
          businessHours = {};
          for (var hour in openHours) {
            String day = _getDayName(hour['day']);
            String startTime = _formatTime(hour['start']);
            String endTime = _formatTime(hour['end']);
            businessHours![day] = '$startTime - $endTime';
          }
        }
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } 
      else 
      {
        throw Exception('Failed to get details: ${response.body}');
      }
    } 
    catch (e) 
    {
      throw Exception('Network error: $e');
    }
    isClosed = isCurrentlyClosed();
}

String _getDayName(int day) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return days[day];
}

String _formatTime(String time) {
  int hours = int.parse(time.substring(0, 2));
  String minutes = time.substring(2);
  String period = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours == 0 ? 12 : hours;
  return '$hours:$minutes $period';
}

  String formatReviewCount()
  {
    if(reviewCount > 1000)
    {
      return '${(reviewCount / 1000).toStringAsFixed(1)}K';
    }
    else
    {
      return '($reviewCount)';
    }
  }


  Future<String?> getDescription() async {
    if (_cachedDescription != null) return _cachedDescription;
    
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      return null;
    }
    String descriptionCategories = categories.join(', ');
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final content = [Content.text('Give me a one-sentence, elegant, and succinct description, of the following restaurant: $name located at $address. It should be no more than 191 characters in length. Here is extra information if needed: $descriptionCategories, with a rating of $rating stars and a price range of $price. ONLY use the extra information if you don\'t have enough to generate a description. Thanks!')];
    final response = await model.generateContent(content);
    _cachedDescription = response.text;
    return _cachedDescription;
  }

  bool isCurrentlyClosed() {
  if (businessHours == null) return true;
  
  final now = DateTime.now();
  final currentDay = DateFormat('EEEE').format(now);
  final currentTime = DateFormat('HH:mm').format(now);
  
  if (!businessHours!.containsKey(currentDay)) return true;
  
  final hours = businessHours![currentDay]!;
  final times = hours.split(' - ');
  if (times.length != 2) return true;
  
  final openTime = DateFormat('hh:mm a').parse(times[0]);
  var closeTime = DateFormat('hh:mm a').parse(times[1]);
  
  // If closing time is earlier than opening time, it means it closes after midnight
  if (closeTime.isBefore(openTime)) {
    closeTime = closeTime.add(const Duration(days: 1));
  }
  
  final currentDateTime = DateFormat('HH:mm').parse(currentTime);
  return currentDateTime.isBefore(openTime) || currentDateTime.isAfter(closeTime);
}
}