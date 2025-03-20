import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_tickets/core/errors/exceptions.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/core/extensions/dio_exception_ext.dart';
import 'package:movie_tickets/core/services/local/shared_prefs_services.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';

class AuthReposImpl implements AuthRepository {
  
  final _prefs = sl<SharedPrefService>();
  final String _userKey = "user_info";
  final String isLoggedInKey = "is_logged_in";
  final dio = sl<Dio>();
  final AuthRemoteDatasource _authRemoteDataSource = AuthRemoteDatasource(sl<Dio>());

  @override
  Future<Result<SignupResponse>> signUpWithUserInfo(String fullName, String email, String phone, String password, String address, DateTime? birthDate, String? gender) async {
    try {
      String formattedDateOfBirth = birthDate != null
        ? birthDate.toIso8601String()
        : DateTime(DateTime.now().year - 13, DateTime.now().month, DateTime.now().day).toIso8601String();
      final body = <String, dynamic>{
        "fullName": fullName,
        "email": email,
        "phoneNumber": phone,
        "password": password,
        "gender": gender ?? "Nam",
        "dateOfBirth": formattedDateOfBirth,
        "address": address
      };
      log("Data: $body", name: "Sign up UC");
      final httpResponse = await _authRemoteDataSource.signUpWithUserInfo(body);
      log("Response: ${httpResponse.data}", name: "Sign up UC");
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        final response = httpResponse.data;
        return Result.success(response);
      } 
      else if (httpResponse.response.statusCode == HttpStatus.badRequest) {
        // Handle 400 errors
        final responseBody = httpResponse.response.data;
        final errorMessage = responseBody["message"] ?? "Invalid request data";
        return Result.fromFailure(ServerFailure("Bad Request: $errorMessage"));
      }
      else {
        return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown server error"));
      }
    } on ServerException catch (e) {
      return Result.fromFailure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.fromFailure(NetworkFailure(e.message));
    } on DioException catch (e) {
      return Result.fromFailure(ServerFailure("DioException: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }
  
  @override
  Result<UserModel> getCurrentUser() {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = googleSignIn.currentUser;
    if (account == null) {
      return Result.fromFailure(ServerFailure("No user is currently signed in"));
    }
    final user = UserModel.fromGoogleSignInAccount(account);
    
    return Result.success(user);
  }
  
  @override
  Future<bool> isSignedIn() async {
    bool isSignedIn = await _prefs.getValue(isLoggedInKey, type: bool) ?? false;
    return isSignedIn;
  }
  
  @override
  Future<Result<LoginResponse>> logInWithEmailOrPhoneAndPassword(String emailOrPhone, String password) async {
    try {
      final body = {"emailOrPhone": emailOrPhone, "password": password};
      
      // final response = await dio.post("http://192.168.1.2:5000/api/v1/Auth/login", data: body);
      // final data = response.data;
      // print(data);
      // final authRes = LoginResponse.fromJson(response.data);
      // return Result.success(authRes); // run correct
      try {
        final httpResponse = await _authRemoteDataSource.logInWithEmailOrPhoneAndPassword(body);
        log("Response: ${httpResponse.response.statusCode}", name: "Log in UC");

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          final loginRes = httpResponse.data;
          final user = loginRes.user;
          await _prefs.saveValue(_userKey, user.toJson());
          await _prefs.saveValue(isLoggedInKey, true);
          return Result.success(loginRes);
        } else {
          return Result.fromFailure(ServerFailure(httpResponse.response.statusMessage ?? "Unknown error"));
        }
      } on DioException catch (e) {
        log("DioException: ${e.response?.statusCode} - ${e.type.toPrettyDescription()} - ${e.message}", name: "Log in UC");
        
        return Result.fromFailure(ServerFailure(e.type.toPrettyDescription()));
      } catch (e) {
        log("Unknown Error: $e", name: "Log in UC");
        return Result.fromFailure(ServerFailure("Unknown Error: $e"));
      }

    } on ServerException catch (e) {
      return Result.fromFailure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Result.fromFailure(NetworkFailure(e.message));
    } on DioException catch (e) {
      return Result.fromFailure(ServerFailure("DioExceptionnnn: ${e.message}"));
    } catch (e) {
      return Result.fromFailure(ServerFailure("Unexpected error occurred: $e"));
    }
  }
  
  @override
  Future<Result<UserModel>> logInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("Google Sign-In was canceled");
    }

    // Retrieve authentication details
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    if (googleAuth.idToken == null || googleAuth.accessToken == null) {
      return Result.fromFailure(ServerFailure("Google Sign-In failed"));
    }

    final user = UserModel.fromGoogleSignInAccount(googleUser);
    await _prefs.saveValue(_userKey, user.toJson());
    await _prefs.saveValue(isLoggedInKey, true);
    return Result.success(user);
  }
  
  @override
  Future<void> logOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _prefs.removeValue(_userKey);
    await _prefs.saveValue(isLoggedInKey, false);
  }
  
}