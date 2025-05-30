import 'package:blink/models/categories/Restaurant.dart';
import 'package:blink/frontend/pages/decision_making/categories/Restaurants/suggest/RestaurantDetailsPage.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/profile/profilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:flutter_svg/svg.dart';

class RestaurantSuggestionsPage extends StatefulWidget {
  final List<Restaurant> recommendations;

  const RestaurantSuggestionsPage({super.key, required this.recommendations});

  @override
  _RestaurantSuggestionsPageState createState() => _RestaurantSuggestionsPageState();
}

class _RestaurantSuggestionsPageState extends State<RestaurantSuggestionsPage> {
  int _selectedIndex = 1; // Assuming this is the index for the current page in the bottom nav bar
  Map<String, bool> likedRestaurants = {};
  Map<String, bool> dislikedRestaurants = {};
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to the Friends page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const FriendHub(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        // Navigate to the Categories page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const CategoriesPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;

      case 2:
        // Navigate to the Profile page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const ProfilePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  void toggleLike(String restaurantId) {
    setState(() {
      if (likedRestaurants[restaurantId] == true) {
        likedRestaurants[restaurantId] = false;
      } else {
        likedRestaurants[restaurantId] = true;
        dislikedRestaurants[restaurantId] = false;
      }
    });
  }

  void toggleDislike(String restaurantId) {
    setState(() {
      if (dislikedRestaurants[restaurantId] == true) {
        dislikedRestaurants[restaurantId] = false;
      } else {
        dislikedRestaurants[restaurantId] = true;
        likedRestaurants[restaurantId] = false;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    // Check if recommendations are empty
    if (widget.recommendations.isEmpty) {
      return _buildEmptyState();
    }
    
    final screenHeight = MediaQuery.of(context).size.height;
    final cardsCount = (widget.recommendations.length / 3).ceil();
    
    return Scaffold(
      body: CardSwiper(
        cardsCount: cardsCount,
        onSwipe: (previousIndex, currentIndex, direction) {
          if (currentIndex != null) {
            setState(() {
              _currentCardIndex = currentIndex;
            });
          }
          return true;
        },
        cardBuilder: (context, index, _, __) {
          int startIndex = index * 3;
          return Column(
            children: List.generate(3, (i) {
              if (startIndex + i < widget.recommendations.length) {
                Restaurant restaurant = widget.recommendations[startIndex + i];
                return Expanded(
                  child: RestaurantCard(
                    restaurant: restaurant,
                    isLiked: likedRestaurants[restaurant.id] ?? false,
                    isDisliked: dislikedRestaurants[restaurant.id] ?? false,
                    onLike: () => toggleLike(restaurant.id),
                    onDislike: () => toggleDislike(restaurant.id),
                  ),
                );
                } 
                else if (_currentCardIndex == cardsCount - 1 && i == 1) {
                  // Last card, last slot → show end message
                  return Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 60, color: Color.fromARGB(255, 183, 236, 236)),
                          SizedBox(height: screenHeight / 56.8),
                          const Text(
                            "You've seen all recommendations!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: screenHeight / 85.2),
                          const Text(
                            "(Try refining your criteria to see more)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                else {
                  return const Expanded(child: SizedBox());
                }
              }),
            );
          },
          numberOfCardsDisplayed: 1,
          isDisabled: _currentCardIndex >= cardsCount - 1,
          allowedSwipeDirection: const AllowedSwipeDirection.only(
            left: true,
          ),
          padding: const EdgeInsets.all(0),
        ),
      bottomNavigationBar: MediaQuery(
        data: MediaQuery.of(context).removePadding(removeBottom: true),
        child: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/Connect.png", height: screenHeight / 21.3),  
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/blink-icon-color.png", height: screenHeight / 18.9),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svgs/Profile.svg", height: screenHeight / 21.3),
                label: '',
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/blink-icon-color.png",
              height: 100,
              width: 100,
            ),
            SizedBox(height: screenHeight / 42.6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenHeight / 21.3),
              child: const Text(
                "No recommendations found. Try adjusting your filters.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight / 21.3),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenHeight / 35.5, vertical: screenHeight / 71),
                child: const Text(
                  "Go Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isLiked,
    required this.isDisliked,
    required this.onLike,
    required this.onDislike,
  });

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        // Store the context in a local variable
        final context = this.context;

        // Show a loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        // Wait for getDetails to complete
        await widget.restaurant.getDetails();

        // Check if the widget is still mounted
        if (!mounted) return;

        // Hide the loading indicator
        if(context.mounted)
        {
          Navigator.of(context).pop();
        }
        else
        {
          return;
        }

        // Navigate to the details page
        if(!context.mounted)
        {
          return;
        }
        else
        {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailsPage(restaurant: widget.restaurant),
            ),
          );
        }
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
            CachedNetworkImage(
              imageUrl: widget.restaurant.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onDislike,
                        child: Icon(
                          widget.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: const Color.fromARGB(255, 183, 236, 236),
                          size: 28,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: Color.fromARGB(255, 183, 236, 236), size: 28),
                            SizedBox(width: screenWidth/50),
                            Text(
                              '${widget.restaurant.rating ?? 'N/A'}',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(width: screenWidth/25),
                            const Icon(Icons.access_time, color: Color.fromARGB(255, 183, 236, 236), size: 28),
                            SizedBox(width: screenWidth/70),
                            Text(
                              widget.restaurant.formattedEta,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(width: screenWidth/40),
                            Text(
                              widget.restaurant.price ?? 'N/A',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onLike,
                        child: Icon(
                          widget.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: const Color.fromARGB(255, 183, 236, 236),
                          size: 28,
                        ),
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
}