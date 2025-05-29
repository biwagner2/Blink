import 'dart:convert';
import 'package:blink/models/categories/Movie.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Service class for fetching movie and show data from The Movie Database (TMDB) API...
class TMDBMovieService {
  final String _apiKey;
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final Map<String, List<Movie>> _cache = {};
  final Map<String, List<Movie>> _tvCache = {};


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
    final tasks = movieResults.take(10).map<Future<Movie?>>((result) async {
      try {
        final movieId = result['id'].toString();
        final detailsUri = Uri.parse('$_baseUrl/movie/$movieId').replace(queryParameters: {
          'api_key': _apiKey,
          'language': 'en-US',
          'append_to_response': 'credits,videos,external_ids,watch/providers',
        });

        final detailsResponse = await http.get(detailsUri);
        if (detailsResponse.statusCode != 200) throw Exception('TMDB fetch failed');

        final details = json.decode(detailsResponse.body);

        // Director and top 3 actors
        final crew = details['credits']['crew'] as List;
        final director = crew.firstWhere(
          (member) => member['job'] == 'Director',
          orElse: () => null,
        );

        final castMembers = <CastMember>[];
        if (director != null) {
          castMembers.add(CastMember(name: director['name'], job: 'Director'));
        }

        final cast = (details['credits']['cast'] as List)
            .take(3)
            .map((actor) => CastMember(name: actor['name'], job: 'Actor'))
            .toList();

        castMembers.addAll(cast);

        // Trailer
        final trailer = (details['videos']['results'] as List?)?.firstWhere(
          (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
          orElse: () => null,
        );
        final trailerKey = trailer != null ? trailer['key'] : '';

        // Providers
        final providerData = details['watch/providers']['results']['US'];
        final providerList = <String>[];
        for (final type in ['flatrate', 'rent', 'buy']) {
          final entries = providerData?[type] as List?;
          if (entries != null) {
            providerList.addAll(entries.map((e) => e['provider_name'].toString()));
          }
        }

        // IMDb & RT Ratings
        final imdbId = details['imdb_id'];
        String imdbRating = 'N/A';
        String imdbVotes = '0';
        String rottenTomatoes = 'N/A';
        String rated = 'N/A';

        if (imdbId != null && imdbId.isNotEmpty) {
          final omdbResponse = await http.get(Uri.parse("http://www.omdbapi.com/").replace(queryParameters: {
            'i': imdbId,
            'apikey': dotenv.env['OMDB_API_KEY'] ?? '',
          }));

          if (omdbResponse.statusCode == 200) {
            final omdb = json.decode(omdbResponse.body);
            imdbRating = omdb['imdbRating'] ?? 'N/A';
            imdbVotes = omdb['imdbVotes']?.toString() ?? '0';
            rated = omdb['Rated'] ?? 'N/A';

            final ratingsList = omdb['Ratings'] as List?;
            if (ratingsList != null) {
              final rtRating = ratingsList.firstWhere(
                (r) => r is Map && r['Source'] == 'Rotten Tomatoes',
                orElse: () => {},
              );
              if (rtRating is Map && rtRating.containsKey('Value')) {
                rottenTomatoes = rtRating['Value'];
              }
            }
          }
        }

        print('Enriching: ${details['title']} | RT: $rottenTomatoes');

        return Movie(
          id: movieId,
          title: details['title'] ?? result['title'] ?? 'Unknown Title',
          imageUrl: details['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${details['poster_path']}'
              : 'https://via.placeholder.com/500x750?text=No+Image',
          overview: details['overview'] ?? 'No overview available',
          rating: (details['vote_average'] ?? 0).toDouble(),
          genres: _extractGenres(details),
          releaseDate: details['release_date'] ?? '2000-01-01',
          runtime: details['runtime'] ?? 0,
          imdbRating: imdbRating,
          imdbVotes: imdbVotes,
          imdbId: imdbId ?? 'N/A',
          rottenTomatoesScore: rottenTomatoes,
          providers: providerList.toSet().toList(),
          cast: castMembers,
          trailerKey: trailerKey,
          rated: rated,
        );
      } catch (e) {
        print('Error enriching movie: $e');
        return null; // Allow failure without breaking others
      }
    }).toList();

    final enrichedMovies = await Future.wait(tasks);
    return enrichedMovies.whereType<Movie>().toList();
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
  List<Movie> finalResults = [];

  // Handle similar shows
  if (similarShows != null && similarShows.isNotEmpty) {
    for (final title in similarShows) {
      final results = await _getSimilarTVShows(title);
      finalResults.addAll(results);
    }
  }

  // Handle people filter
  if (people != null && people.isNotEmpty) {
    for (final person in people) {
      final results = await _getTVShowsByPerson(person);
      finalResults.addAll(results);
    }
  }

  // Discover TV if no people/similar filters used
  if ((similarShows == null || similarShows.isEmpty) &&
      (people == null || people.isEmpty)) {
    final genreMapping = await _getTVGenreMapping();
    final genreIds = <String>[];

    if (genres != null) {
      for (final genre in genres) {
        if (genreMapping.containsKey(genre)) {
          genreIds.add(genreMapping[genre].toString());
        }
      }
    }

    final queryParameters = {
      'api_key': _apiKey,
      'language': 'en-US',
      'sort_by': sortBy ?? 'popularity.desc',
      'include_adult': 'false',
      'page': '1',
      'with_genres': genreIds.isNotEmpty ? genreIds.join(',') : null,
      'vote_average.gte': minRating != null ? (minRating / 10).toString() : null,
      'vote_average.lte': maxRating != null ? (maxRating / 10).toString() : null,
      'first_air_date_year': firstAirYear,
    };

    queryParameters.removeWhere((k, v) => v == null);

    final uri = Uri.parse('$_baseUrl/discover/tv').replace(queryParameters: queryParameters);
    final cacheKey = uri.toString();

    if (_tvCache.containsKey(cacheKey)) {
      finalResults.addAll(_tvCache[cacheKey]!);
    } 
    else {
      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          final enriched = await _enrichMoviesWithDetails(results.take(10).toList());
          _tvCache[cacheKey] = enriched;
          finalResults.addAll(enriched);
        }
      } catch (e) {
        print('Error fetching discover TV shows: $e');
      }
    }
  }

  // Filter by streaming platforms
  if (platforms != null && platforms.isNotEmpty && finalResults.isNotEmpty) {
    finalResults = await _filterByPlatforms(finalResults, platforms);
  }

  // Remove duplicates
  final uniqueResults = <Movie>[];
  final seenIds = <String>{};

  for (final show in finalResults) {
    if (!seenIds.contains(show.id)) {
      seenIds.add(show.id);
      uniqueResults.add(show);
    }
  }

  return uniqueResults.take(15).toList();
}

Future<List<Movie>> _getSimilarTVShows(String showTitle) async {
  final searchUri = Uri.parse('$_baseUrl/search/tv').replace(queryParameters: {
    'api_key': _apiKey,
    'query': showTitle,
    'language': 'en-US',
    'page': '1',
  });

  try {
    final searchResponse = await http.get(searchUri);
    if (searchResponse.statusCode != 200) return [];

    final data = json.decode(searchResponse.body);
    final results = data['results'] as List;
    if (results.isEmpty) return [];

    final showId = results[0]['id'];

    final similarUri = Uri.parse('$_baseUrl/tv/$showId/similar').replace(queryParameters: {
      'api_key': _apiKey,
      'language': 'en-US',
      'page': '1',
    });

    final similarResponse = await http.get(similarUri);
    if (similarResponse.statusCode != 200) return [];

    final similarData = json.decode(similarResponse.body);
    final similarResults = similarData['results'] as List;

    return await _enrichMoviesWithDetails(similarResults.take(10).toList());
  } catch (e) {
    print('Error fetching similar TV shows: $e');
    return [];
  }
}


Future<List<Movie>> _getTVShowsByPerson(String personName) async {
  final searchUri = Uri.parse('$_baseUrl/search/person').replace(queryParameters: {
    'api_key': _apiKey,
    'query': personName,
    'language': 'en-US',
    'page': '1',
    'include_adult': 'false',
  });

  try {
    final searchResponse = await http.get(searchUri);
    if (searchResponse.statusCode != 200) return [];

    final data = json.decode(searchResponse.body);
    final results = data['results'] as List;
    if (results.isEmpty) return [];

    final personId = results[0]['id'];

    final creditsUri = Uri.parse('$_baseUrl/person/$personId/tv_credits').replace(queryParameters: {
      'api_key': _apiKey,
      'language': 'en-US',
    });

    final creditsResponse = await http.get(creditsUri);
    if (creditsResponse.statusCode != 200) return [];

    final creditsData = json.decode(creditsResponse.body);
    final cast = creditsData['cast'] as List? ?? [];
    final crew = creditsData['crew'] as List? ?? [];

    final allShows = [...cast];
    for (final job in crew) {
      final department = job['department'];
      if (department == 'Directing' || department == 'Writing') {
        allShows.add(job);
      }
    }

    allShows.sort((a, b) => (b['popularity'] as num).compareTo(a['popularity'] as num));
    return await _enrichMoviesWithDetails(allShows.take(10).toList());
  } catch (e) {
    print('Error fetching TV shows by person: $e');
    return [];
  }
}


Future<Map<String, int>> _getTVGenreMapping() async {
  final uri = Uri.parse('$_baseUrl/genre/tv/list').replace(queryParameters: {
    'api_key': _apiKey,
    'language': 'en-US',
  });

  try {
    final response = await http.get(uri);
    if (response.statusCode != 200) return {};

    final data = json.decode(response.body);
    final genres = data['genres'] as List;

    return {
      for (final genre in genres) genre['name']: genre['id'],
    };
  } catch (e) {
    print('Error fetching TV genre mapping: $e');
    return {};
  }
}




  // Clears the recommendation caches
  void clearCache() => _cache.clear();

  void clearTVCache() => _tvCache.clear();
}