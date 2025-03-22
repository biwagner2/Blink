import 'package:auto_size_text/auto_size_text.dart';
import 'package:blink/frontend/navigation/blinkButton.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:blink/frontend/pages/decision_making/categories/selectionPage.dart';
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

  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  int _selectedIndex = 1;
  bool _isSaved = false;

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

  Future<void> _launchIMDb() async {
    final Uri url = Uri.parse('https://www.imdb.com/title/${widget.movie.id}/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchTrailer() async {
    // YouTube search URL for the movie trailer
    final Uri url = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent("${widget.movie.title} trailer ${widget.movie.formattedReleaseYear}")}'
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    // TODO: Implement actual save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Added to your saved list' : 'Removed from your saved list'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onBlinkButtonPressed() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => SelectionPage(widget.movie.title),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: true,
      child: Scaffold(
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image with gradient overlay and movie title
              Stack(
                children: [
                  CachedNetworkImage(
                    height: screenHeight / 3,
                    width: screenWidth,
                    imageUrl: widget.movie.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 60, color: Colors.grey),
                    ),
                  ),
                  // Back button
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
                  // Gradient overlay for text readability
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
                            // Movie title
                            AutoSizeText(
                              widget.movie.title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              minFontSize: 22,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Movie stats (rating and year)
                            Row(
                              children: [
                                Text(
                                  '${widget.movie.formattedRating}',
                                  style: const TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 15),
                                ),
                                SizedBox(width: screenWidth / 110),
                                const Icon(Icons.star, color: Color.fromARGB(255, 183, 236, 236), size: 20),
                                SizedBox(width: screenWidth / 110),
                                Text(
                                  widget.movie.formattedReleaseYear,
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
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LabeledIconButton(
                      onPressed: _launchIMDb,
                      icon: Icons.movie_outlined,
                      label: 'IMDb',
                    ),
                    LabeledIconButton(
                      onPressed: _launchTrailer,
                      icon: Icons.play_arrow_rounded,
                      label: 'Trailer',
                    ),
                    LabeledIconButton(
                      onPressed: _toggleSave,
                      icon: _isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                      label: 'Save',
                    ),
                  ],
                ),
              ),
              // Movie details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview section
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.overview,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    // Genre tags section
                    const SizedBox(height: 16),
                    const Text(
                      'Genres',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.movie.genres.isNotEmpty ? 
                        widget.movie.genres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          );
                        }).toList() : 
                        [const Chip(
                          label: Text('Not Available'),
                          backgroundColor: Color.fromARGB(255, 220, 220, 220),
                        )],
                    ),
                    
                    // Additional Details section
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
                              widget.movie.runtime > 0 
                                ? widget.movie.formattedRuntime 
                                : 'Not Available',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // "Friends who saved" section (placeholder for now)
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          child: Column(
                            children: [
                              Text(
                                '0', // Placeholder - would be dynamic in production
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'friends also saved this',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Streaming platforms section (placeholder for future implementation)
                    const SizedBox(height: 16),
                    const Text(
                      'Available On',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Information not available', // Placeholder - would be populated with actual data
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 84), // Space for floating action button
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