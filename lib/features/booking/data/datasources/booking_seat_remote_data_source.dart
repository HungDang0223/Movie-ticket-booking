import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/booking/data/models/seat.dart';
import 'package:movie_tickets/features/booking/data/models/showing_seat.dart';
import 'package:retrofit/retrofit.dart';

part 'booking_seat_remote_data_source.g.dart';

@RestApi(baseUrl: baseURL)
abstract class BookingSeatRemoteDataSource {
  factory BookingSeatRemoteDataSource(Dio dio) = _BookingSeatRemoteDataSource;

  @GET('/screen/{screenId}/seats')
  Future<HttpResponse<List<RowSeatsDto>>> getSeatsByScreen(@Path('screenId') int screenId);

  // Reserve seat
  @POST('/seat-reserve/reserve')
  Future<HttpResponse<RegularResponse>> reserveSeat(@Body() ReserveSeatRequest request);

  // Confirm reservation
  @POST('/seat-reserve/confirm')
  Future<HttpResponse<RegularResponse>> confirmReservation(@Body() ReserveSeatRequest request);

  // Cancel reservation
  @POST('/seat-reserve/cancel')
  Future<HttpResponse<RegularResponse>> cancelReservation(@Body() ReserveSeatRequest request);
}