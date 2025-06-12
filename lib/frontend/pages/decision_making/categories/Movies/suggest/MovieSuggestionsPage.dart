import 'package:blink/models/categories/Movie.dart';
import 'package:blink/frontend/pages/decision_making/categories/Movies/suggest/MovieDetailsPage.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/profile/profilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:flutter_svg/svg.dart';

class MovieSuggestionsPage extends StatefulWidget {
  final List<Movie> recommendations;

  const MovieSuggestionsPage({super.key, required this.recommendations});

  @override
  State<MovieSuggestionsPage> createState() => _MovieSuggestionsPageState();
}

class _MovieSuggestionsPageState extends State<MovieSuggestionsPage> {
  int _selectedIndex = 1;
  Map<String, bool> likedMovies = {};
  Map<String, bool> dislikedMovies = {};
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
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

  void toggleLike(String movieId) {
    setState(() {
      if (likedMovies[movieId] == true) {
        likedMovies[movieId] = false;
      } else {
        likedMovies[movieId] = true;
        dislikedMovies[movieId] = false;
      }
    });
  }

  void toggleDislike(String movieId) {
    setState(() {
      if (dislikedMovies[movieId] == true) {
        dislikedMovies[movieId] = false;
      } else {
        dislikedMovies[movieId] = true;
        likedMovies[movieId] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if recommendations are empty
    if (widget.recommendations.isEmpty) {
      return _buildEmptyState();
    }

    // 3 movies per card
    final List<Movie> displayedRecommendations = widget.recommendations.take(10).toList();
    final int cardsCount = (displayedRecommendations.length / 3.0).ceil();
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: CardSwiper(
        cardsCount: cardsCount,
        onSwipe: (previousIndex, currentIndex, direction) {
          if (currentIndex != null) {
            setState(() {
              _currentCardIndex = currentIndex;
            });
          }
          return true;
        },
        cardBuilder: (context, index, _, __) {
          int startIndex = index * 3;
          return Column(
            children: List.generate(3, (i) {
              if (startIndex + i < displayedRecommendations.length) {
                Movie movie = displayedRecommendations[startIndex + i];
                return Expanded(
                  child: MovieCard(
                    movie: movie,
                    isLiked: likedMovies[movie.id] ?? false,
                    isDisliked: dislikedMovies[movie.id] ?? false,
                    onLike: () => toggleLike(movie.id),
                    onDislike: () => toggleDislike(movie.id),
                  ),
                );
              } 
              else if (_currentCardIndex == cardsCount - 1 && i == 1) {
                // Last card, last slot → show end message
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 60, color: Color.fromARGB(255, 183, 236, 236)),
                        SizedBox(height: screenHeight / 56.8),
                        const Text(
                          "You've seen all recommendations!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: screenHeight / 85.2),
                        const Text(
                          "(Try refining your criteria to see more)",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }
              else {
                return const Expanded(child: SizedBox());
              }
            }),
          );
        },
        numberOfCardsDisplayed: 1,
        isDisabled: _currentCardIndex >= cardsCount - 1,
        allowedSwipeDirection: const AllowedSwipeDirection.only(
          left: true,
        ),
        padding: const EdgeInsets.all(0),
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
    );
  }

  Widget _buildEmptyState() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/blink-icon-color.png",
              height: 100,
              width: 100,
            ),
            SizedBox(height: screenHeight / 42.6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenHeight / 21.3),
              child: const Text(
                "No recommendations found. Try adjusting your filters.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight / 21.3),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenHeight / 35.5, vertical: screenHeight / 71),
                child: const Text(
                  "Go Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isLiked,
    required this.isDisliked,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsPage(movie: movie),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Movie poster image
            CachedNetworkImage(
              imageUrl: movie.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.error, size: screenHeight / 17.04, color: Colors.grey),
              ),
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            // Movie information
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight / 106.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dislike button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onDislike,
                            child: Icon(
                              isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                              color: const Color.fromARGB(255, 183, 236, 236),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: screenWidth / 50),
                          Text(
                            movie.type == 'movie'
                            ? movie.formattedRuntime // e.g. 1h 42m
                            : '${movie.runtime} min/ep',

                            style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: "Open Sans", fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Color.fromARGB(255, 183, 236, 236), size: 28),
                          SizedBox(width: screenWidth / 100),
                          Text(
                            movie.formattedTmdbRating,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: "Open Sans", fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      // Release year
                      Text(
                        movie.formattedReleaseYear,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: "Open Sans", fontWeight: FontWeight.w700),
                      ),
                      Text(
                        movie.genres.isNotEmpty
                          ? (movie.formatGenre(movie.genres[0]).length > 12 ? movie.formatGenre(movie.genres[0]).substring(0, 13) : movie.formatGenre(movie.genres[0]))
                          : 'N/A',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: "Open Sans", fontWeight: FontWeight.w700),
                      ),
                      // Like button
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: const Color.fromARGB(255, 183, 236, 236),
                          size: screenHeight / 30.43,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}