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

  const MovieSuggestionsPage({Key? key, required this.recommendations}) : super(key: key);

  @override
  _MovieSuggestionsPageState createState() => _MovieSuggestionsPageState();
}

class _MovieSuggestionsPageState extends State<MovieSuggestionsPage> {
  int _selectedIndex = 1;
  Map<String, bool> likedMovies = {};
  Map<String, bool> dislikedMovies = {};

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
    return Scaffold(
      body: CardSwiper(
        cardsCount: (widget.recommendations.length / 3).ceil(),
        cardBuilder: (context, index, _, __) {
          int startIndex = index * 3;
          return Column(
            children: List.generate(3, (i) {
              if (startIndex + i < widget.recommendations.length) {
                Movie movie = widget.recommendations[startIndex + i];
                return Expanded(
                  child: MovieCard(
                    movie: movie,
                    isLiked: likedMovies[movie.id] ?? false,
                    isDisliked: dislikedMovies[movie.id] ?? false,
                    onLike: () => toggleLike(movie.id),
                    onDislike: () => toggleDislike(movie.id),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox());
              }
            }),
          );
        },
        numberOfCardsDisplayed: 1,
        isDisabled: false,
        allowedSwipeDirection: const AllowedSwipeDirection.only(
          left: true,
        ),
        padding: const EdgeInsets.all(0),
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
    Key? key,
    required this.movie,
    required this.isLiked,
    required this.isDisliked,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            CachedNetworkImage(
              imageUrl: movie.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: onDislike,
                        child: Icon(
                          isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: const Color.fromARGB(255, 183, 236, 236),
                          size: 28,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color.fromARGB(255, 183, 236, 236), size: 28),
                          SizedBox(width: screenWidth / 50),
                          Text(
                            '${movie.rating}',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Text(
                        movie.releaseDate.substring(0, 4),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: const Color.fromARGB(255, 183, 236, 236),
                          size: 28,
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