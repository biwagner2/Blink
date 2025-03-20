import 'package:blink/backend/services/categories/Movies/TMDBMovieService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:blink/models/categories/Movie.dart';
import 'package:blink/frontend/navigation/blinkButton.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:blink/frontend/navigation/readingMindScreen.dart';
import 'package:blink/frontend/pages/decision_making/categories/Movies/select/MovieInputPage.dart';
import 'package:blink/frontend/pages/decision_making/categories/Movies/suggest/MovieFilterSelectionPage.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/profile/profilePage.dart';

class MovieTabControllerPage extends StatefulWidget {
  const MovieTabControllerPage({super.key});

  @override
  State<MovieTabControllerPage> createState() => _MovieTabControllerPageState();
}

class _MovieTabControllerPageState extends State<MovieTabControllerPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  final recommender = TMDBMovieService();
  Map<String, dynamic> _movieFilterData = {};
  Map<String, dynamic> _showFilterData = {};
  late TabController _tabController;
  
  // Reference to the filter selection page key to access its state
  final GlobalKey<MovieFilterSelectionPageState> _filterPageKey = GlobalKey<MovieFilterSelectionPageState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add a listener to react to tab changes
    _tabController.addListener(() {
      // This will be called when the tab changes
      setState(() {
        // Any state updates needed when tab changes
      });
    });
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

void _handleFilterData(Map<String, dynamic> data) {
  // Don't update state if we're in the middle of a build
  if (!mounted) return;

  // Store filter data based on content type (movie or show)
  if (data['isMovie'] == true) {
    setState(() {
      _movieFilterData = data;
    });
  } else {
    setState(() {
      _showFilterData = data;
    });
  }
}

  Future<void> _onBlinkButtonPressed() async {
    if (_tabController.index == 0) {
      // Reset filters after generating recommendations
      if (_filterPageKey.currentState != null) {
        _filterPageKey.currentState!.resetFilters();
      }
      
      // Get the appropriate filter data based on current selection
      final filterData = _movieFilterData['isMovie'] == false ? _showFilterData : _movieFilterData;
      
      // Suggest tab - clear cache and fetch recommendations
      recommender.clearCache();
      Future<List<Movie>> recommendationsFuture = _getRecommendations(filterData);
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReadingMindScreen(
          recommendations: recommendationsFuture,
          category: filterData['isMovie'] == false ? 'Shows' : 'Movies',
        )),
      );
    } else {
      // Select tab functionality
      print('Selecting best option from user input');
    }
  }

  Future<List<Movie>> _getRecommendations(Map<String, dynamic> filterData) async {
    try {
      return await recommender.getMovieRecommendations(
        genres: filterData['genres'],
        platforms: filterData['platforms'],
        people: filterData['people'],
        similarMovies: filterData['similarMovies'],
        minRating: filterData['minRating'],
        maxRating: filterData['maxRating'],
        releaseYear: filterData['releaseYear'],
        sortBy: filterData['sortBy'],
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

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          // Reset filters when going back to category selection page
          if (didPop && _filterPageKey.currentState != null) {
            _filterPageKey.currentState!.resetFilters();
          }
        },
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
                // Reset filters when manually navigating back
                if (_filterPageKey.currentState != null) {
                  _filterPageKey.currentState!.resetFilters();
                }
                Navigator.pop(context);
              },
            ),
            leadingWidth: iconSize + 8,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/svgs/movie illustration.svg",
                  height: iconSize * 1.2,
                ),
                SizedBox(width: spacing),
                const Text(
                  'Movies/Shows',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController, // Connect TabBar to your controller
              tabs: const [
                Tab(text: 'Suggest'),
                Tab(text: 'Select'),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController, // Make sure this is the same controller
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MovieFilterSelectionPage(
                key: _filterPageKey,
                onFilterChanged: _handleFilterData
              ),
              const MovieInputPage(),
            ],
          ),
          floatingActionButton: FloatingActionButton.large(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () {},
            child: BlinkButton(
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
      );
  }
}