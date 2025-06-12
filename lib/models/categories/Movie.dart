class Movie {
  final String id;
  final String title;
  final String imageUrl;
  final String overview;
  final double tmdbRating;
  final List<String> genres;
  final String releaseDate;
  final int runtime;

  final String imdbRating;
  String imdbVotes;
  final String? imdbId;
  final String rottenTomatoesScore;
  final List<String> providers;
  final List<CastMember> cast;
  final String trailerKey;
  final String? rated;
  final String type;


  Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.overview,
    required this.tmdbRating,
    required this.genres,
    required this.releaseDate,
    required this.runtime,
    required this.imdbRating,
    required this.imdbVotes,
    required this.imdbId,
    required this.rottenTomatoesScore,
    required this.providers,
    required this.cast,
    required this.trailerKey,
    required this.rated,
    required this.type
  });

  factory Movie.fromJson(Map<String, dynamic> json, {String type = 'movie'}) {
    return Movie(
      id: json['id'].toString(),
      title: json['title'] ?? json['original_title'] ?? json['name'] ?? json['original_name'] ?? 'Unknown Title',
      imageUrl: json['poster_path'] != null 
        ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}' 
        : '',
      overview: json['overview'] ?? 'No overview available',
      tmdbRating: (json['vote_average'] ?? 0).toDouble(),
      genres: (json['genre_ids'] as List<dynamic>?)
        ?.map((id) => id.toString())
        .toList() ?? [],
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? 'N/A',
      runtime: json['runtime'] ?? (json['episode_run_time']?.first ?? 0),
      imdbRating: json['imdb_rating'] ?? 'N/A',
      imdbVotes: json['imdb_votes'] ?? 'N/A',
      imdbId: json['imdb_id'] ?? 'N/A',
      rottenTomatoesScore: json['rotten_tomatoes_score'] ?? 'N/A',
      providers: (json['providers'] as List<dynamic>?)
              ?.map((provider) => provider['provider_name'] as String)
              .toList() ??
          [],
      cast: (json['cast'] as List<dynamic>?)
              ?.map((member) => CastMember(
                    name: member['name'],
                    job: member['character'],
                  ))
              .toList() ??
          [],
      trailerKey: json['trailer_key'] ?? '',
      rated: json['rated'] ?? 'N/A',
      type: type,
    );
  }

  final Map<String, String> genreAbbreviation = {
    'Science Fiction' : 'Sci-Fi',
    'Action & Adventure' : 'Action',
    'Sci-Fi & Fantasy' : 'Sci-Fi',
    'War & Politics' : 'Politics',
  };

  String formatGenre(String genre) {
    if (genreAbbreviation[genre] != null)
    {
      return genreAbbreviation[genre]!;
    }
    return genre;
  }

  String get formattedTmdbRating {
    final percent = (tmdbRating * 10).round();
    return '$percent%';
  }

  String get formatReviewCount
  {
    //Remove commas from imdbVote numbers
    if(imdbVotes == 'N/A' || imdbVotes.isEmpty)
    {
      return '(N/A)';
    }
    imdbVotes = imdbVotes.replaceAll(',', '');
    if(int.parse(imdbVotes) > 1000)
    {
      return '(${(int.parse(imdbVotes) / 1000).toStringAsFixed(1)}K+)';
    }
    else
    {
      return '($imdbVotes)';
    }
  }

  String get formattedReleaseYear {
    try {
      return releaseDate.substring(0, 4);
    } catch (_) {
      return '';
    }
  }

  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class CastMember {
  final String name;
  final String job;

  CastMember({required this.name, required this.job});
}