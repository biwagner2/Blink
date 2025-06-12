import 'package:blink/backend/services/utility/SearchService.dart';

class MediaSearchResult implements SearchResult {
  final String _title;
  final String? _posterPath;
  final String? _releaseDate;

  // Constructor
  MediaSearchResult({
    required String title, 
    String? posterPath, 
    String? releaseDate,
    }) : 
    _title = title, 
    _posterPath = posterPath, 
    _releaseDate = releaseDate;

  // Getters
  @override
  String get title => _title;
  
  String? get releaseDate => _releaseDate;

  @override
  String? get imageUrl => _posterPath != null 
    ? 'https://image.tmdb.org/t/p/w200$_posterPath' 
    : null;

  @override
  String? get subtitle => _releaseDate?.split('-')[0];
  
  // Add equals method to properly compare media items
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is MediaSearchResult &&
    runtimeType == other.runtimeType &&
    _title == other._title &&
    _releaseDate == other._releaseDate;

  @override
  int get hashCode => _title.hashCode ^ (_releaseDate?.hashCode ?? 0);
}




class MovieSearchResult extends MediaSearchResult {

  final int tmdbID;

  MovieSearchResult({
    required super.title,
    super.posterPath,
    super.releaseDate,
    required this.tmdbID
  });

}



 
class ShowSearchResult extends MediaSearchResult {
  final int tmdbID;

  ShowSearchResult({
    required super.title,
    super.posterPath,
    String? firstAirDate,
    required this.tmdbID
  }) : super(releaseDate: firstAirDate);
}



class PersonSearchResult implements SearchResult {
  final String _name;
  final String? _profilePath;
  final String? _knownForDepartment;
  final int tmdbID;

  PersonSearchResult({
    required String name,
    String? profilePath,
    String? knownForDepartment,
    required this.tmdbID
  }) :
    _name = name,
    _profilePath = profilePath,
    _knownForDepartment = knownForDepartment;

  @override
  String get title => _name;

  @override
  String? get imageUrl => _profilePath != null 
    ? 'https://image.tmdb.org/t/p/w200$_profilePath' 
    : null;

  @override
  String? get subtitle => _knownForDepartment;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is PersonSearchResult &&
    runtimeType == other.runtimeType &&
    _name == other._name &&
    _knownForDepartment == other._knownForDepartment;

  @override
  int get hashCode => _name.hashCode ^ (_knownForDepartment?.hashCode ?? 0);
}