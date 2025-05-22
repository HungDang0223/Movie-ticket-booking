
abstract class Movie {
  final int movieId;
  final String title;
  final DateTime releaseDate;
  final int duration;
  final double rating;
  final String synopsis;
  final String posterUrl;
  final String trailerUrl;
  final String censor;
  final String cast;
  final String directors;
  final String genre;
  final DateTime showingDate;
  final DateTime endDate;
  final String showingStatus;
  final bool isSpecial;
  final int favouritesCount;
  final bool isFavourited;

  Movie(
      {required this.movieId,
      required this.title,
      required this.releaseDate,
      required this.duration,
      required this.rating,
      required this.synopsis,
      required this.posterUrl,
      required this.trailerUrl,
      required this.censor,
      required this.cast,
      required this.directors,
      required this.genre,
      required this.showingDate,
      required this.endDate,
      required this.showingStatus,
      required this.isSpecial,
      required this.favouritesCount,
      required this.isFavourited});
}
