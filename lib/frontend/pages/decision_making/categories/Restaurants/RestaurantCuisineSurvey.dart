import 'package:blink/frontend/pages/decision_making/categories/Restaurants/RestaurantTabControllerPage.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/profile/profilePage.dart';
import 'package:blink/backend/services/supabase/supabaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';

class RestaurantCuisineSurvey extends StatefulWidget {
  const RestaurantCuisineSurvey({super.key});

  @override
  _RestaurantCuisineSurveyState createState() => _RestaurantCuisineSurveyState();
}

class _RestaurantCuisineSurveyState extends State<RestaurantCuisineSurvey> {
  int _selectedIndex = 1;
  final Set<String> _selectedCuisines = <String>{};
  final SupabaseService _supabaseService = SupabaseService();

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
        // Do nothing since we're already on the correct page
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

  void _toggleCuisineSelection(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine)) {
        _selectedCuisines.remove(cuisine);
      } else {
        _selectedCuisines.add(cuisine);
      }
    });
  }

  void _saveCuisinePreferences() async {
    await _supabaseService.saveCuisinePreferences(
      userId: await _supabaseService.getUserId(),
      cuisines: _selectedCuisines.toList(),
    );

    // Navigate to the RestaurantTabControllerPage
     if (mounted){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RestaurantTabControllerPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.1;
    final spacing = screenWidth * 0.05;

    return PopScope(
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
                'Restaurant Cuisine',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Which of these do you enjoy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _cuisineOptions.length,
                  itemBuilder: (context, index) {
                    final cuisine = _cuisineOptions[index];
                    final isSelected = _selectedCuisines.contains(cuisine);
                    return GestureDetector(
                      onTap: () => _toggleCuisineSelection(cuisine),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color.fromARGB(255, 183, 236, 236) : Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            addEmoji(cuisine),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _selectedCuisines.isNotEmpty ? _saveCuisinePreferences : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(250, 0),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing)
            ],
          ),
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
      ),
    );
  }

  String addEmoji(String cuisine) {
    switch (cuisine) {
      case 'Vegan':
        return '🌱Vegan';
      case 'Fast Food':
        return '🍟Fast Food';
      case 'East Asian':
        return '🍣East Asian';
      case 'Mexican':
        return '🌮Mexican';
      case 'Indian':
        return '🇮🇳Indian';
      case 'Mediterranean':
        return '🥙Mediterranean';
      case 'American':
        return '🍔American';
      case 'Vegetarian':
        return '🥗Vegetarian';
      case 'Halal':
        return '🧆Halal';
      case 'Caribbean':
        return '🌴Caribbean';
      case 'Italian':
        return '🍝Italian';
      case 'Healthy':
        return '🍎Healthy';
      case 'Coffee':
        return '☕Coffee';
      case 'Sweet':
        return '🍪Sweet';
      case 'Bakery':
        return '🥖Bakery';
      case 'Tea':
        return '🍵Tea';
      default:
        return cuisine;
    }
  }

  final List<String> _cuisineOptions = [
    'Vegan',
    'Fast Food',
    'East Asian',
    'Mexican',
    'Indian',
    'Mediterranean',
    'American',
    'Vegetarian',
    'Halal',
    'Caribbean',
    'Italian',
    'Healthy',
    'Coffee',
    'Sweet',
    'Bakery',
    'Tea',
  ];
}