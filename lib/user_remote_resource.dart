import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:retrofit/retrofit.dart';

part 'user_remote_resource.g.dart';

@RestApi(baseUrl: baseURL)
abstract class UserRemoteResource {
  factory UserRemoteResource(Dio dio) = _UserRemoteResource;

  @GET("user")
  Future<HttpResponse<List<UserModel>>> getUsers();
}