import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:retrofit/retrofit.dart';

// @RestApi(baseUrl: baseURL)
// abstract class BookingSnackRemoteDataSource {
//   factory BookingSnackRemoteDataSource(Dio dio) = _BookingSnackRemoteDataSource;

//   // Get all snacks
//   @GET('/snacks')
//   Future<HttpResponse<List<SnackDto>>> getAllSnacks();

//   // Get snacks by category
//   @GET('/snacks/category/{categoryId}')
//   Future<HttpResponse<List<SnackDto>>> getSnacksByCategory(@Path('categoryId') int categoryId);
// }