import 'package:dio/dio.dart';
import 'package:movie_tickets/core/constants/strings.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_remote_data_source.g.dart';

@RestApi(baseUrl: authAPIBaseURL)
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST('/login')
  Future<HttpResponse<LoginResponse>> logInWithEmailOrPhoneAndPassword(
    // param String emailOrPhone
    //param String password
    @Body() Map<String, dynamic> body,
  );

  @POST('/signup')
  Future<HttpResponse<SignupResponse>> signUpWithUserInfo(
    // @Field('emailOrPhone') String emailOrPhone,
    // @Field('password') String password,
    // @Field('firstName') String firstName,
    // @Field('lastName') String lastName,
    // @Field('phoneNumber') String phoneNumber,
    // @Field('address') String address,
    // @Field('dateOfBirth') String dateOfBirth,
    @Body() Map<String, dynamic> body,
  );

  @POST('/send-email-verify')
  Future<HttpResponse<Map<String, String>>> sendEmailAuthRequest(
    @Body() Map<String, dynamic> email
  );

  @POST('/verify-code')
  Future<HttpResponse<RegularResponse>> verifyCode(
    @Body() Map<String, dynamic> body
  );

  @POST('/refresh-token')
  Future<HttpResponse<AuthResponse>> refreshToken(
    @Field('refreshToken') String refreshToken,
  );
}