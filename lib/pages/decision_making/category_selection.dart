import 'package:blink_v1/navigation/customNavBar.dart';
import 'package:blink_v1/pages/friends/friendHub.dart';
import 'package:blink_v1/pages/profile/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedIndex = 1;

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
        // Do nothing since we already on the correct page.
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'What decision are you making?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TextField(
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search categories',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                       _buildRecentCategoryBox(SvgPicture.asset("assets/svgs/restaurant illustration.svg"), 'Restaurants'),
                      _buildRecentCategoryBox(SvgPicture.asset("assets/svgs/movie illustration.svg"), 'Movies'),
                      _buildRecentCategoryBox(SvgPicture.asset("assets/svgs/recipes illustration.svg"), 'Recipes'),
                      _buildRecentCategoryBox(SvgPicture.asset("assets/svgs/book illustration.svg"), 'Books'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'All Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryBox(SvgPicture.asset("assets/svgs/restaurant illustration.svg"), 'Restaurants'),
                _buildCategoryBox(SvgPicture.asset("assets/svgs/movie illustration.svg"), 'Movies'),
                _buildCategoryBox(SvgPicture.asset("assets/svgs/recipes illustration.svg"), 'Recipes'),
                _buildCategoryBox(SvgPicture.asset("assets/svgs/book illustration.svg"), 'Books'),
                _buildCategoryBox(SvgPicture.asset("assets/svgs/outfit illustration.svg"), 'Outfits'),
                _buildCategoryBox(SvgPicture.asset("assets/svgs/college illustration.svg"), 'Colleges'),
              ],
            ),
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

// 
// 
// 
// 
//
//Widgets to build the the category boxes


  Widget _buildRecentCategoryBox(SvgPicture icon, String label) {
  return Container(
    width: 100,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          child: icon,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


  Widget _buildCategoryBox(SvgPicture icon, String label) {
  return Container(
    height: 80,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 50,
            child: icon,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    ),
  );
}


}