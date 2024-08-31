import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class MovieFilterSelectionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const MovieFilterSelectionPage({Key? key, required this.onFilterChanged}) : super(key: key);

  @override
  _MovieFilterSelectionPageState createState() => _MovieFilterSelectionPageState();
}

class _MovieFilterSelectionPageState extends State<MovieFilterSelectionPage> {
  String? _selectedGenre;
  String? _selectedReleaseYear;
  double _minRating = 5.0;
  String? _selectedSortBy;

  final List<String> _genreOptions = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family',
    'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance', 'Science Fiction', 'Thriller',
    'War', 'Western'
  ];

  final List<String> _releaseYearOptions = [
    '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016', '2015',
    '2010-2014', '2000-2009', '1990-1999', '1980-1989', 'Before 1980'
  ];

  final List<String> _sortByOptions = [
    'Popularity', 'Release Date', 'Vote Average', 'Vote Count'
  ];

  void _updateFilters() {
    widget.onFilterChanged({
      'genres': _selectedGenre != null ? [_selectedGenre] : null,
      'releaseYear': _selectedReleaseYear,
      'minRating': _minRating,
      'sortBy': _convertSortBy(_selectedSortBy),
    });
  }

  String? _convertSortBy(String? sortBy) {
    switch (sortBy?.toLowerCase()) {
      case 'popularity':
        return 'popularity.desc';
      case 'release date':
        return 'release_date.desc';
      case 'vote average':
        return 'vote_average.desc';
      case 'vote count':
        return 'vote_count.desc';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              _buildGenreDropdown(),
              const SizedBox(height: 24),
              _buildReleaseYearDropdown(),
              const SizedBox(height: 24),
              _buildSortByDropdown(),
              const SizedBox(height: 24),
              _buildRatingsSlider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Genre",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedGenre,
            hint: const Text("Select a genre"),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGenre = newValue;
              });
              _updateFilters();
            },
            items: _genreOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseYearDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Release Year",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedReleaseYear,
            hint: const Text("Select a release year"),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedReleaseYear = newValue;
              });
              _updateFilters();
            },
            items: _releaseYearOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSortByDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sort By",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedSortBy,
            hint: const Text("Select sort order"),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSortBy = newValue;
              });
              _updateFilters();
            },
            items: _sortByOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Minimum Rating",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SfSliderTheme(
          data: SfSliderThemeData(
            activeTrackColor: const Color.fromARGB(255, 183, 236, 236),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.white,
            overlayColor: const Color.fromARGB(30, 183, 236, 236),
            tickOffset: const Offset(0, 8),
          ),
          child: SfSlider(
            min: 0.0,
            max: 10.0,
            value: _minRating,
            interval: 1,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            minorTicksPerInterval: 0,
            onChanged: (dynamic value) {
              setState(() {
                _minRating = value;
              });
              _updateFilters();
            },
          ),
        ),
      ],
    );
  }
}