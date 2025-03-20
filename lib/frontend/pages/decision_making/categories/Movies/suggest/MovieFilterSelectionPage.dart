import 'package:blink/backend/services/categories/Movies/MediaSearchResult.dart';
import 'package:blink/backend/services/categories/Movies/TMDBMovieService.dart';
import 'package:blink/backend/services/categories/Movies/TMDBSearchService.dart';
import 'package:blink/frontend/utility/CustomSliderShapes.dart';
import 'package:blink/frontend/utility/MediaFilterState.dart';
import 'package:blink/frontend/utility/SearchBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:blink/frontend/utility/GridSearchBottomSheet.dart';

class MovieFilterSelectionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const MovieFilterSelectionPage({super.key, required this.onFilterChanged});

  @override
  MovieFilterSelectionPageState createState() => MovieFilterSelectionPageState();
}

class MovieFilterSelectionPageState extends State<MovieFilterSelectionPage> {
  bool _isMovieSelected = true;
  
  // Separate filter states for movies and shows
  final MediaSearchFilterState _movieFilters = MediaSearchFilterState();
  final MediaSearchFilterState _showFilters = MediaSearchFilterState();
  
  // Current active filter state based on selection
  MediaSearchFilterState get _activeFilters => _isMovieSelected ? _movieFilters : _showFilters;
  
  final TMDBMovieService _tmdbService = TMDBMovieService();
  late TMDBPeopleSearchService _peopleSearchService;
  late TMDBMovieSearchService _movieSearchService;
  late TMDBShowSearchService _showSearchService;

  final List<String> _genreOptions = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family',
    'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance', 'Science Fiction', 'Thriller',
    'War', 'Western'
  ];

  final List<String> _platformOptions = [
    'Netflix', 'Max', 'Prime', 'Hulu', 'Disney+', 'Apple TV+', 'Paramount', 'Crunchyroll'
  ];

  @override
void initState() {
  super.initState();
  _peopleSearchService = TMDBPeopleSearchService(_tmdbService);
  _movieSearchService = TMDBMovieSearchService(_tmdbService);
  _showSearchService = TMDBShowSearchService(_tmdbService);
  
  // Safely updates filters after widget building is complete
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _updateFilters();
  });
}

  // Toggles the genre dropdown visibility
  void _toggleGenreDropdown() {
    setState(() {
      _activeFilters.isGenreDropdownOpen = !_activeFilters.isGenreDropdownOpen;
    });
  }

  // Toggles the platform dropdown visibility
  void _togglePlatformDropdown() {
    setState(() {
      _activeFilters.isPlatformDropdownOpen = !_activeFilters.isPlatformDropdownOpen;
    });
  }

  // Toggles selection for a specific genre
  void _toggleGenreSelection(String genre) {
    setState(() {
      if (_activeFilters.genres.contains(genre)) {
        _activeFilters.genres.remove(genre);
      } else {
        _activeFilters.genres.add(genre);
      }
    });
    _updateFilters();
  }

  // Toggles selection for a specific platform
  void _togglePlatformSelection(String platform) {
    setState(() {
      if (_activeFilters.platforms.contains(platform)) {
        _activeFilters.platforms.remove(platform);
      } else {
        _activeFilters.platforms.add(platform);
      }
    });
    _updateFilters();
  }

  // Removes a genre from selected genres
  void _removeGenre(String genre) {
    setState(() {
      _activeFilters.genres.remove(genre);
    });
    _updateFilters();
  }

  // Removes a platform from selected platforms
  void _removePlatform(String platform) {
    setState(() {
      _activeFilters.platforms.remove(platform);
    });
    _updateFilters();
  }

  // Updates filter values and notifies parent component
  void _updateFilters() {
    widget.onFilterChanged({
      'genres': _activeFilters.genres,
      'platforms': _activeFilters.platforms,
      'isMovie': _isMovieSelected,
      'people': _activeFilters.people.map((person) => person.title).toList(),
      'similarMedia': _activeFilters.similarMedia.map((media) => media.title).toList(),
      'minRating': _activeFilters.isRatingSelected ? _activeFilters.minRating : null,
      'maxRating': _activeFilters.isRatingSelected ? _activeFilters.maxRating : null,
    });
  }

  // Removes a person from selected people
  void _removePerson(PersonSearchResult person) {
    setState(() {
      _activeFilters.people.remove(person);
    });
    _updateFilters();
  }

  // Removes a similar media item from selection
  void _removeSimilarMovie(MediaSearchResult media) {
    setState(() {
      _activeFilters.similarMedia.remove(media);
    });
    _updateFilters();
  }

  // Resets all filters to default values
  void resetFilters() {
    setState(() {
      _movieFilters.reset();
      _showFilters.reset();
    });
    _updateFilters();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: deviceHeight/175),
               const Text(
                'You have your criteria. Let us make you a recommendation.',
                softWrap: true,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'HammerSmithOne-Regular',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: deviceHeight/36.5),
              _buildMovieShowToggle(),
              SizedBox(height: deviceHeight/36.5),
              _buildGenreDropdown(),
              SizedBox(height: deviceHeight/36.5),
              _buildPlatformDropdown(),
              SizedBox(height: deviceHeight/36.5),
              _buildSearchButtons(),
              SizedBox(height: deviceHeight/36.5),
              _buildRatingsDropdownButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieShowToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color.fromARGB(255, 161, 161, 161)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isMovieSelected = true;
                  _updateFilters();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isMovieSelected ? Colors.cyan[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Movies',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isMovieSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isMovieSelected = false;
                  _updateFilters();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isMovieSelected ? Colors.cyan[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Shows',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: !_isMovieSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreDropdown() {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleGenreDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width / 2.5,
            decoration: BoxDecoration(
              color: _activeFilters.genres.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _activeFilters.genres.isNotEmpty
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width / 500),
                const Text(
                  "Genre",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _activeFilters.isGenreDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
        if (_activeFilters.isGenreDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _genreOptions.map((genre) {
                final isSelected = _activeFilters.genres.contains(genre);
                return GestureDetector(
                  onTap: () => _toggleGenreSelection(genre),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 183, 236, 236)
                          : Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'HammerSmithOne-Regular',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (_activeFilters.genres.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activeFilters.genres.map((genre) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 137, 137, 137)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        genre,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontFamily: 'HammerSmithOne-Regular',
                        ),
                      ),
                      SizedBox(width: deviceWidth/67),
                      GestureDetector(
                        onTap: () => _removeGenre(genre),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPlatformDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _togglePlatformDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width / 2.2,
            decoration: BoxDecoration(
              color: _activeFilters.platforms.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _activeFilters.platforms.isNotEmpty
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width / 500),
                const Text(
                  "Platform",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _activeFilters.isPlatformDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
        if (_activeFilters.isPlatformDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _platformOptions.map((platform) {
                final isSelected = _activeFilters.platforms.contains(platform);
                return GestureDetector(
                  onTap: () => _togglePlatformSelection(platform),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 183, 236, 236)
                          : Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      platform,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'HammerSmithOne-Regular',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (_activeFilters.platforms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activeFilters.platforms.map((platform) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 137, 137, 137)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        platform,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontFamily: 'HammerSmithOne-Regular',
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removePlatform(platform),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchButtons() {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // People Search Button
        GestureDetector(
          onTap: _showPeopleSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width / 2.5,
            decoration: BoxDecoration(
              color: _activeFilters.people.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _activeFilters.people.isNotEmpty
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width / 500),
                const Text(
                  "People",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_activeFilters.people.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activeFilters.people.map((person) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 137, 137, 137)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: deviceWidth/1.5),
                        child: Text(
                          person.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 101, 101, 101),
                            fontFamily: 'HammerSmithOne-Regular',
                          ),
                        ),
                      ),
                      SizedBox(width: deviceWidth/67),
                      GestureDetector(
                        onTap: () => _removePerson(person),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        SizedBox(height: deviceHeight/36.5),

        // Similar Movies Search Button
        GestureDetector(
          onTap: _showSimilarMoviesSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
              color: _activeFilters.similarMedia.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _activeFilters.similarMedia.isNotEmpty
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width / 500),
                Text(
                  _isMovieSelected ? "Movies Similar To" : "Shows Similar To",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_activeFilters.similarMedia.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activeFilters.similarMedia.map((movie) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 137, 137, 137)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: deviceWidth/1.5),
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 101, 101, 101),
                            fontFamily: 'HammerSmithOne-Regular',
                          ),
                          overflow: TextOverflow.ellipsis,
                          
                        ),
                      ),
                      SizedBox(width: deviceWidth/67),
                      GestureDetector(
                        onTap: () => _removeSimilarMovie(movie),
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showPeopleSearch() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SearchBottomSheet(
      title: 'Search People',
      hintText: 'Search for actors or directors...',
      searchService: _peopleSearchService,
      initialSelections: _activeFilters.people, // Pass current selections
      onSave: (selectedResults) {
        setState(() {
          // Update with the complete list of selections
          _activeFilters.people = List<PersonSearchResult>.from(
            selectedResults.map((result) => result as PersonSearchResult)
          );
        });
        _updateFilters();
      },
    ),
  );
}

  void _showSimilarMoviesSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GridSearchBottomSheet(
        title: _isMovieSelected ? 'Movies Similar To' : 'Shows Similar To',
        hintText: _isMovieSelected ? 'Search for movies...' : 'Search for shows...',
        searchService: _isMovieSelected ? _movieSearchService : _showSearchService,
        initialSelections: _activeFilters.similarMedia, // Pass current selections
        onSave: (selectedResults) {
          setState(() {
            // Update with the complete list of selections
            _activeFilters.similarMedia = List<MediaSearchResult>.from(selectedResults);
          });
          _updateFilters();
        },
      ),
    );
  }

  Widget _buildRatingsDropdownButton() {
    String getRatingDisplay() {
      if (_activeFilters.minRating == _activeFilters.maxRating) {
        return '${_activeFilters.minRating.toInt()}%';
      } else {
        return '${_activeFilters.minRating.toInt()}% - ${_activeFilters.maxRating.toInt()}%';
      }
    }
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showRatingsBottomSheet,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8, left: 31),
            width: _activeFilters.isRatingSelected == false
                ? MediaQuery.of(context).size.width / 2.5 :
                  getRatingDisplay().length > 5 ? 
                  MediaQuery.of(context).size.width / 1.8 :
                  MediaQuery.of(context).size.width / 2.7,
            decoration: BoxDecoration(
              border: _activeFilters.isRatingSelected 
                  ? Border.all(color: Colors.transparent) 
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
              color: _activeFilters.isRatingSelected 
                  ? const Color.fromARGB(255, 183, 236, 236) 
                  : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded( 
                  child: _activeFilters.isRatingSelected
                      ? Text(
                          getRatingDisplay(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          "Rating",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRatingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final deviceHeight = MediaQuery.of(context).size.height;
            final deviceWidth = MediaQuery.of(context).size.width;
            return Container(
              height: deviceHeight / 2.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: deviceWidth * 0.2,
                    height: deviceHeight / 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  SizedBox(height: deviceHeight/20 - 20),
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: deviceHeight/87.4),
                  const Text(
                    'Move the slider to adjust the range you\'re looking for.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 84, 84, 84),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HammerSmithOne-Regular',
                    ),
                  ),
                  SizedBox(height: deviceHeight/109),
                  SizedBox(
                    child: SfSliderTheme(
                      data: const SfSliderThemeData(
                        activeTrackColor: Color.fromARGB(255, 183, 236, 236),
                        labelOffset: Offset(0, 55),
                      ),
                      child: SfRangeSlider(
                        min: 0.0,
                        max: 100.0,
                        interval: 100,
                        dragMode: SliderDragMode.onThumb,
                        values: SfRangeValues(_activeFilters.minRating, _activeFilters.maxRating),
                        showLabels: false,
                        activeColor: const Color.fromARGB(255, 183, 236, 236),
                        inactiveColor: const Color.fromARGB(255, 191, 191, 191),
                        stepSize: 1,
                        showDividers: true,
                        dividerShape: CustomDividerShape(),
                        trackShape: CustomTrackShape(),
                        thumbShape: CustomThumbShape(),
                        onChanged: (SfRangeValues values) {
                          setState(() {
                            _activeFilters.minRating = values.start;
                            _activeFilters.maxRating = values.end;
                          });
                        },
                      ),
                    )
                  ),
                  SizedBox(
                    height: deviceHeight/20 - 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: deviceWidth/22),
                        const Text(
                          '0%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'HammerSmithOne-Regular',
                          ),
                        ),
                        SizedBox(width: deviceWidth/4.4),
                        SizedBox(width: deviceWidth/3.2,
                          child: Center(
                            child: Text(
                                '${_activeFilters.minRating.toInt()}% - ${_activeFilters.maxRating.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ),
                        ),
                        SizedBox(width: deviceWidth/5.6),
                        const Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'HammerSmithOne-Regular',
                          ),
                        ),
                      ],
                    )
                  ),
                  SizedBox(height: deviceHeight/45 - 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(deviceWidth/1.5, deviceHeight/20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      this.setState(() {
                        _activeFilters.isRatingSelected = true;
                      });
                      _updateFilters();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}