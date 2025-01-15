import 'package:blink_v1/backend/services/categories/Movies/MediaSearchResult.dart';
import 'package:blink_v1/backend/services/categories/Movies/TMDBMovieService.dart';
import 'package:blink_v1/backend/services/categories/Movies/TMDBSearchService.dart';
import 'package:blink_v1/frontend/utility/CustomSliderShapes.dart';
import 'package:blink_v1/frontend/utility/SearchBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MovieFilterSelectionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const MovieFilterSelectionPage({Key? key, required this.onFilterChanged}) : super(key: key);

  @override
  _MovieFilterSelectionPageState createState() => _MovieFilterSelectionPageState();
}

class _MovieFilterSelectionPageState extends State<MovieFilterSelectionPage> {
  bool _isMovieSelected = true;
  final List<String> _selectedGenres = [];
  final List<String> _selectedPlatforms = [];
  bool _isGenreDropdownOpen = false;
  bool _isPlatformDropdownOpen = false;
  bool _isRatingDropdownOpen = false;
  final TMDBMovieService _tmdbService = TMDBMovieService();
  late TMDBPeopleSearchService _peopleSearchService;
  late TMDBMovieSearchService _movieSearchService;
  late TMDBShowSearchService _showSearchService;
  final List<PersonSearchResult> _selectedPeople = [];
  final List<MediaSearchResult> _selectedSimilarMovies = [];
  double _minRating = 0.0;
  double _maxRating = 100.0;
  bool _isRatingSelected = false;

  @override
  void initState() {
    super.initState();
    _peopleSearchService = TMDBPeopleSearchService(_tmdbService);
    _movieSearchService = TMDBMovieSearchService(_tmdbService);
    _showSearchService = TMDBShowSearchService(_tmdbService);
  }

  final List<String> _genreOptions = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family',
    'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance', 'Science Fiction', 'Thriller',
    'War', 'Western'
  ];

  final List<String> _platformOptions = [
    'Netflix', 'Max', 'Prime', 'Hulu', 'Disney+', 'Apple TV+', 'Paramount', 'Crunchyroll'
  ];

  void _toggleGenreDropdown() {
    setState(() {
      _isGenreDropdownOpen = !_isGenreDropdownOpen;
    });
  }

  void _togglePlatformDropdown() {
    setState(() {
      _isPlatformDropdownOpen = !_isPlatformDropdownOpen;
    });
  }

  void _toggleGenreSelection(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
    _updateFilters();
  }

  void _togglePlatformSelection(String platform) {
    setState(() {
      if (_selectedPlatforms.contains(platform)) {
        _selectedPlatforms.remove(platform);
      } else {
        _selectedPlatforms.add(platform);
      }
    });
    _updateFilters();
  }

  void _removeGenre(String genre) {
    setState(() {
      _selectedGenres.remove(genre);
    });
    _updateFilters();
  }

  void _removePlatform(String platform) {
    setState(() {
      _selectedPlatforms.remove(platform);
    });
    _updateFilters();
  }

  void _updateFilters() {
  widget.onFilterChanged({
    'genres': _selectedGenres,
    'platforms': _selectedPlatforms,
    'isMovie': _isMovieSelected,
    'people': _selectedPeople.map((person) => person.title).toList(),
    'similarMovies': _selectedSimilarMovies.map((movie) => movie.title).toList(),
    'minRating': _isRatingSelected ? _minRating : null,
    'maxRating': _isRatingSelected ? _maxRating : null,
  });
}

  void _removePerson(PersonSearchResult person) {
    setState(() {
      _selectedPeople.remove(person);
    });
    _updateFilters();
  }

  void _removeSimilarMovie(MediaSearchResult media) {
    setState(() {
      _selectedSimilarMovies.remove(media);
    });
    _updateFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
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
              const SizedBox(height: 24),
              _buildMovieShowToggle(),
              const SizedBox(height: 24),
              _buildGenreDropdown(),
              const SizedBox(height: 24),
              _buildPlatformDropdown(),
              const SizedBox(height: 24),
              _buildSearchButtons(),
              const SizedBox(height: 24),
              _buildRatingsDropdown(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleGenreDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width / 2.5,
            decoration: BoxDecoration(
              color: _selectedGenres.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _selectedGenres.isNotEmpty
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
                  _isGenreDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
        if (_isGenreDropdownOpen)
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
                final isSelected = _selectedGenres.contains(genre);
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
        if (_selectedGenres.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedGenres.map((genre) {
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
                      const SizedBox(width: 6),
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
              color: _selectedPlatforms.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _selectedPlatforms.isNotEmpty
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
                  _isPlatformDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
        if (_isPlatformDropdownOpen)
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
                final isSelected = _selectedPlatforms.contains(platform);
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
        if (_selectedPlatforms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedPlatforms.map((platform) {
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
              color: _selectedPeople.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _selectedPeople.isNotEmpty
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
        if (_selectedPeople.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedPeople.map((person) {
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
                        person.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontFamily: 'HammerSmithOne-Regular',
                        ),
                      ),
                      const SizedBox(width: 6),
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

        const SizedBox(height: 24),

        // Similar Movies Search Button
        GestureDetector(
          onTap: _showSimilarMoviesSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
              color: _selectedSimilarMovies.isNotEmpty
                  ? const Color.fromARGB(255, 183, 236, 236)
                  : Colors.white,
              border: _selectedSimilarMovies.isNotEmpty
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
        if (_selectedSimilarMovies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSimilarMovies.map((movie) {
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
                        movie.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontFamily: 'HammerSmithOne-Regular',
                        ),
                      ),
                      const SizedBox(width: 6),
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
        onSelect: (result) {
          final person = result as PersonSearchResult;
          // Create a unique identifier using both name and known department
          final uniqueId = '${person.title}_${person.subtitle ?? ""}';
          
          setState(() {
            // Check if a person with the same name and department already exists
            bool isDuplicate = _selectedPeople.any((existingPerson) => 
              '${existingPerson.title}_${existingPerson.subtitle ?? ""}' == uniqueId
            );
            
            if (!isDuplicate) {
              _selectedPeople.add(person);
            }
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
      builder: (context) => SearchBottomSheet(
        title: _isMovieSelected ? 'Search Similar Movies' : 'Search Similar Shows',
        hintText: _isMovieSelected ? 'Search for movies...' : 'Search for shows...',
        searchService: _isMovieSelected ? _movieSearchService : _showSearchService,
        onSelect: (result) {
          final media = result as MediaSearchResult;
          // Create a unique identifier using both title and release date
          final uniqueId = '${media.title}_${media.releaseDate}';
          
          setState(() {
            // Check if a media with the same title and date already exists
            bool isDuplicate = _selectedSimilarMovies.any((existingMedia) => 
              '${existingMedia.title}_${existingMedia.releaseDate}' == uniqueId
            );
            
            if (!isDuplicate) {
              _selectedSimilarMovies.add(media);
            }
          });
          _updateFilters();
        },
      ),
    );
  }

  Widget _buildRatingsDropdown() {
    String getRatingDisplay() {
      if (_minRating == _maxRating) {
        return '${_minRating.toInt()}%';
      } else {
        return '${_minRating.toInt()}% - ${_maxRating.toInt()}%';
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
            width: _isRatingSelected == false
                ? MediaQuery.of(context).size.width / 2.5 :
                  getRatingDisplay().length > 5 ? 
                  MediaQuery.of(context).size.width / 1.8 :
                  MediaQuery.of(context).size.width / 2.7,
            decoration: BoxDecoration(
              border: _isRatingSelected 
                  ? Border.all(color: Colors.transparent) 
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(25),
              color: _isRatingSelected 
                  ? const Color.fromARGB(255, 183, 236, 236) 
                  : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded( 
                  child: _isRatingSelected
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
                  SizedBox(height: deviceHeight/20 - 10),
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Move the slider to adjust the range you\'re looking for.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 84, 84, 84),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HammerSmithOne-Regular',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    child: SfSliderTheme(
                      data: const SfSliderThemeData(
                        activeTrackColor: Color.fromARGB(255, 183, 236, 236),
                        labelOffset: Offset(0, 55),
                      ),
                      child: SfRangeSlider(
                        min: 0.0,
                        max: 100.0,
                        interval: 20,
                        dragMode: SliderDragMode.onThumb,
                        values: SfRangeValues(_minRating, _maxRating),
                        showLabels: true,
                        activeColor: const Color.fromARGB(255, 183, 236, 236),
                        inactiveColor: const Color.fromARGB(255, 191, 191, 191),
                        stepSize: 1,
                        showDividers: true,
                        dividerShape: CustomDividerShape(),
                        trackShape: CustomTrackShape(),
                        thumbShape: CustomThumbShape(),
                        onChanged: (SfRangeValues values) {
                          setState(() {
                            _minRating = values.start;
                            _maxRating = values.end;
                          });
                        },
                      ),
                    )
                  ),
                  SizedBox(height: deviceHeight/20 - 10),
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
                        _isRatingSelected = true;
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