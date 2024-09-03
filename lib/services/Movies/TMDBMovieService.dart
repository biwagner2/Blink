import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:blink_v1/models/categories/Movie.dart';

class TMDBMovieService {
  final String _apiKey;
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final Map<String, List<Movie>> _cache = {};

  TMDBMovieService() : _apiKey = dotenv.env['TMDB_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('TMDB_API_KEY not found in .env file');
    }
  }

  Future<List<Movie>> getMovieRecommendations({
    List<String>? genres,
    String? releaseYear,
    double? minRating,
    String? sortBy,
  }) async {
    final queryParameters = {
      'api_key': _apiKey,
      'language': 'en-US',
      'sort_by': sortBy ?? 'popularity.desc',
      'include_adult': 'false',
      'include_video': 'false',
      'page': '1',
      'with_genres': genres?.join(','),
      'primary_release_year': releaseYear,
      'vote_average.gte': minRating?.toString(),
    };

    queryParameters.removeWhere((key, value) => value == null);

    final uri = Uri.parse('$_baseUrl/discover/movie').replace(queryParameters: queryParameters);
    final cacheKey = uri.toString();

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
        _cache[cacheKey] = movies;
        return movies;
      } else {
        throw Exception('Failed to get recommendations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void clearCache() {
    _cache.clear();
  }
}