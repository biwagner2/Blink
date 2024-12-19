import 'package:blink_v1/frontend/navigation/customNavBar.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Movies/MovieTabControllerPage.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Restaurants/RestaurantCuisineSurvey.dart';
import 'package:blink_v1/frontend/pages/decision_making/categories/Restaurants/RestaurantTabControllerPage.dart';
import 'package:blink_v1/frontend/pages/friends/friendHub.dart';
import 'package:blink_v1/frontend/pages/profile/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';


//Shows all of the categories that the user can choose from
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  //Index of the selected item in the bottom navigation bar
  int _selectedIndex = 1;

  //List of recent categories that the user has selected
  List<String> _recentCategories = [];

  //List of all categories that the user can choose from
  final List<String> _allCategories = ['Restaurants', 'Movies', 'Recipes', 'Books', 'Outfits', 'Colleges'];

  /// Map of synonyms for each category to improve search functionality.
  final Map<String, List<String>> _synonyms = {
    'Restaurants': ['food', 'dining', 'eatery', 'cuisine', 'grub', 'munchies'],
    'Movies': ['films', 'cinema', 'flicks'],
    'Recipes': ['cooking', 'dishes', 'meals'],
    'Books': ['reading', 'literature', 'novels'],
    'Outfits': ['clothes', 'fashion', 'attire', 'garments', 'wardrobe', 'apparel', 'fit'],
    'Colleges': ['schools', 'universities', 'education'],
  };

  final TextEditingController _searchController = TextEditingController();
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadRecentCategories();
    _searchController.addListener(_onSearchChanged);
  }

   @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _searchSuggestions = _getSuggestions(keyword);
      _showSuggestions = keyword.isNotEmpty;
    });
  }

  Future<void> _loadRecentCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedCategories = prefs.getStringList('recentCategories') ?? [];
    setState(() {
      _recentCategories = savedCategories;
    });
  }

  Future<void> _saveRecentCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentCategories', _recentCategories);
  }

  void _onCategoryTapped(String category) {
    if (_allCategories.contains(category)) {
      setState(() {
        if (_recentCategories.contains(category)) {
          _recentCategories.remove(category);
        }
        _recentCategories.insert(0, category);
        if (_recentCategories.length > 4) {
          _recentCategories.removeLast();
        }
      });
      _saveRecentCategories();
      _navigateToCategory(category);
    } else {
      _showCategoryNotFoundDialog();
    }
  }

  void _navigateToCategory(String category) {
    switch (category) {
      case "Restaurants":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantTabControllerPage()),
        );
        break;
      case "Movies":
        // Navigate to the Movies page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MovieTabControllerPage()),
        );
        break;
      case "Recipes":
        // Navigate to the Recipes page
        break;
      case "Books":
        // Navigate to the Books page
        break;
      case "Outfits":
        // Navigate to the Outfits page
        break;
      case "Colleges":
        // Navigate to the Colleges page
        break;
    }
  }

  void _showCategoryNotFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Category Not Found", textAlign: TextAlign.center,),
          content: const Text("The category you searched for is not an option. Please try again.",
                   style: TextStyle(fontSize: 16, fontFamily: 'OpenSans')
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        // Do nothing since we already on the correct page.
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
        body: GestureDetector(
           onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _showSuggestions = false;
            });
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLines: 1,
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search categories',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onSubmitted: _handleSearch,
                  ),
                  if (_showSuggestions)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final category = _searchSuggestions[index];
                          return ListTile(
                            leading: SizedBox(
                              width: 40,
                              height: 40,
                              child: _getCategoryIcon(category),
                            ),
                            title: Text(category),
                            onTap: () {
                              _handleSearch(category);
                              setState(() {
                                _showSuggestions = false;
                              });
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          );
                        },
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
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentCategories.length,
                      itemBuilder: (context, index) {
                        String category = _recentCategories[index];
                        return _buildRecentCategoryBox(
                          _getCategoryIcon(category),
                          category,
                        );
                      },
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
                  _buildCategoryBox(
                    SvgPicture.asset("assets/svgs/restaurant illustration.svg"),
                    'Restaurants',
                  ),
                  _buildCategoryBox(
                    SvgPicture.asset("assets/svgs/movie illustration.svg"),
                    'Movies',
                  ),
                  _buildCategoryBox(
                    SvgPicture.asset("assets/svgs/recipes illustration.svg"),
                    'Recipes',
                  ),
                  _buildCategoryBox(
                    SvgPicture.asset("assets/svgs/book illustration.svg"),
                    'Books',
                  ),
                  _buildCategoryBox(
                    SvgPicture.asset("assets/svgs/outfit illustration.svg"),
                    'Outfits',
                  ),
                  _buildCategoryBox(
                    SvgPicture.asset("assets/svgs/college illustration.svg"),
                    'Colleges',
                  ),
                ],
              ),
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
              icon: Image.asset("assets/images/blink-icon-color.png", height: 45),
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

  //Method that returns category box widget for recent categories
  Widget _buildRecentCategoryBox(SvgPicture icon, String label) {
    return GestureDetector(
      onTap: () => _onCategoryTapped(label),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SizedBox(
                  height: 70,
                  child: icon,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBox(SvgPicture icon, String label) {
    return GestureDetector(
      onTap: () => _onCategoryTapped(label),
      child: Container(
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
      ),
    );
  }

  SvgPicture _getCategoryIcon(String category) {
    switch (category) {
      case 'Restaurants':
        return SvgPicture.asset("assets/svgs/restaurant illustration.svg");
      case 'Movies':
        return SvgPicture.asset("assets/svgs/movie illustration.svg");
      case 'Recipes':
        return SvgPicture.asset("assets/svgs/recipes illustration.svg");
      case 'Books':
        return SvgPicture.asset("assets/svgs/book illustration.svg");
      case 'Outfits':
        return SvgPicture.asset("assets/svgs/outfit illustration.svg");
      case 'Colleges':
        return SvgPicture.asset("assets/svgs/college illustration.svg");
      default:
        return SvgPicture.asset("assets/svgs/default illustration.svg");
    }
  }
  

  //Generates a list of category suggestions based on the given keyword.
  List<String> _getSuggestions(String keyword) 
  {
    Set<String> suggestions = {};
    
    // This method searches through category names and their synonyms to find
    // partial matches for the given keyword.
    for (var category in _allCategories) 
    {
      if (_isPartialMatch(category, keyword)) 
      {
        suggestions.add(category);
      } 
      else 
      {
        for (var synonym in _synonyms[category] ?? []) 
        {
          if (_isPartialMatch(synonym, keyword)) 
          {
            suggestions.add(category);
            break;
          }
        }
      }
    }
    // Returns a list of matching category names.
    return suggestions.toList();
  }

  //This method is case-insensitive and checks if the keyword is a substring
  //of the text or vice versa.
  bool _isPartialMatch(String text, String keyword) {
    text = text.toLowerCase();
    keyword = keyword.toLowerCase();
    return text.contains(keyword) || keyword.contains(text);
  }

  // Handles the search action when a user submits a search term.
  void _handleSearch(String searchTerm) 
  {
    //Attempts to find a matching category for the given search term
    //and navigates to the corresponding page if found. If no match is found,
    //it shows a "Category not found" dialog.
    String? matchedCategory = _findMatchingCategory(searchTerm);
    if (matchedCategory != null) 
    {
      _onCategoryTapped(matchedCategory);
    } 
    else 
    {
      _showCategoryNotFoundDialog();
    }
  }
  
  // Finds a matching category for the given search term.
  String? _findMatchingCategory(String searchTerm) {
    searchTerm = searchTerm.toLowerCase();
    
    //This method checks if the search term partially matches any category name
    //or any of its synonyms.
    for (var category in _allCategories) {
      if (_isPartialMatch(category, searchTerm)) {
        return category;
      }
      for (var synonym in _synonyms[category] ?? []) {
        if (_isPartialMatch(synonym, searchTerm)) {
          return category;
        }
      }
    }

    //Returns the matched category name, or null if no match is found.
    return null;
  }
}