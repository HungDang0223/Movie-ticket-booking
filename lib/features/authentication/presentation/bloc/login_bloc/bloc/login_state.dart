import 'package:movie_tickets/core/errors/failures.dart';
import 'package:flutter/material.dart';

@immutable
abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final String accessToken;
  const LoginSuccess(this.accessToken);
}

class LoginFailed extends LoginState {
  final String message;
  const LoginFailed(this.message);
}