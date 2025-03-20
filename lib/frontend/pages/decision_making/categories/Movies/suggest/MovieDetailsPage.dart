import 'package:auto_size_text/auto_size_text.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/profile/profilePage.dart';
import 'package:blink/frontend/utility/labeledIconButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blink/models/categories/Movie.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailsPage({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  int _selectedIndex = 1;

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

  Future<void> _launchIMDb() async {
    final Uri url = Uri.parse('https://www.imdb.com/title/${widget.movie.id}/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    height: screenHeight / 3,
                    width: screenWidth,
                    imageUrl: widget.movie.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  Positioned(
                    top: screenHeight / 18,
                    left: screenWidth / 40,
                    child: FloatingActionButton(
                      heroTag: 'backButton',
                      elevation: 0,
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      child: Icon(Icons.chevron_left_rounded, color: Colors.white, size: screenHeight / 20),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: screenHeight / 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              widget.movie.title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              minFontSize: 22,
                              overflowReplacement: Text(
                                widget.movie.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${widget.movie.rating}',
                                  style: const TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 15),
                                ),
                                SizedBox(width: screenWidth / 110),
                                const Icon(Icons.star, color: Color.fromARGB(255, 183, 236, 236), size: 20),
                                SizedBox(width: screenWidth / 110),
                                Text(
                                  widget.movie.releaseDate.substring(0, 4),
                                  style: const TextStyle(color: Colors.white, fontFamily: "OpenSans-Bold", fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LabeledIconButton(
                          onPressed: _launchIMDb,
                          icon: Icons.movie,
                          label: 'IMDb',
                        ),
                        LabeledIconButton(
                          onPressed: () {
                            // Implement trailer logic here
                          },
                          icon: Icons.play_arrow,
                          label: 'Trailer',
                        ),
                        LabeledIconButton(
                          onPressed: () {
                            // Implement save logic here
                          },
                          icon: Icons.bookmark_border_rounded,
                          label: 'Save',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.overview,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Genres',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.movie.genres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Release Date',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.movie.releaseDate,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Runtime',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.movie.runtime} minutes',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
}