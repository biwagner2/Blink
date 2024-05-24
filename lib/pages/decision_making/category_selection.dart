import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _buildRecentCategoryBox(Icons.restaurant, 'Restaurants'),
                    _buildRecentCategoryBox(Icons.movie, 'Movies'),
                    _buildRecentCategoryBox(Icons.shopping_cart, 'Shopping'),
                    _buildRecentCategoryBox(Icons.flight, 'Travel'),
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
              _buildCategoryBox(Icons.restaurant, 'Restaurants'),
              _buildCategoryBox(Icons.movie, 'Movies'),
              _buildCategoryBox(Icons.shopping_cart, 'Shopping'),
              _buildCategoryBox(Icons.flight, 'Travel'),
              _buildCategoryBox(Icons.gamepad, 'Gaming'),
              _buildCategoryBox(Icons.book, 'Books'),
              _buildCategoryBox(Icons.music_note, 'Music'),
              _buildCategoryBox(Icons.sports_basketball, 'Sports'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildRecentCategoryBox(IconData icon, String label) {
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
          Icon(icon, size: 40),
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

  Widget _buildCategoryBox(IconData icon, String label) {
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
            child: Icon(icon, size: 40),
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