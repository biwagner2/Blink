import 'package:blink/backend/services/categories/Movies/MediaSearchResult.dart';

// A reusable class representing filter state for any media type
class MediaFilterState<P, M> {
  List<String> genres = [];
  List<String> platforms = [];
  List<P> people = [];
  List<M> similarMedia = [];
  double minRating = 0.0;
  double maxRating = 100.0;
  bool isRatingSelected = false;
  bool isGenreDropdownOpen = false;
  bool isPlatformDropdownOpen = false;
  
  // Additional fields for specific media types
  Map<String, dynamic> additionalFilters = {};

  // Creates a deep copy of the current state
  MediaFilterState<P, M> copy() {
    final newState = MediaFilterState<P, M>();
    newState.genres = List.from(genres);
    newState.platforms = List.from(platforms);
    newState.people = List.from(people);
    newState.similarMedia = List.from(similarMedia);
    newState.minRating = minRating;
    newState.maxRating = maxRating;
    newState.isRatingSelected = isRatingSelected;
    newState.isGenreDropdownOpen = isGenreDropdownOpen;
    newState.isPlatformDropdownOpen = isPlatformDropdownOpen;
    newState.additionalFilters = Map.from(additionalFilters);
    return newState;
  }

  // Resets all filter values to their defaults
  void reset() {
    genres = [];
    platforms = [];
    people = [];
    similarMedia = [];
    minRating = 0.0;
    maxRating = 100.0;
    isRatingSelected = false;
    isGenreDropdownOpen = false;
    isPlatformDropdownOpen = false;
    additionalFilters = {};
  }
}

// Specialized version for movie/show search results
class MediaSearchFilterState extends MediaFilterState<PersonSearchResult, MediaSearchResult> {
  //Can add additional fields here for movie/show search results if needed
}