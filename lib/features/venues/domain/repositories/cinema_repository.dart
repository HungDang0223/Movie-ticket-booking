import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/venues/data/models/cinema.dart';

abstract class CinemaRepository {
  Future<Result<List<CinemaResponse>>> GetCinemas();
  Future<Result<List<Cinema>>> GetCinemasByCity(int cityId);
  Future<Result<List<Cinema>>> GetCinemasByCityName(String cityName);
}