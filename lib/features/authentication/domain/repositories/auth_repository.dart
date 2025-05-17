import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Result<LoginResponse>> logInWithEmailOrPhoneAndPassword(String emailOrPhone, String password);
  Future<Result<SignupResponse>> signUpWithUserInfo(
    String fullName,
    String email,
    String phoneNumber,
    String password,
    String address,
    DateTime? dateOfBirth,
    String? gender
  );
  Future<void> logOut();
  Future<bool> isSignedIn();
  Future<Result<UserModel>> getCurrentUser();
  Future<Result<String>> sendEmailAuthRequest(String email);
  Future<Result<RegularResponse>> verifyCode(String email, String code);
}