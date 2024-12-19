import 'package:blink_v1/models/categories/Restaurant.dart';
import 'package:blink_v1/frontend/navigation/blinkButton.dart';
import 'package:blink_v1/frontend/navigation/customNavBar.dart';
import 'package:blink_v1/frontend/navigation/readingMindScreen.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Restaurants/select/RestaurantInputPage.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Restaurants/suggest/RestaurantFilterSelectionPage.dart';
import 'package:blink_v1/frontend/pages/decision_making/category_selection.dart';
import 'package:blink_v1/frontend/pages/friends/friendHub.dart';
import 'package:blink_v1/frontend/pages/profile/profilePage.dart';
import 'package:blink_v1/backend/services/utility/LocationService.dart';
import 'package:blink_v1/backend/services/categories/Restaurants/YelpRestaurantService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantTabControllerPage extends StatefulWidget {

  const RestaurantTabControllerPage({super.key});

  @override
  _RestaurantTabControllerPageState createState() => _RestaurantTabControllerPageState();
}

class _RestaurantTabControllerPageState extends State<RestaurantTabControllerPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
   final recommender = YelpRestaurantService();
  final locationService = LocationService();
  Map<String, dynamic> _filterData = {};
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
  }
  
   Future<void> _getCurrentLocation() async
   {
      Position? position = await locationService.getCurrentLocation();
      position ??= await locationService.getLastKnownPosition();
      if (position != null) {
        setState(() {
        });
        recommender.setUserLocation(position);
        print('Location: ${position.latitude}, ${position.longitude}');
      } else {
        print('Failed to get location');
        // Handle the error, maybe show a message to the user
      }
    }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _handleFilterData(Map<String, dynamic> data) 
  {
    setState(() {
      _filterData = data;
    });
    print('Updated filter data: $_filterData');
  }

  Future<void> _onBlinkButtonPressed() async {
  if (_tabController.index == 0) 
  {
    // Suggest tab
    recommender.clearCache(); // Clear the cache before fetching new recommendations
    Position? userLocation = await locationService.getCachedOrCurrentLocation();
    if (userLocation == null) {
      if(mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location. Please try again.')),
        );
      }
      return;
    }
    recommender.setUserLocation(userLocation);
    Future<List<Restaurant>?> recommendationsFuture = _getRecommendations();
    if(mounted)
    {
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReadingMindScreen<Restaurant>(
      recommendations: recommendationsFuture,
      userLocation: userLocation,
      category: 'Restaurants',
      processRecommendations: (restaurants, location) async {
        if (location != null) {
          await Future.wait(restaurants.map((restaurant) => 
            restaurant.calculateAndCacheEta(location)
          ));
        }
      },
    ),
  ),
);
    }
  } 
  else {
    // Select tab
    // Implement the logic for selecting the best option from user input
    print('Selecting best option from user input');
  }
}


  Future<List<Restaurant>?> _getRecommendations() async {
  try {
    return await recommender.getRestaurantRecommendations(
      cuisines: _filterData['cuisines'],
      occasion: _filterData['occasion'],
      pricing: _filterData['pricing'],
      distance: _filterData['distance'],
      rating: _filterData['minRating'],
    );
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error getting recommendations: $e')),
    );
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.1;
    final spacing = screenWidth * 0.05;

    return DefaultTabController(
      length: 2,
      initialIndex: 0,  
      child: PopScope(
        canPop: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.black),
              iconSize: iconSize,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            leadingWidth: iconSize + 8,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/svgs/restaurant illustration.svg",
                  height: iconSize * 1.2,
                ),
                SizedBox(width: spacing),
                const Text(
                  'Restaurants',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Suggest'),
                Tab(text: 'Select'),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              RestaurantFilterSelectionPage(onFilterChanged: _handleFilterData),
              const RestaurantInputPage(),
            ],
          ),
          floatingActionButton: FloatingActionButton.large(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed:  () {},
            child: 
            BlinkButton(
              isEnlarged: true,
              onTap: _onBlinkButtonPressed,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/Connect.png", height: 40),
                label: '',
              ),
              BottomNavigationBarItem(
              icon: Image.asset("assets/images/blink-icon-color.png", height: 0),
              label: '',
            ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svgs/Profile.svg", height: 40),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}