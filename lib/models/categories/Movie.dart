class Movie {
  final String id;
  final String title;
  final String imageUrl;
  final String overview;
  final double rating;
  final List<String> genres;
  final String releaseDate;
  final int runtime;

  final String imdbRating;
  String imdbVotes;
  final String rottenTomatoesScore;
  final List<String> providers;
  final List<CastMember> cast;
  final String trailerKey;
  final String? rated;


  Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.overview,
    required this.rating,
    required this.genres,
    required this.releaseDate,
    required this.runtime,
    required this.imdbRating,
    required this.imdbVotes,
    required this.rottenTomatoesScore,
    required this.providers,
    required this.cast,
    required this.trailerKey,
    required this.rated,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'].toString(),
      title: json['title'],
      imageUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      overview: json['overview'],
      rating: json['vote_average'].toDouble(),
      genres: (json['genre_ids'] as List).map((id) => id.toString()).toList(),
      releaseDate: json['release_date'],
      runtime: json['runtime'] ?? 0,
      imdbRating: json['imdb_rating'] ?? 'N/A',
      imdbVotes: json['imdb_votes'] ?? 'N/A',
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
    );
  }

  String get formattedRating => rating.toStringAsFixed(1);

  String formatReviewCount()
  {
    //Remove commas from imdbVotes
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