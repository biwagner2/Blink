import 'dart:convert';
import 'package:blink/models/categories/Movie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Service class for fetching movie and show data from The Movie Database (TMDB) API...
class TMDBMovieService {
  static final TMDBMovieService _instance = TMDBMovieService._internal();
  factory TMDBMovieService() => _instance;
  TMDBMovieService._internal();

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  final Map<String, List<Movie>> _cache = {};
  final Map<String, List<Movie>> _tvCache = {};
  final Map<String, Map<String, dynamic>> _omdbCache = {};
  static const String _omdbCacheKey = 'omdb_cache';


  late final Map<String, int> _movieGenreIdMap; // Maps genre names to IDs
  late final Map<String, String> _movieGenreNameMap; // Maps genre IDs to names

  late final Map<String, int> _showGenreIdMap;
  late final Map<String, String> _showGenreNameMap;
  
  final Map<String, String> tmdbProviderMap = {
    'netflix': '8',
    'amazon': '9',
    'apple tv': '2',
    'google play movies': '3',
    'youtube': '192',
    'fandango at home': '7', 
    'spectrum on demand': '486',
    'plex': '538',
    'mgm plus': '34',
    'max': '1899',
    'hulu': '15',
    'disney plus': '337',
    'paramount+': '531',
    'crunchyroll': '283',
    'peacock': '387',
    'tubi tv': '73',
    'pluto tv': '300',
  };

  String get baseUrl => _baseUrl;

  String normalize(String input) => input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String get apiKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('TMDB_API_KEY is missing or not loaded');
    }
    return key;
  }


  Future<void> initializeGenreMap() async {
    final movieMap = await _getGenreMapping();
    _movieGenreIdMap = movieMap;
    _movieGenreNameMap = {
      for (var entry in movieMap.entries) entry.value.toString(): entry.key,
    };

    final showMap = await _getShowGenreMapping();
    _showGenreIdMap = showMap;
    _showGenreNameMap = {
      for (var entry in showMap.entries) entry.value.toString(): entry.key,
    };
  }

  List<String> _movieGenreNameLookup(List<String> genreIds) {
    final genreMap = _movieGenreNameMap;
    return genreIds.map((id) => genreMap[id] ?? id).toList();
  }

  List<String> _showGenreNameLookup(List<String> genreIds) {
    final genreMap = _showGenreNameMap;
    return genreIds.map((id) => genreMap[id] ?? id).toList();
  }

  Future<void> _persistOmdbCache() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_omdbCache);
    await prefs.setString(_omdbCacheKey, encoded);
  }

  Future<void> loadOmdbCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_omdbCacheKey);
    if (raw == null) return;

    try {
      final decoded = json.decode(raw);
      _omdbCache.clear();

      final now = DateTime.now().millisecondsSinceEpoch;
      final expirationMs = 10 * 24 * 60 * 60 * 1000; // expire after 10 days

      for (final entry in decoded.entries) {
        final value = entry.value;
        final timestamp = value['timestamp'] ?? 0;

        if (now - timestamp <= expirationMs && value['data'] != null) {
          _omdbCache[entry.key] = value;
        }
      }

      print('Loaded OMDb cache with ${_omdbCache.length} fresh entries');
    } catch (e) {
      print('Failed to load OMDb cache: $e');
    }
  }

  Future<List<Movie>> supplementRecommendations({required List<Movie> currentRecommendations, required bool isMovie}) async {
    if (currentRecommendations.length >= 10) return currentRecommendations;

    final fallbackRecs = isMovie
        ? await getMovieRecommendations()
        : await getShowRecommendations();

    // Add only movies not already in the list
    final fallbackFiltered = fallbackRecs
        .where((media) => currentRecommendations.every((existing) => existing.id != media.id))
        .toList();

    final supplemented = [...currentRecommendations, ...fallbackFiltered];
    supplemented.shuffle();
    return supplemented.take(10).toList();
  }


  // Fetches movie recommendations based on the provided filters...
  // Runs when Blink button is pressed
  Future<List<Movie>> getMovieRecommendations({
    List<String>? genres,
    List<String>? platforms,
    List<int>? peopleIDs,
    List<int>? similarMovieIDs,
    double? minRating,
    double? maxRating,
    String? sortBy,
  }) async {

    final Set<String> seenMovieIds = {};
    List<Movie> potentialMovies = [];
    
    // Handle similar movies filter if provided by user
    if (similarMovieIDs != null && similarMovieIDs.isNotEmpty) {
      for (final tmdbID in similarMovieIDs) {
        final similarMoviesList = await _getSimilarMoviesById(tmdbID);
        potentialMovies.addAll(similarMoviesList);
      }
    }
    
    // Now handle people filter if provided by user
    if (peopleIDs != null && peopleIDs.isNotEmpty) {
      for (final tmdbID in peopleIDs) {
        final personMoviesList = await _getMoviesByPersonID(tmdbID);
        potentialMovies.addAll(personMoviesList);
      }
    }

    // If user only wants to see recommendations based on similar movies or people, return those early.
    if ((genres == null || genres.isEmpty) && (platforms == null || platforms.isEmpty) && minRating == null && maxRating == null && potentialMovies.length >= 10) {
      // Deduplicate list, enrich with details, shuffle, and return top 10
      final deduplicatedMovieList = <Movie>[];
      for (final movie in potentialMovies) {
        if (seenMovieIds.add(movie.id)) {
          deduplicatedMovieList.add(movie);
        }
      }

      if (deduplicatedMovieList.length < 10) {
        deduplicatedMovieList.shuffle();
        final supplementedList = await supplementRecommendations(currentRecommendations: List.from(deduplicatedMovieList), isMovie: true);
        final enriched = await _enrichMoviesWithDetails(supplementedList, isMovie: true);
        return enriched.take(10).toList();
      }

      final enrichedMovieList = await _enrichMoviesWithDetails(deduplicatedMovieList, isMovie: true);
      enrichedMovieList.shuffle();
      return enrichedMovieList.take(10).toList();
    }

    //Convert genre names to IDs using the genreMap
    final genreIds = genres?.map((g) => _movieGenreIdMap[g]).whereType<int>().toList();

    final providerIds = platforms ?.map((p) => tmdbProviderMap[p.toLowerCase()])
      .whereType<String>()
      .toList();
    print("Calling discover with minRating: $minRating, and maxRating: $maxRating");
    final discoverQuery = {
      'api_key': apiKey,
      'language': 'en-US',
      'sort_by': sortBy ?? 'popularity.desc',
      'include_adult': 'false',
      'include_video': 'false',
      'page': '1',
      if (genreIds != null && genreIds.isNotEmpty)
        if (genreIds.length > 3)
          'with_genres': genreIds.join('|'),
      if (genreIds != null && genreIds.isNotEmpty)
        if (genreIds.length <= 3)
          'with_genres': genreIds.join(','),
      if (providerIds != null && providerIds.isNotEmpty) 
        'with_watch_providers': providerIds.join('|'),
      if (providerIds != null && providerIds.isNotEmpty) 
        'watch_region': 'US',
      if (minRating != null) 
        'vote_average.gte': (minRating / 10).toString(),
      if (maxRating != null) 
        'vote_average.lte': (maxRating / 10).toString(),
    };

    final discoverUri = Uri.parse('$_baseUrl/discover/movie').replace(queryParameters: discoverQuery);
    final cacheKey = discoverUri.toString();

    if (_cache.containsKey(cacheKey)) {
      potentialMovies.addAll(_cache[cacheKey]!);
    } 
    else {
      try {
        final response = await http.get(discoverUri);
        if (response.statusCode == 200) {
          print("Call didn't crash");
          final results = json.decode(response.body)['results'] as List;
          final movies = results.map((r) => Movie.fromJson(r, type: 'movie')).toList();
          _cache[cacheKey] = movies;
          for (final movie in movies) {
            print('Found movie: ${movie.title} (${movie.formattedReleaseYear})');
          }
          potentialMovies.addAll(movies);
        }
      } 
      catch (e) {
        print('Error fetching discover movies: $e');
      }
    }

    // Filter all the possible movies we have now by genre and rating. 
    final selectedGenreIds = genreIds?.map((id) => id.toString()).toList();
    final adjustedMinRating = minRating != null ? minRating / 10 : null;
    final adjustedMaxRating = maxRating != null ? maxRating / 10 : null;

    final filteredPotentialMovies = potentialMovies.where((movie) {
      final matchesGenre = selectedGenreIds == null || selectedGenreIds.isEmpty || movie.genres.any((gId) => selectedGenreIds.contains(gId));
      final matchesRating = 
        (adjustedMinRating == null || movie.tmdbRating >= adjustedMinRating) 
        && (adjustedMaxRating == null || movie.tmdbRating <= adjustedMaxRating);
      return matchesGenre && matchesRating;
    }).toList();

    for (final movie in filteredPotentialMovies) {
      print('Found movie: ${movie.title} (${movie.formattedReleaseYear})');
    }

    // Deduplicate the list of possible recommendations
    final deduplicatedMovieList = <Movie>[];

    for (final movie in filteredPotentialMovies) {
      if (seenMovieIds.add(movie.id)) {
        deduplicatedMovieList.add(movie);
      }
    }

    // Enrich the deduplicated potential movies list with extra details to filter by later
    final enrichedMovieList = await _enrichMoviesWithDetails(deduplicatedMovieList, isMovie: true);

    // Can now filter by plaform
    final filteredByPlatform = platforms == null || platforms.isEmpty
      ? enrichedMovieList
      : enrichedMovieList.where((movie) =>
           movie.providers.any((p) => platforms.any((platform) => normalize(p).contains(normalize(platform))))
      ).toList();
    
    List<Movie> finalList = filteredByPlatform;
    finalList.shuffle();
    if(finalList.length < 10)
    {
      final supplementalMovies = enrichedMovieList.where((movie) => !filteredByPlatform.contains(movie)).toList()..shuffle();
      finalList.addAll(supplementalMovies.take(10 - filteredByPlatform.length));
    }
    // Return 10 movie recommendations
    return finalList.take(10).toList();
  }
  
  // Gets genre ID mapping from TMDB
  Future<Map<String, int>> _getGenreMapping() async {
    
    final uri = Uri.parse('$_baseUrl/genre/movie/list')
        .replace(queryParameters: {'api_key': apiKey, 'language': 'en-US'});
    
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
    
    // Fallback to hardcoded mapping
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
  
  // Gets movies by a specific person (actor, director, etc.\)
  Future<List<Movie>> _getMoviesByPersonID(int tmdbID) async {
    // Get person's movies
    final personMoviesUri = Uri.parse('$_baseUrl/person/$tmdbID/movie_credits')
      .replace(queryParameters: {
        'api_key': apiKey,
        'language': 'en-US'
    });

    try {           
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
          
          // Convert to Movies
          return allMovies.take(10).map((movie) => Movie.fromJson(movie, type: 'movie')).toList();
        }
    }
    catch (e) {
      print('Error getting movies by person: $e');
    }
    return [];
  }
  
  // Gets movies similar to the provided movie tmdbID
  Future<List<Movie>> _getSimilarMoviesById(int tmdbID) async {
    // First search for the movie by tmdb ID
    final similarUri = Uri.parse('$_baseUrl/movie/$tmdbID/similar')
      .replace(queryParameters: {
        'api_key': apiKey,
        'language': 'en-US',
        'page': '1'
      });

      try {
        final response = await http.get(similarUri);
        if (response.statusCode == 200) {
          final results = json.decode(response.body)['results'] as List;
          return results.take(10).map((movie) => Movie.fromJson(movie, type: 'movie')).toList();
        }
      }
      catch (e) {
        print('Error fetching similar movies: $e');
      }
      return [];
  }
  
  // Enriches movie or show data with additional details
  Future<List<Movie>> _enrichMoviesWithDetails(List<Movie> mediaList, {required bool isMovie}) async {
      final tasks = mediaList.map<Future<Movie?>>((media) async {
      try {
        final detailsUri = Uri.parse(
          '$_baseUrl/${isMovie ? 'movie' : 'tv'}/${media.id}'
        ).replace(queryParameters: {
          'api_key': apiKey,
          'language': 'en-US',
          'append_to_response': 'credits,videos,external_ids,watch/providers',
        });

        final detailsResponse = await http.get(detailsUri);
        if (detailsResponse.statusCode != 200) throw Exception('TMDB fetch failed');

        final details = json.decode(detailsResponse.body);

        // Grab data on Director and top 3 actors
        final crew = (details['credits']['crew'] ?? []) as List;
        final director = crew.firstWhere(
          (c) => c['job'] == 'Director',
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

        String? imdbId = details['external_ids']?['imdb_id']; // safer access
        String imdbRating = 'N/A';
        String imdbVotes = '0';
        String rottenTomatoes = 'N/A';
        String rated = 'N/A';

        // Build cache key
        final omdbKey = imdbId != null && imdbId.isNotEmpty
            ? 'id:$imdbId'
            : 'title:${media.title.toLowerCase()}_${media.formattedReleaseYear}';

        Map<String, dynamic>? omdb;

        // Use cache if available
        if (_omdbCache.containsKey(omdbKey)) {
          omdb = _omdbCache[omdbKey]?['data'];
        } else {
          Uri omdbUri;

          if (imdbId != null && imdbId.isNotEmpty) {
            omdbUri = Uri.parse("http://www.omdbapi.com/").replace(queryParameters: {
              'i': imdbId,
              'apikey': dotenv.env['OMDB_API_KEY'] ?? '',
            });
          } else {
            omdbUri = Uri.parse("http://www.omdbapi.com/").replace(queryParameters: {
              't': media.title,
              'y': media.formattedReleaseYear,
              'apikey': dotenv.env['OMDB_API_KEY'] ?? '',
            });
          }

          final omdbResponse = await http.get(omdbUri);

          if (omdbResponse.statusCode == 200) {
            omdb = json.decode(omdbResponse.body);
            _omdbCache[omdbKey] = {
              'data': omdb!,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
            await _persistOmdbCache();
          }
        }

        // Parse ratings if available
        if (omdb != null) {
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
        print('Enriching: ${isMovie ? details['title'] : details['name']} | RT: $rottenTomatoes');


        return Movie(
          id: media.id,
          title: isMovie ? details['title'] : details['name'],
          imageUrl: media.imageUrl,
          overview: details['overview'] ?? media.overview,
          tmdbRating: (details['vote_average'] ?? media.tmdbRating).toDouble(),
          genres: isMovie ?  _movieGenreNameLookup(media.genres) : _showGenreNameLookup(media.genres),
          releaseDate: isMovie ? (details['release_date'] ?? media.releaseDate) : (details['first_air_date'] ?? media.releaseDate),
          runtime: isMovie ? (details['runtime'] ?? media.runtime) 
            : (details['episode_run_time'] is List && (details['episode_run_time'] as List).isNotEmpty
            ? details['episode_run_time'][0]
            : media.runtime),
          imdbRating: imdbRating,
          imdbVotes: imdbVotes,
          imdbId: imdbId,
          rottenTomatoesScore: rottenTomatoes,
          providers: providerList.toSet().toList(),
          cast: castMembers,
          trailerKey: trailerKey,
          rated: rated,
          type: isMovie ? 'movie' : 'show',
        );
      } catch (e) {
        if (isMovie) {
          print('Error enriching movie: $e');
        } else {
          print('Error enriching show: $e');
        }
        return null; // Allow failure without breaking others
      }
    }).toList();

    final enrichedMovies = await Future.wait(tasks);
    return enrichedMovies.whereType<Movie>().toList();
  }
  
  // Fetch TV show recommendations with similar filtering
  Future<List<Movie>> getShowRecommendations({
    List<String>? genres,
    List<String>? platforms,
    List<int>? peopleIDs,
    List<int>? similarShowIDs,
    double? minRating,
    double? maxRating,
    String? sortBy,
  }) async {
    final Set<String> seenIds = {};
    List<Movie> potentialShows = [];

    // Check if user filtered by similar shows
    if (similarShowIDs != null && similarShowIDs.isNotEmpty) {
      for (final tmdbID in similarShowIDs) {
        final shows = await _getSimilarShowsbyID(tmdbID);
        potentialShows.addAll(shows);
      }
    }

    // Check if user filtered shows by people
    if (peopleIDs != null && peopleIDs.isNotEmpty) {
      for (final tmdbID in peopleIDs) {
        final shows = await _getShowsByPersonID(tmdbID);
        potentialShows.addAll(shows);
      }
    }

     // If user only wants to see recommendations based on similar movies or people, return those early.
    if ((genres == null || genres.isEmpty) && (platforms == null || platforms.isEmpty) && minRating == null && maxRating == null && potentialShows.length >= 10) {
      // Deduplicate list, enrich with details, shuffle, and return top 10
      final deduplicatedShowList = <Movie>[];
      for (final show in potentialShows) {
        if (seenIds.add(show.id)) {
          deduplicatedShowList.add(show);
        }
      }

      if (deduplicatedShowList.length < 10) {
        deduplicatedShowList.shuffle();
        final supplementedList = await supplementRecommendations(currentRecommendations: List.from(deduplicatedShowList), isMovie: false);
        final enriched = await _enrichMoviesWithDetails(supplementedList, isMovie: false);
        return enriched.take(10).toList();
      }

      final enrichedShowList = await _enrichMoviesWithDetails(deduplicatedShowList, isMovie: false);
      enrichedShowList.shuffle();
      return enrichedShowList.take(10).toList();
    }

    // Now make a discover call with all the filters
    final genreIds = genres?.map((g) => _showGenreIdMap[g]).whereType<int>().toList();

    final providerIds = platforms?.map((p) => tmdbProviderMap[p.toLowerCase()])
        .whereType<String>()
        .toList();

    final discoverQuery = {
      'api_key': apiKey,
      'language': 'en-US',
      'sort_by': sortBy ?? 'popularity.desc',
      'include_adult': 'false',
      'page': '1',
      if (genreIds != null && genreIds.isNotEmpty) 
        if (genreIds.length > 3)
          'with_genres': genreIds.join('|'),
      if (genreIds != null && genreIds.isNotEmpty) 
        if (genreIds.length <= 3)
        'with_genres': genreIds.join(','),
      if (providerIds != null && providerIds.isNotEmpty) 
        'with_watch_providers': providerIds.join('|'),
      if (providerIds != null && providerIds.isNotEmpty) 
        'watch_region': 'US',
      if (minRating != null) 
        'vote_average.gte': (minRating / 10).toString(),
      if (maxRating != null) 
        'vote_average.lte': (maxRating / 10).toString(),
    };

    final discoverUri = Uri.parse('$_baseUrl/discover/tv').replace(queryParameters: discoverQuery);
    final cacheKey = discoverUri.toString();

    if (_tvCache.containsKey(cacheKey)) {
      potentialShows.addAll(_tvCache[cacheKey]!);
    } else {
      try {
        final response = await http.get(discoverUri);
        if (response.statusCode == 200) {
          final results = json.decode(response.body)['results'] as List;
          final shows = results.map((r) => Movie.fromJson(r, type: 'show')).toList();
          _tvCache[cacheKey] = shows;
          potentialShows.addAll(shows);
        }
      } catch (e) {
        print('Error discovering shows: $e');
      }
    }

    // // Filter all the possible movies we have now by genre and rating. 
    final selectedGenreIds = genreIds?.map((id) => id.toString()).toList();
    final adjustedMinRating = minRating != null ? minRating / 10 : null;
    final adjustedMaxRating = maxRating != null ? maxRating / 10 : null;

    final filteredPotentialShows = potentialShows.where((show) {
      final matchesGenre = selectedGenreIds == null || selectedGenreIds.isEmpty || show.genres.any((gId) => selectedGenreIds.contains(gId));
      final matchesRating = 
        (adjustedMinRating == null || show.tmdbRating >= adjustedMinRating) 
        && (adjustedMaxRating == null || show.tmdbRating <= adjustedMaxRating);
      return matchesGenre && matchesRating;
    }).toList();

    // Deduplicate the list of possible recommendations
    final deduplicatedShowList = <Movie>[];
    for (final show in filteredPotentialShows) {
      if (seenIds.add(show.id)) {
        deduplicatedShowList.add(show);
      }
    }

    // Enrich the deduplicated potential movies list with extra details to filter by later
    final enrichedShowList = await _enrichMoviesWithDetails(deduplicatedShowList, isMovie: false);

    // Can now filter by platform
    final filteredByPlatform = platforms == null || platforms.isEmpty
        ? enrichedShowList
        : enrichedShowList.where((show) =>
            show.providers.any((p) => platforms.any((platform) => normalize(p).contains(normalize(platform))))
          ).toList();

    List<Movie> finalList = filteredByPlatform;
    finalList.shuffle();
    if(finalList.length < 10)
    {
      final supplementalShows = enrichedShowList.where((show) => !filteredByPlatform.contains(show)).toList()..shuffle();
      finalList.addAll(supplementalShows.take(10 - filteredByPlatform.length));
    }
    // Return 10 show recommendations
    return finalList.take(10).toList();
  }

  // Gets shows similar to the provided show tmdbID
  Future<List<Movie>> _getSimilarShowsbyID(int tmdbID) async {
    final similarUri = Uri.parse('$_baseUrl/tv/$tmdbID/similar').replace(queryParameters: {
        'api_key': apiKey,
        'language' : 'en-US',
        'page' : '1'
    });

    try {
      final response = await http.get(similarUri);
      if(response.statusCode == 200)
      {
        final results = json.decode(response.body) as List;
        return results.take(10).map((show) => Movie.fromJson(show, type: 'show')).toList();
      }
    } catch (e) {
      print("Error fetching similar shows: $e");
    }
    return [];
  }


  Future<List<Movie>> _getShowsByPersonID(int tmdbID) async {
    final creditsUri = Uri.parse('$_baseUrl/person/$tmdbID/tv_credits').replace(queryParameters: {
        'api_key': apiKey,
        'language': 'en-US',
    });

    try {
      final creditsResponse = await http.get(creditsUri);
      if(creditsResponse.statusCode == 200)
      {
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
        return allShows.take(10).map((show) => Movie.fromJson(show, type: 'show')).toList();
      }
    } catch (e) {
      print('Error fetching TV shows by person: $e');
    }
    return [];
  }


  Future<Map<String, int>> _getShowGenreMapping() async {
    final uri = Uri.parse('$_baseUrl/genre/tv/list').replace(queryParameters: {
      'api_key': apiKey,
      'language': 'en-US',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['genres'] as List;

        return {
          for (final genre in genres) genre['name']: genre['id'],
        };
      }
    } catch (e) {
      print('Error fetching TV show genre mapping: $e');
    }

    // Fallback if TMDB call fails or result is incomplete
    return {
      'Action & Adventure': 10759,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Kids': 10762,
      'Mystery': 9648,
      'News': 10763,
      'Reality': 10764,
      'Sci-Fi & Fantasy': 10765,
      'Soap': 10766,
      'Talk': 10767,
      'War & Politics': 10768,
      'Western': 37,
    };
  }


  // Clears the recommendation caches
  void clearCache() => _cache.clear();

  void clearTVCache() => _tvCache.clear();

  Future<void> clearExpiredOmdbCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expirationMs = 10 * 24 * 60 * 60 * 1000;

    _omdbCache.removeWhere((_, entry) {
      final timestamp = entry['timestamp'];
      return timestamp == null || now - timestamp > expirationMs;
    });

    await _persistOmdbCache(); // Save cleaned cache
  }

  // Clears all caches
  Future<void> clearAllCaches() async {
    _cache.clear();
    _tvCache.clear();
    _omdbCache.clear();
    await _persistOmdbCache(); // Save empty cache
  }

}