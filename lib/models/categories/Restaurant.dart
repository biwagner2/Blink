class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final bool isClosed;
  final String url;
  final int reviewCount;
  final List<String> categories;
  final double rating;
  final String price;
  final String address;
  final String phone;
  final double distance;
  
  // Additional fields for detailed view
  String? description;
  List<String>? additionalImages;
  String? eta;
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
    required this.rating,
    required this.price,
    required this.address,
    required this.phone,
    required this.distance,
    this.description,
    this.additionalImages,
    this.eta,
    this.businessHours,
    this.menuUrl,
    this.reservationUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      isClosed: json['is_closed'],
      url: json['url'],
      reviewCount: json['review_count'],
      categories: (json['categories'] as List).map((c) => c['title'] as String).toList(),
      rating: json['rating'].toDouble(),
      price: json['price'] ?? '',
      address: json['location']['display_address'].join(', '),
      phone: json['phone'],
      distance: json['distance'],
    );
  }

  String getPriceString() {
    return '\$' * price.length;
  }

  String getFormattedDistance() {
    return '${(distance / 1609.34).toStringAsFixed(1)} mi';
  }

  //Get the description of the current restaurant...
  // String getDescription() {
  //   return description ?? 'No description available';
  // }

}