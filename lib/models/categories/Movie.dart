import 'dart:convert';

class Movie {
  final String id;
  final String title;
  final String imageUrl;
  final String overview;
  final double rating;
  final List<String> genres;
  final String releaseDate;
  final int runtime;

  Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.overview,
    required this.rating,
    required this.genres,
    required this.releaseDate,
    required this.runtime,
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
    );
  }
}