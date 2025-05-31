import 'package:equatable/equatable.dart';

class CinemaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class GetCinemas extends CinemaEvent {
  final int? cityId;
  final String? cityName;

  GetCinemas({this.cityId, this.cityName});

  @override
  List<Object?> get props => [cityId, cityName];
}
class GetCinemasByCityId extends CinemaEvent {
  final int cityId;

  GetCinemasByCityId(this.cityId);

  @override
  List<Object?> get props => [cityId];
}
class GetCinemasByCityName extends CinemaEvent {
  final String cityName;

  GetCinemasByCityName(this.cityName);

  @override
  List<Object?> get props => [cityName];
}