import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:movie_tickets/features/movies/data/models/movie.dart';

@JsonSerializable()
class MovieModel extends Movie with EquatableMixin {
  MovieModel({required super.id, required super.title, required super.overview, required super.posterPath, required super.backdropPath, required super.voteAverage, required super.releaseDate});
  
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

}