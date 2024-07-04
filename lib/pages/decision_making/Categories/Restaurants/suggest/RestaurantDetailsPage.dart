// import "package:flutter/material.dart";

// class RestaurantDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> recommendation;

//   const RestaurantDetailsPage({super.key, required this.recommendation});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(recommendation['name'] ?? 'Restaurant Details'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image carousel
//             SizedBox(
//               height: 200,
//               child: PageView.builder(
//                 itemCount: recommendation['images']?.length ?? 1,
//                 itemBuilder: (context, index) {
//                   return Image.network(
//                     recommendation['images']?[index] ?? recommendation['image_url'] ?? 'https://via.placeholder.com/150',
//                     fit: BoxFit.cover,
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     recommendation['name'] ?? 'Unknown',
//                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.yellow),
//                       Text('${recommendation['rating'] ?? 'N/A'} (${recommendation['review_count'] ?? 0} reviews)'),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text('Distance: ${recommendation['distance'] ?? 'N/A'}'),
//                   Text('Hours: ${recommendation['hours'] ?? 'N/A'}'),
//                   Text('Status: ${recommendation['is_open'] ? 'Open' : 'Closed'}'),
//                   const SizedBox(height: 16),
//                   Text(
//                     recommendation['description'] ?? 'No description available.',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }