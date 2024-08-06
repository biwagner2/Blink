import 'package:blink_v1/services/LocationService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final bool isClosed;
  final String url;
  final int reviewCount;
  final List<String> categories;
  final double? rating;
  final String? price;
  final String address;
  final String phone;
  final double distance;
  
  // Additional fields
  String? description;
  List<String>? additionalImages;
  String? _cachedEta;
  DateTime? _etaLastUpdated;
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
    this.description,
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
        _cachedEta = duration!.text;
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
  
}
  //Get the description of the current restaurant...
  // String getDescription() {
  //   return description ?? 'No description available';
  // }