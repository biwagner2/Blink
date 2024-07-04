import 'dart:math';

import 'package:blink_v1/pages/decision_making/Categories/Restaurants/suggest/RestaurantDetailsPage.dart';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/friends/friendHub.dart';
import 'package:blink_v1/pages/profile/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:blink_v1/navigation/customNavBar.dart';
import 'package:flutter_svg/svg.dart';

class RestaurantSuggestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> recommendations;

  const RestaurantSuggestionsPage({super.key, required this.recommendations});

  @override
  _RestaurantSuggestionsPageState createState() => _RestaurantSuggestionsPageState();
}

class _RestaurantSuggestionsPageState extends State<RestaurantSuggestionsPage> {
  int _selectedIndex = 1; // Assuming this is the index for the current page in the bottom nav bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to the Friends page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendHub()),
        );
        break;
      case 1:
        // Navigate to the Categories page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoriesPage()),
        );
        break;

      case 2:
        // Navigate to the Profile page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardSwiper(
          cardsCount: (widget.recommendations.length / 3).ceil(),
          cardBuilder: (context, index, _, __) {
            int startIndex = index * 3;
            return Column(
              children: List.generate(3, (i) {
                if (startIndex + i < widget.recommendations.length) {
                  return Expanded(
                    child: RestaurantCard(recommendation: widget.recommendations[startIndex + i]),
                  );
                } else {
                  return const Expanded(child: SizedBox());
                }
              }),
            );
          },
          numberOfCardsDisplayed: 1,
          isDisabled: false,
          allowedSwipeDirection: const AllowedSwipeDirection.only(
            left: true,
          ),
          padding: const EdgeInsets.all(0),
        ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/Connect.png", height: 40),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/images/blink-icon-color.png", height: 40),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svgs/Profile.svg", height: 40),
              label: '',
            ),
          ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const RestaurantCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsPage(recommendation: recommendation),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              recommendation['image_url'] ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    recommendation['name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${recommendation['rating'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${recommendation['eta'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        _getPriceString(recommendation['price']),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriceString(String? price) {
    if (price == null) return 'N/A';
    return '\$' * price.length;
  }
}

class RestaurantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const RestaurantDetailsPage({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recommendation['name'] ?? 'Restaurant Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: recommendation['images']?.length ?? 1,
                itemBuilder: (context, index) {
                  return Image.network(
                    recommendation['images']?[index] ?? recommendation['image_url'] ?? 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
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
                    recommendation['name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color.fromARGB(255, 183, 236, 236)),
                      Text('${recommendation['rating'] ?? 'N/A'} (${recommendation['review_count'] ?? 0} reviews)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Distance: ${recommendation['distance'] ?? 'N/A'}'),
                  Text('Hours: ${recommendation['hours'] ?? 'N/A'}'),
                  Text('Status: ${recommendation['is_open'] ? 'Open' : 'Closed'}'),
                  const SizedBox(height: 16),
                  Text(
                    recommendation['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 16),
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