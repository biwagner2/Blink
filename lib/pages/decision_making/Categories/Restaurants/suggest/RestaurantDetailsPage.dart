import 'package:flutter/material.dart';
import 'package:blink_v1/models/categories/Restaurant.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: restaurant.additionalImages?.length ?? 1,
                itemBuilder: (context, index) {
                  return Image.network(
                    restaurant.additionalImages?[index] ?? restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow),
                      Text('${restaurant.rating} (${restaurant.reviewCount} reviews)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Distance: ${restaurant.getFormattedDistance()}'),
                  Text('Hours: ${restaurant.businessHours != null ? restaurant.businessHours!.entries.map((e) => '${e.key}: ${e.value}').join(', ') : 'N/A'}'),
                  Text('Status: ${restaurant.isClosed ? 'Closed' : 'Open'}'),
                  const SizedBox(height: 16),
                  Text(
                    restaurant.description ?? 'No description available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (restaurant.menuUrl != null)
                    ElevatedButton(
                      onPressed: () {
                        // Implement menu opening logic here
                      },
                      child: const Text('View Menu'),
                    ),
                  if (restaurant.reservationUrl != null)
                    ElevatedButton(
                      onPressed: () {
                        // Implement reservation logic here
                      },
                      child: const Text('Make Reservation'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}