import 'package:auto_size_text/auto_size_text.dart';
import 'package:blink/frontend/navigation/blinkButton.dart';
import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:blink/frontend/pages/decision_making/categories/selectionPage.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/profile/profilePage.dart';
import 'package:blink/frontend/utility/labeledIconButton.dart';
import 'package:blink/models/icons/my_flutter_app_icons.dart';
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
    final Uri url = Uri.parse('https://www.imdb.com/title/${widget.movie.imdbId}/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchRottenTomatoes(String title) async {
    // Generate a Rotten Tomatoes-style slug from the movie title
    String slug = title
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s]"), '') // Remove non-word characters
        .replaceAll(RegExp(r"\s+"), '_');   // Replace spaces with underscores

    final Uri url = Uri.parse("https://www.rottentomatoes.com/m/$slug");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchTrailer() async {
    if (widget.movie.trailerKey.isNotEmpty) 
    {
      final Uri url = Uri.parse('https://www.youtube.com/watch?v=${widget.movie.trailerKey}');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } 
    else {
      final Uri fallback = Uri.parse(
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent("${widget.movie.title} trailer ${widget.movie.formattedReleaseYear}")}'
      );
      if (!await launchUrl(fallback, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $fallback');
      }
    }
  }

  final Map<String, String> platformSearchUrls = {
    'amazon video': 'https://www.amazon.com/s?k=',
    'apple tv': 'https://tv.apple.com/search?term=',
    'google play movies': 'https://play.google.com/store/search?q=',
    'youtube': 'https://www.youtube.com/results?search_query=',
    'fandango at home': 'https://www.vudu.com/content/movies/search?searchString=',
    'spectrum on demand': 'https://watch.spectrum.net/search?q=',
    'plex': 'https://watch.plex.tv/search?q=',
    'mgm plus': 'https://www.mgmplus.com/search/',
    'netflix': 'https://www.netflix.com/search?q=',
    'max': 'https://play.max.com/search?q=',
    'hulu': 'https://www.hulu.com/search?q=',
    'disney+': 'https://www.disneyplus.com/search/',
    'apple tv+': 'https://tv.apple.com/search?term=',
    'paramount': 'https://www.paramountplus.com/shows/?q=',
    'crunchyroll': 'https://www.crunchyroll.com/search?from=&q=',
    'peacock': 'https://www.peacocktv.com/search?q=',
    'tubi': 'https://tubitv.com/search?query=',
    'pluto tv': 'https://pluto.tv/search?q=',
    'netflix standard with ads': 'https://www.netflix.com/search?q=',
  };



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
                  // Movie Poster
                  CachedNetworkImage(
                    imageUrl: widget.movie.imageUrl,
                    width: screenWidth,
                    height: screenHeight / 3,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 60, color: Colors.grey),
                    ),
                  ),

                  // Back Button
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

                  // Bottom Overlay with Info
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: screenHeight / 4.5,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
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
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight / 142),

                          // Sub-info Row
                          Row(
                            children: [
                              Text(
                                widget.movie.rottenTomatoesScore,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Open Sans', fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: screenHeight / 142),
                              const Icon(Icons.favorite, color: Color.fromARGB(255, 183, 236, 236), size: 18),
                              SizedBox(width: screenHeight / 142),
                              Text(
                                widget.movie.formatReviewCount(),
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Open Sans', fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (widget.movie.trailerKey.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: _launchTrailer,
                        icon: const Icon(Icons.play_arrow_rounded),
                        iconAlignment: IconAlignment.end,
                        label: const Text('Play trailer', style: TextStyle(fontSize: 12, fontFamily: 'Open Sans', fontWeight: FontWeight.w500)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(left: 8, bottom: 4, top: 4, right: 4),
                          backgroundColor: Colors.black.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero, // Prevent extra height/width
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, size: 22,),
                    SizedBox(width: screenWidth / 100),
                    Text(widget.movie.formattedRuntime, 
                        style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold")
                    ),
                    SizedBox(width: screenWidth / 110),
                    const Icon(Icons.circle, size: 8,),
                    SizedBox(width: screenWidth / 110),
                    Text(widget.movie.formattedReleaseYear,
                        style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold")
                    ),
                    SizedBox(width: screenWidth / 110),
                    const Icon(Icons.circle, size: 8,),
                    SizedBox(width: screenWidth / 110),
                    Text(widget.movie.genres.length >= 2
                          ? '${widget.movie.genres[0]}/${widget.movie.genres[1]}'
                          : widget.movie.genres[0],
                      style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold"),
                    ),
                    SizedBox(width: screenWidth / 110),
                    const Icon(Icons.circle, size: 8,),
                    SizedBox(width: screenWidth / 110),
                    Text(widget.movie.rated!,
                        style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold")
                    )
                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AutoSizeText(
                  widget.movie.overview,
                  style: const TextStyle(fontSize: 13, fontFamily: "OpenSans", height: 1.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LabeledIconButton(
                      onPressed: () => _launchRottenTomatoes(widget.movie.title),
                      pngAsset: "assets/images/rotten-tomatoes.png",
                      label: widget.movie.rottenTomatoesScore,
                      iconSize: screenHeight /23,
                    ),
                    LabeledIconButton(
                      onPressed: _launchIMDb,
                      pngAsset: "assets/images/imdb.png",
                      label: "${widget.movie.imdbRating}/10",
                      iconSize: screenHeight / 19,
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
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: const Color.fromRGBO(209, 209, 209, 1), width: 1.1),
                      ),
                      height: screenWidth/5,
                      width: screenWidth/2.8,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '0', //Eventually make it a counter variable. Maybe convert numbers into 1K, 21.6K format etc. 
                            style: TextStyle(fontSize: 25, fontFamily: "OpenSans",)
                          ),
                          Text(
                            'friends also saved this',
                            style: TextStyle(fontSize: 10, fontFamily: "OpenSans", color: Color.fromRGBO(120, 120, 120, 1))
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Platforms', style: TextStyle(fontSize: 22)),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: "OpenSans",
                                color: Colors.black,
                              ),
                              children: widget.movie.providers.isEmpty
                                  ? [const TextSpan(text: 'Only in Theaters')]
                                  : [
                                      for (int i = 0; i < widget.movie.providers.length && i < 3; i++) ...[
                                        TextSpan(text: widget.movie.providers[i]),
                                        if (i < widget.movie.providers.length - 1 && i < 2)
                                          const TextSpan(text: ' • '),
                                      ]
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Available On', textAlign: TextAlign.center),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: 
                                  widget.movie.providers.isEmpty ?
                                  [
                                    const Text('Only in Theaters', style: TextStyle(fontSize: 16, fontFamily: "OpenSans")),
                                  ] 
                                  :
                                  [ ... widget.movie.providers.map((provider) 
                                    {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: provider,
                                                      style: const TextStyle(fontSize: 16, fontFamily: "OpenSans", fontWeight: FontWeight.bold, color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () async {
                                                final String title = Uri.encodeComponent(widget.movie.title);
                                                final String? baseUrl = platformSearchUrls[provider.toLowerCase()];
                                                if (baseUrl != null) {
                                                  final Uri uri = Uri.parse('$baseUrl$title');
                                                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                                    throw Exception('Could not launch $uri');
                                                  }
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black),
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Watch",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.play_circle_outlined,
                                                      color: Colors.black,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Close', style: TextStyle(fontSize: 18)),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Image.asset(
                        'assets/images/icons8-arrow-right-96.png',
                        height: screenWidth / 13,
                        width: screenWidth / 13,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cast', style: TextStyle(fontSize: 22)),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 15, fontFamily: "OpenSans", color: Colors.black),
                              children: [
                                const TextSpan(
                                  text: "Director: ",
                                  style: TextStyle(fontFamily: "HammersmithOne"),
                                ),
                                TextSpan(
                                  text: widget.movie.cast.isNotEmpty
                                      ? widget.movie.cast[0].name
                                      : 'N/A',
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 15, fontFamily: "OpenSans", color: Colors.black),
                              children: [
                                const TextSpan(
                                  text: "Starring: ",
                                  style: TextStyle(fontFamily: "HammersmithOne"),
                                ),
                                TextSpan(
                                  text: widget.movie.cast.length > 1
                                      ? widget.movie.cast
                                          .skip(1)
                                          .take(3)
                                          .map((actor) => actor.name)
                                          .join(" | ")
                                      : 'N/A',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Icon Button
                    IconButton(
                      onPressed: _launchIMDb,
                      icon: Image.asset(
                        'assets/images/icons8-arrow-right-96.png',
                        height: screenWidth / 13,
                        width: screenWidth / 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                icon: Image.asset("assets/images/blink-icon-color.png", height: 0),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svgs/Profile.svg", height: screenHeight / 21.3),
                label: '',
              ),
            ],
          ),
        ),
      )
    );
  }
}