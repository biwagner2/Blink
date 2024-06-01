import 'package:blink_v1/navigation/customNavBar.dart';
import 'package:blink_v1/pages/decision_making/Categories/Restaurants/RestaurantCriteriaPage2.dart';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/friends/friendHub.dart';
import 'package:blink_v1/pages/profile/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RestaurantCriteriaPage1 extends StatefulWidget {
  const RestaurantCriteriaPage1({Key? key}) : super(key: key);

  @override
  _RestaurantCriteriaPage1State createState() => _RestaurantCriteriaPage1State();
}

class _RestaurantCriteriaPage1State extends State<RestaurantCriteriaPage1> {
  int _selectedIndex = 1;

  final List<String> foodTypes = [
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

  final Set<String> selectedFoodTypes = <String>{};

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
    final screenWidth = MediaQuery.of(context).size.width;
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
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Which of these are you craving?',
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
                  itemCount: foodTypes.length,
                  itemBuilder: (context, index) {
                    final foodType = foodTypes[index];
                    final isSelected = selectedFoodTypes.contains(foodType);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedFoodTypes.remove(foodType);
                          } else {
                            selectedFoodTypes.add(foodType);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color.fromARGB(255, 183, 236, 236) : Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            addEmoji(foodType),
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
                  onPressed: () {
                    if (selectedFoodTypes.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('No food types selected'),
                            content: const Text(
                              'Please select at least one food type to continue.',
                              style: TextStyle(fontSize: 18),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantCriteriaPage2(
                          selectedFoodTypes: selectedFoodTypes,
                        ),
                      ),
                    );
                  },
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
              SizedBox(height: spacing + 8)
            ],
          ),
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
      ),
    );
  }

  String addEmoji(String foodType)
  {
    switch (foodType) {
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
        return foodType;
    }
  }
}