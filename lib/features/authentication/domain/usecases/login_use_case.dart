import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<LoginResponse, SignInParams> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Result<LoginResponse>> call(SignInParams params) async {
    // return 
    print(params.emailOrPhone + params.password);
    try {
      final res = await _repository.logInWithEmailOrPhoneAndPassword(params.emailOrPhone, params.password);
    // final a = await _userRemoteDatasource.getUsers();
      res.isSuccess == true ? print(res.data!.accessToken) : print(res.failure!.message);
      // print(a.data);
      return res;
    } catch (e) {
      log("Login error: $e", name: "Login UC");
      return Result.fromFailure(ServerFailure("$e"));
    }
  }
}

class SignInParams {
  final String emailOrPhone;
  final String password;

  SignInParams({required this.emailOrPhone, required this.password});
}