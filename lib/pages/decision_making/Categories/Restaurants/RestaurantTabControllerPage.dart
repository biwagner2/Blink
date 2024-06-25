import 'package:blink_v1/navigation/blinkButton.dart';
import 'package:blink_v1/navigation/customNavBar.dart';
import 'package:blink_v1/pages/decision_making/Categories/Restaurants/select/RestaurantInputPage.dart';
import 'package:blink_v1/pages/decision_making/Categories/Restaurants/suggest/RestaurantFilterSelectionPage.dart';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/friends/friendHub.dart';
import 'package:blink_v1/pages/profile/profilePage.dart';
import 'package:blink_v1/services/Restaurants/RestaurantService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RestaurantTabControllerPage extends StatefulWidget {

  const RestaurantTabControllerPage({super.key});

  @override
  _RestaurantTabControllerPageState createState() => _RestaurantTabControllerPageState();
}

class _RestaurantTabControllerPageState extends State<RestaurantTabControllerPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  final recommender = GeminiRestaurantService();
  Map<String, dynamic> _filterData = {};
  late TabController _tabController;

     @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  void _handleFilterData(Map<String, dynamic> data) {
    setState(() {
      _filterData = data;
    });
  }

  Future<void> _onBlinkButtonPressed() async {
    if (_tabController.index == 0) {
      // Suggest tab
      await _getRecommendations();
    } else {
      // Select tab
      // Implement the logic for selecting the best option from user input
      // This should be implemented in RestaurantInputPage
      // For now, we'll just print a message
      print('Selecting best option from user input');
    }
  }

  Future<void> _getRecommendations() async {
    try {
      List<String> recommendations;
      if (_filterData.isEmpty) {
        // No criteria selected, get nearby restaurants
        recommendations = await recommender.getNearbyRestaurants();
      } else {
        recommendations = await recommender.getRestaurantRecommendations(
          cuisines: _filterData['cuisines'],
          occasion: _filterData['occasion'],
          pricing: _filterData['pricing'],
          distance: _filterData['distance'],
          minRating: _filterData['minRating'],
          maxRating: _filterData['maxRating'],
        );
      }
      _showRecommendations(recommendations);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting recommendations: $e')),
      );
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
        canPop: false,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesPage()),
                );
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
  void _showRecommendations(List<String> recommendations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restaurant Recommendations'),
          content: SingleChildScrollView(
            child: ListBody(
              children: recommendations.map((restaurant) => Text(restaurant)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}