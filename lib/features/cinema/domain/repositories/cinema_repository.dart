import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/cinema/data/models/cinema.dart';

abstract class CinemaRepository {
  Future<Result<CinemaResponse>> getCinemas();
  Future<Result<List<Cinema>>> getCinemasByCityId(int cityId);
  Future<Result<List<Cinema>>> getCinemasByCityName(String cityName);
}