import 'package:blink_v1/backend/services/categories/Movies/TMDBMovieService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:blink_v1/models/categories/Movie.dart';
import 'package:blink_v1/frontend/navigation/blinkButton.dart';
import 'package:blink_v1/frontend/navigation/customNavBar.dart';
import 'package:blink_v1/frontend/navigation/readingMindScreen.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Movies/select/MovieInputPage.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Movies/suggest/MovieFilterSelectionPage.dart';
import 'package:blink_v1/frontend/pages/decision_making/category_selection.dart';
import 'package:blink_v1/frontend/pages/friends/friendHub.dart';
import 'package:blink_v1/frontend/pages/profile/profilePage.dart';


class MovieTabControllerPage extends StatefulWidget {
  const MovieTabControllerPage({Key? key}) : super(key: key);

  @override
  _MovieTabControllerPageState createState() => _MovieTabControllerPageState();
}

class _MovieTabControllerPageState extends State<MovieTabControllerPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  final recommender = TMDBMovieService();
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
      recommender.clearCache();
      Future<List<Movie>> recommendationsFuture = _getRecommendations();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReadingMindScreen(
          recommendations: recommendationsFuture,
          category: 'Movies',
        )),
      );
    } else {
      print('Selecting best option from user input');
    }
  }

  Future<List<Movie>> _getRecommendations() async {
    try {
      return await recommender.getMovieRecommendations(
        genres: _filterData['genres'],
        platforms: _filterData['platforms'],
        people: _filterData['people'],
        similarMovies: _filterData['similarMovies'],
        minRating: _filterData['minRating'],
        maxRating: _filterData['maxRating'],
        releaseYear: _filterData['releaseYear'],  // Keep this
        sortBy: _filterData['sortBy'],
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
                  "assets/svgs/movie illustration.svg",
                  height: iconSize * 1.2,
                ),
                SizedBox(width: spacing),
                const Text(
                  'Movies',
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
              MovieFilterSelectionPage(onFilterChanged: _handleFilterData),
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
      ),
    );
  }
}