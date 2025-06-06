import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/movies/domain/entities/movie.dart';

class MovieModel extends Movie with EquatableMixin {
  MovieModel({
    required super.movieId,
    required super.title,
    required super.releaseDate,
    required super.duration,
    required super.rating,
    required super.synopsis,
    required super.posterUrl,
    required super.trailerUrl,
    required super.censor,
    required super.cast,
    required super.directors,
    required super.genre,
    required super.showingDate,
    required super.endDate,
<<<<<<< HEAD
    required super.showingStatus,
=======
    required super.showingStatus, // upcoming, showing, ended
>>>>>>> 32bc590bda4bb23396a8e21652ce4e328417ad15
    required super.favouritesCount,
    required super.isFavourited
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      movieId: json['movieId'],
      title: json['title'],
      releaseDate: DateTime.parse(json['releaseDate']),
      duration: json['duration'],
      rating: (json['rating'] as num).toDouble(),
      synopsis: json['synopsis'],
      posterUrl: json['posterUrl'],
      trailerUrl: json['trailerUrl'],
      censor: json['censor'],
      cast: json['cast'],
      directors: json['directors'],
      genre: json['genre'],
      showingDate: DateTime.parse(json['showingDate']),
      endDate: DateTime.parse(json['endDate']),
      showingStatus: json['showingStatus'],
      favouritesCount: json['favouritesCount'],
      isFavourited: json['isFavourited']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'title': title,
      'releaseDate': releaseDate.toIso8601String(),
      'duration': duration,
      'rating': rating,
      'synopsis': synopsis,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'censor': censor,
      'cast': cast,
      'directors': directors,
      'genre': genre,
      'showingDate': showingDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'showingStatus': showingStatus,
    };
  }

  Map<String, dynamic> movieInfo() {
    return {
      'Kiểm duyệt': censor,
      'Diễn viên': cast,
      'Đạo diễn': directors,
      'Thể loại': genre,
    };
  }

  factory MovieModel.empty() {
    return MovieModel(
      movieId: 0,
      title: '',
      releaseDate: DateTime.now(),
      duration: 0,
      rating: 0.0,
      synopsis: '',
      posterUrl: '',
      trailerUrl: '',
      censor: '',
      cast: '',
      directors: '',
      genre: '',
      showingDate: DateTime.now(),
      endDate: DateTime.now(),
      showingStatus: '',
      favouritesCount: 0,
      isFavourited: false,
    );
  }

  @override
  List<Object?> get props => [
        movieId,
        title,
        releaseDate,
        duration,
        rating,
        synopsis,
        posterUrl,
        trailerUrl,
        censor,
        cast,
        directors,
        genre,
        showingDate,
        endDate,
        showingStatus,
      ];
}