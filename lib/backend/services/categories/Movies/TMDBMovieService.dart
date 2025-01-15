import 'dart:convert';

import 'package:blink_v1/backend/services/categories/Movies/MediaSearchResult.dart';
import 'package:blink_v1/models/categories/Movie.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBMovieService {
  final String _apiKey;
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final Map<String, List<Movie>> _cache = {};

  TMDBMovieService() : _apiKey = dotenv.env['TMDB_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('TMDB_API_KEY not found in .env file');
    }
  }

  String get apiKey => _apiKey;
  String get baseUrl => _baseUrl;

  Future<List<Movie>> getMovieRecommendations({
    List<String>? genres,
    List<String>? platforms,
    List<PersonSearchResult>? people,
    List<MediaSearchResult>? similarMovies,
    double? minRating,
    double? maxRating,
    String? releaseYear,
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
      'vote_average.gte': minRating?.toString(),
      'vote_average.lte': maxRating?.toString(),
      'primary_release_year': releaseYear,
    };

    queryParameters.removeWhere((key, value) => value == null);

    var uri = Uri.parse('$_baseUrl/discover/movie')
        .replace(queryParameters: queryParameters);
    final cacheKey = uri.toString();

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<Movie> movies = [];
        final results = json.decode(response.body)['results'] as List;
        
        // Fetch additional details for each movie to get runtime
        for (var result in results) {
          final movieId = result['id'].toString();
          final detailsUri = Uri.parse('$_baseUrl/movie/$movieId')
              .replace(queryParameters: {'api_key': _apiKey});
          
          try {
            final detailsResponse = await http.get(detailsUri);
            if (detailsResponse.statusCode == 200) {
              final movieDetails = json.decode(detailsResponse.body);
              // Merge the movie details with the original result
              final movieData = Map<String, dynamic>.from(result)
                ..['runtime'] = movieDetails['runtime'];
              movies.add(Movie.fromJson(movieData));
            }
          } catch (e) {
            print('Error fetching details for movie $movieId: $e');
            // Add movie without runtime if details fetch fails
            movies.add(Movie.fromJson(result));
          }
        }

        // Handle platform filtering if specified
        var filteredMovies = movies;
        if (platforms != null && platforms.isNotEmpty) {
          filteredMovies = await _filterByPlatforms(movies, platforms);
        }

        // Handle similar movies if specified
        if (similarMovies != null && similarMovies.isNotEmpty) {
          filteredMovies = await _getSimilarMovies(similarMovies, filteredMovies);
        }

        _cache[cacheKey] = filteredMovies;
        return filteredMovies;
      } else {
        throw Exception('Failed to get recommendations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Movie>> _filterByPlatforms(List<Movie> movies, List<String> platforms) async {
    final filteredMovies = <Movie>[];
    
    for (var movie in movies) {
      final watchProvidersUri = Uri.parse(
        '$_baseUrl/movie/${movie.id}/watch/providers'
      ).replace(queryParameters: {'api_key': _apiKey});
      
      try {
        final response = await http.get(watchProvidersUri);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results']['US']?['flatrate'] ?? [];
          final moviePlatforms = results.map((p) => p['provider_name'].toString()).toList();
          
          if (platforms.any((p) => moviePlatforms.contains(p))) {
            filteredMovies.add(movie);
          }
        }
      } catch (e) {
        print('Error fetching watch providers for movie ${movie.id}: $e');
      }
    }
    
    return filteredMovies;
  }

  Future<List<Movie>> _getSimilarMovies(List<MediaSearchResult> similarMovies, List<Movie> baseMovies) async {
    final allSimilarMovies = <Movie>[];
    
    for (var similarMovie in similarMovies) {
      final searchUri = Uri.parse('$_baseUrl/search/movie')
          .replace(queryParameters: {
            'api_key': _apiKey,
            'query': similarMovie.title,
          });
      
      try {
        final response = await http.get(searchUri);
        if (response.statusCode == 200) {
          final searchResults = json.decode(response.body)['results'] as List;
          if (searchResults.isNotEmpty) {
            final movieId = searchResults[0]['id'];
            // Fetch details for runtime
            final detailsUri = Uri.parse('$_baseUrl/movie/$movieId')
                .replace(queryParameters: {'api_key': _apiKey});
            final detailsResponse = await http.get(detailsUri);
            
            if (detailsResponse.statusCode == 200) {
              final movieDetails = json.decode(detailsResponse.body);
              final movieData = Map<String, dynamic>.from(searchResults[0])
                ..['runtime'] = movieDetails['runtime'];
              allSimilarMovies.add(Movie.fromJson(movieData));
            }
          }
        }
      } catch (e) {
        print('Error fetching similar movies for ${similarMovie.title}: $e');
      }
    }
    
    return [...baseMovies, ...allSimilarMovies]
      .toSet() // Remove duplicates
      .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  void clearCache() {
    _cache.clear();
  }
}