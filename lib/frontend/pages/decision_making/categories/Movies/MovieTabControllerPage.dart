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
  Map<String, dynamic> _filterData = {};
  late TabController _tabController;
  
  // Reference to the filter selection page key to access its state
  final GlobalKey<MovieFilterSelectionPageState> _filterPageKey = GlobalKey<MovieFilterSelectionPageState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen for tab changes to update the IndexedStack
    _tabController.addListener(() {
      setState(() {
        // Forces a rebuild with the new tab index
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
    setState(() {
      _filterData = data;
    });
    print('Updated filter data: $_filterData');
  }

  Future<void> _onBlinkButtonPressed() async {
    if (_tabController.index == 0) {
      // Reset cache before fetching new recommendations
      recommender.clearCache();
      
      // Check if we have filter data
      if (_filterData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one filter')),
        );
        return;
      }
      
      // Get movie or show recommendations based on isMovie flag
      final bool isMovie = _filterData['isMovie'] ?? true;
      Future<List<Movie>> recommendationsFuture;
      
      try {
        if (isMovie) {
          print('Getting movie recommendations with filters: $_filterData');
          recommendationsFuture = recommender.getMovieRecommendations(
            genres: _filterData['genres']?.cast<String>(),
            platforms: _filterData['platforms']?.cast<String>(),
            people: _filterData['people']?.cast<String>(),
            similarMovies: _filterData['similarMedia']?.cast<String>(),
            minRating: _filterData['minRating'],
            maxRating: _filterData['maxRating'],
          );
        } else {
          print('Getting show recommendations with filters: $_filterData');
          recommendationsFuture = recommender.getShowRecommendations(
            genres: _filterData['genres']?.cast<String>(),
            platforms: _filterData['platforms']?.cast<String>(),
            people: _filterData['people']?.cast<String>(),
            similarShows: _filterData['similarMedia']?.cast<String>(),
            minRating: _filterData['minRating'],
            maxRating: _filterData['maxRating'],
          );
        }
        
        // Navigate to loading screen while fetching recommendations
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingMindScreen<Movie>(
                recommendations: recommendationsFuture,
                category: isMovie ? 'Movies' : 'Shows',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error preparing recommendations: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      // Select tab functionality (for future implementation)
      print('Selecting best option from user input');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.1;
    final spacing = screenWidth * 0.05;

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        // We only reset filters when the user is leaving the page entirely
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
              // Navigate back
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
            controller: _tabController,
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
        // Use IndexedStack to maintain widget state when switching tabs
        body: IndexedStack(
          index: _tabController.index,
          children: [
            // These widgets will maintain their state when tab changes
            MovieFilterSelectionPage(
              key: _filterPageKey,
              onFilterChanged: _handleFilterData,
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
        bottomNavigationBar: MediaQuery(
          data: MediaQuery.of(context).removePadding(removeBottom: true),
          child: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/Connect.png", height: screenHeight/21.3),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/blink-icon-color.png", height: 0),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svgs/Profile.svg", height: screenHeight/21.3),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}