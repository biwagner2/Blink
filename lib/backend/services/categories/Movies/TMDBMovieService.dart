import 'dart:convert';
import 'package:blink/models/categories/Movie.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Service class for fetching movie and show data from The Movie Database (TMDB) API...
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

  // Fetches movie recommendations based on the provided filters...
  Future<List<Movie>> getMovieRecommendations({
    List<String>? genres,
    List<String>? platforms,
    List<String>? people,
    List<String>? similarMovies,
    double? minRating,
    double? maxRating,
    String? releaseYear,
    String? sortBy,
  }) async {
    List<Movie> finalResults = [];
    
    // First handle similar movies filter if provided by user
    if (similarMovies != null && similarMovies.isNotEmpty) {
      for (final title in similarMovies) {
        final similarMoviesList = await _getSimilarMoviesRecommendations(title);
        finalResults.addAll(similarMoviesList);
      }
    }
    
    // Second handle people filter if provided by user
    if (people != null && people.isNotEmpty) {
      for (final person in people) {
        final personMoviesList = await _getMoviesByPerson(person);
        finalResults.addAll(personMoviesList);
      }
    }
    
    // If user doesn't filter by similar movies or by people, can just use discover endpoint
    if ((similarMovies == null || similarMovies.isEmpty) && 
        (people == null || people.isEmpty)) {
      // Convert genre names to TMDB genre IDs
      final Map<String, int> genreMapping = await _getGenreMapping();
      final List<String> genreIds = [];
      
      if (genres != null) {
        for (final genre in genres) {
          if (genreMapping.containsKey(genre)) {
            genreIds.add(genreMapping[genre].toString());
          }
        }
      }

      // Build standard discover query
      final queryParameters = {
        'api_key': _apiKey,
        'language': 'en-US',
        'sort_by': sortBy ?? 'popularity.desc',
        'include_adult': 'false', // Exclude adult content
        'include_video': 'false',
        'page': '1',
        'with_genres': genreIds.isNotEmpty ? genreIds.join(',') : null,
        'vote_average.gte': minRating != null ? (minRating / 10).toString() : null, // TMDB uses 0-10 scale
        'vote_average.lte': maxRating != null ? (maxRating / 10).toString() : null, // TMDB uses 0-10 scale
        'primary_release_year': releaseYear,
      };

      queryParameters.removeWhere((key, value) => value == null);
      
      final uri = Uri.parse('$_baseUrl/discover/movie')
          .replace(queryParameters: queryParameters);
      final cacheKey = uri.toString();

      if (_cache.containsKey(cacheKey)) {
        finalResults.addAll(_cache[cacheKey]!);
      } else {
        try {
          final response = await http.get(uri);
          
          if (response.statusCode == 200) {
            final results = json.decode(response.body)['results'] as List;
            
            if (results.isNotEmpty) {
              // Add to cache and enrich with details
              final List<Movie> movies = await _enrichMoviesWithDetails(results);
              _cache[cacheKey] = movies;
              finalResults.addAll(movies);
            }
          }
        } catch (e) {
          print('Error in discover movies: $e');
        }
      }
    }
    
    // Lastly, filter by platforms if provided by user
    if (platforms != null && platforms.isNotEmpty && finalResults.isNotEmpty) {
      finalResults = await _filterByPlatforms(finalResults, platforms);
    }
    
    // Remove duplicates based on movie ID
    final uniqueResults = <Movie>[];
    final uniqueIds = <String>{};
    
    for (final movie in finalResults) {
      if (!uniqueIds.contains(movie.id)) {
        uniqueIds.add(movie.id);
        uniqueResults.add(movie);
      }
    }
    
    // Limit results to prevent overwhelming the UI
    return uniqueResults.take(15).toList();
  }
  
  /// Gets genre ID mapping from TMDB
  Future<Map<String, int>> _getGenreMapping() async {
    
    final uri = Uri.parse('$_baseUrl/genre/movie/list')
        .replace(queryParameters: {'api_key': _apiKey, 'language': 'en-US'});
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['genres'] as List;
        
        final mapping = <String, int>{};
        for (final genre in genres) {
          mapping[genre['name']] = genre['id'];
        }
        
        return mapping;
      }
    } catch (e) {
      print('Error fetching genre mapping: $e');
    }
    
    // Fallback to hardcoded mapping (from TMDB API docs)
    return {
      'Action': 28,
      'Adventure': 12,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Fantasy': 14,
      'History': 36,
      'Horror': 27,
      'Music': 10402,
      'Mystery': 9648,
      'Romance': 10749,
      'Science Fiction': 878,
      'Thriller': 53,
      'War': 10752,
      'Western': 37,
    };
  }
  
  // Gets movies by a specific person (actor, director, etc.)
  Future<List<Movie>> _getMoviesByPerson(String personName) async {
    final personSearchUri = Uri.parse('$_baseUrl/search/person')
        .replace(queryParameters: {
          'api_key': _apiKey,
          'query': personName,
          'language': 'en-US',
          'page': '1',
          'include_adult': 'false'
        });
    
    try {
      final searchResponse = await http.get(personSearchUri);
      
      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final results = searchData['results'] as List;
        
        if (results.isNotEmpty) {
          final personId = results[0]['id'];
          
          // Get person's movies
          final personMoviesUri = Uri.parse('$_baseUrl/person/$personId/movie_credits')
              .replace(queryParameters: {
                'api_key': _apiKey,
                'language': 'en-US'
              });
          
          final creditsResponse = await http.get(personMoviesUri);
          
          if (creditsResponse.statusCode == 200) {
            final creditsData = json.decode(creditsResponse.body);
            final cast = creditsData['cast'] as List? ?? [];
            final crew = creditsData['crew'] as List? ?? [];
            
            // Combine cast and crew roles, focusing on directing/writing for crew
            final allMovies = [...cast];
            
            for (final job in crew) {
              final department = job['department'];
              if (department == 'Directing' || department == 'Writing') {
                allMovies.add(job);
              }
            }
            
            // Sort by popularity (most popular first)
            allMovies.sort((a, b) => 
              (b['popularity'] as num).compareTo(a['popularity'] as num));
            
            // Convert to Movies and enrich with details
            return await _enrichMoviesWithDetails(allMovies.take(10).toList());
          }
        }
      }
    } catch (e) {
      print('Error getting movies by person: $e');
    }
    
    return [];
  }
  
  // Gets movies similar to the provided movie title
  Future<List<Movie>> _getSimilarMoviesRecommendations(String movieTitle) async {
    // First search for the movie by title
    final searchUri = Uri.parse('$_baseUrl/search/movie')
        .replace(queryParameters: {
          'api_key': _apiKey,
          'query': movieTitle,
          'language': 'en-US',
          'page': '1',
          'include_adult': 'false'
        });
    
    try {
      final searchResponse = await http.get(searchUri);
      
      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final results = searchData['results'] as List;
        
        if (results.isNotEmpty) {
          final movieId = results[0]['id'];
          
          // Get similar movies
          final similarUri = Uri.parse('$_baseUrl/movie/$movieId/similar')
              .replace(queryParameters: {
                'api_key': _apiKey,
                'language': 'en-US',
                'page': '1'
              });
          
          final similarResponse = await http.get(similarUri);
          
          if (similarResponse.statusCode == 200) {
            final similarData = json.decode(similarResponse.body);
            final similarResults = similarData['results'] as List;
            
            // Convert to Movies and enrich with details
            return await _enrichMoviesWithDetails(similarResults.take(10).toList());
          }
        }
      }
    } catch (e) {
      print('Error getting similar movies: $e');
    }
    
    return [];
  }
  
  // Enriches movie data with additional details
  Future<List<Movie>> _enrichMoviesWithDetails(List movieResults) async {
    final enrichedMovies = <Movie>[];
    
    for (final result in movieResults) {
      try {
        final movieId = result['id'].toString();
        final detailsUri = Uri.parse('$_baseUrl/movie/$movieId')
            .replace(queryParameters: {'api_key': _apiKey, 'language': 'en-US'});
        
        final detailsResponse = await http.get(detailsUri);
        
        if (detailsResponse.statusCode == 200) {
          final movieDetails = json.decode(detailsResponse.body);
          
          // Create a comprehensive movie object
          final Movie movie = Movie(
            id: movieId,
            title: result['title'] ?? movieDetails['title'] ?? 'Unknown Title',
            imageUrl: result['poster_path'] != null && result['poster_path'].toString().isNotEmpty
                ? 'https://image.tmdb.org/t/p/w500${result['poster_path']}'
                : 'https://via.placeholder.com/500x750?text=No+Image',
            overview: result['overview'] ?? movieDetails['overview'] ?? 'No overview available',
            rating: (result['vote_average'] ?? movieDetails['vote_average'] ?? 0).toDouble(),
            genres: _extractGenres(movieDetails),
            releaseDate: result['release_date'] ?? movieDetails['release_date'] ?? '2000-01-01',
            runtime: movieDetails['runtime'] ?? 0,
          );
          
          enrichedMovies.add(movie);
        } else {
          // Fallback to basic movie without details
          final Movie movie = Movie.fromJson(result);
          enrichedMovies.add(movie);
        }
      } catch (e) {
        print('Error enriching movie data: $e');
        try {
          final Movie movie = Movie.fromJson(result);
          enrichedMovies.add(movie);
        } catch (_) {
          // Ignore completely invalid entries
        }
      }
    }
    
    return enrichedMovies;
  }
  
  // Extract genre names from movie details
  List<String> _extractGenres(Map<String, dynamic> movieDetails) {
    try {
      final genreObjects = movieDetails['genres'] as List?;
      
      if (genreObjects != null && genreObjects.isNotEmpty) {
        return genreObjects
            .map((genre) => genre['name'].toString())
            .toList();
      }
    } catch (e) {
      print('Error extracting genres: $e');
    }
    
    return [];
  }
  
  // Filters movies by streaming platforms
  Future<List<Movie>> _filterByPlatforms(List<Movie> movies, List<String> platforms) async {
    final filteredMovies = <Movie>[];
    
    for (var movie in movies) {
      try {
        final watchProvidersUri = Uri.parse(
            '$_baseUrl/movie/${movie.id}/watch/providers'
          ).replace(queryParameters: {'api_key': _apiKey});
        
        final response = await http.get(watchProvidersUri);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Check US results first, then fall back to other regions if needed
          Map<String, dynamic>? regionData = data['results']['US'];
          
          if (regionData == null) {
            // Try to get any available region data
            final allRegions = data['results'] as Map<String, dynamic>;
            if (allRegions.isNotEmpty) {
              regionData = allRegions.values.first;
            }
          }
          
          if (regionData != null) {
            // Check all provider types (flatrate, rent, buy)
            final allProviders = <Map<String, dynamic>>[];
            
            for (final type in ['flatrate', 'rent', 'buy']) {
              final typeProviders = regionData[type] as List?;
              if (typeProviders != null) {
                allProviders.addAll(typeProviders.cast<Map<String, dynamic>>());
              }
            }
            
            // Extract provider names
            final moviePlatforms = allProviders
                .map((p) => p['provider_name'].toString().toLowerCase())
                .toSet()
                .toList();
            
            // Check if any requested platform is available
            for (final platform in platforms) {
              if (moviePlatforms.any((p) => p.contains(platform.toLowerCase()))) {
                filteredMovies.add(movie);
                break;
              }
            }
          }
        }
      } catch (e) {
        print('Error checking platforms for movie ${movie.id}: $e');
      }
    }
    
    return filteredMovies;
  }

  // Fetch TV show recommendations with similar filtering
  Future<List<Movie>> getShowRecommendations({
    List<String>? genres,
    List<String>? platforms,
    List<String>? people,
    List<String>? similarShows,
    double? minRating,
    double? maxRating,
    String? firstAirYear,
    String? sortBy,
  }) async {
    // Example for basic discover TV without the complex filters
    final queryParameters = {
      'api_key': _apiKey,
      'language': 'en-US',
      'sort_by': sortBy ?? 'popularity.desc',
      'include_adult': 'false',
      'page': '1',
      'vote_average.gte': minRating != null ? (minRating / 10).toString() : null, // TMDB uses 0-10 scale
      'vote_average.lte': maxRating != null ? (maxRating / 10).toString() : null, // TMDB uses 0-10 scale
      'first_air_date_year': firstAirYear,
    };
    
    queryParameters.removeWhere((key, value) => value == null);
    
    final uri = Uri.parse('$_baseUrl/discover/tv')
        .replace(queryParameters: queryParameters);
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        // Convert TV shows to Movie objects for compatibility with UI
        return results.map((show) {
          return Movie(
            id: show['id'].toString(),
            title: show['name'],
            imageUrl: show['poster_path'] != null 
                ? 'https://image.tmdb.org/t/p/w500${show['poster_path']}' 
                : 'https://via.placeholder.com/500x750?text=No+Image',
            overview: show['overview'] ?? 'No overview available',
            rating: (show['vote_average'] ?? 0).toDouble(),
            genres: [],  // Would need to fetch TV genre details
            releaseDate: show['first_air_date'] ?? '2000-01-01',
            runtime: 0,  // Would need episode runtime, not directly available
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching TV shows: $e');
    }
    
    return [];
  }

  // Clears the recommendation cache
  void clearCache() {
    _cache.clear();
  }
}