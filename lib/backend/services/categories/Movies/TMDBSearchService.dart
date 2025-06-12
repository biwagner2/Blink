import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blink/backend/services/categories/Movies/MediaSearchResult.dart';
import 'package:blink/backend/services/categories/Movies/TMDBMovieService.dart';
import 'package:blink/backend/services/utility/SearchService.dart';

class TMDBMovieSearchService implements SearchService {
  final TMDBMovieService _tmdbService;

  TMDBMovieSearchService(this._tmdbService);

  // Searches for specific movie by name
  @override
  Future<List<SearchResult>> search(String query) async {
    final uri = Uri.parse('${_tmdbService.baseUrl}/search/movie').replace(
      queryParameters: {
        'api_key': _tmdbService.apiKey,
        'query': query,
        'language': 'en-US',
        'page': '1',
        'include_adult': 'false',
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List).map((movie) => MovieSearchResult(
          title: movie['title'],
          posterPath: movie['poster_path'],
          releaseDate: movie['release_date'],
          tmdbID: movie['id'],
        )).toList();
      }
      throw Exception('Failed to search movies: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}


class TMDBShowSearchService implements SearchService {
  final TMDBMovieService _tmdbService;

  TMDBShowSearchService(this._tmdbService);

  // Searches for specific show by name
  @override
  Future<List<SearchResult>> search(String query) async {
    final uri = Uri.parse('${_tmdbService.baseUrl}/search/tv').replace(
      queryParameters: {
        'api_key': _tmdbService.apiKey,
        'query': query,
        'language': 'en-US',
        'page': '1', 
        'include_adult': 'false',
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List).map((show) => ShowSearchResult(
          title: show['name'],
          posterPath: show['poster_path'],
          firstAirDate: show['first_air_date'],
          tmdbID: show['id'],
        )).toList();
      }
      throw Exception('Failed to search shows: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}


class TMDBPeopleSearchService implements SearchService {
  final TMDBMovieService _tmdbService;

  TMDBPeopleSearchService(this._tmdbService);

  // Searches for specific person by name
  @override
  Future<List<SearchResult>> search(String query) async {
    final uri = Uri.parse('${_tmdbService.baseUrl}/search/person').replace(
      queryParameters: {
        'api_key': _tmdbService.apiKey,
        'query': query,
        'language': 'en-US',
        'page': '1',
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List).map((person) => PersonSearchResult(
          name: person['name'],
          tmdbID: person['id'],
          profilePath: person['profile_path'],
          knownForDepartment: person['known_for_department'],
        )).toList();
      }
      throw Exception('Failed to search people: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}