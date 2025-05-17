import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}

class SendEmailAuthRequest extends AuthenticationEvent {
  final String email;
  const SendEmailAuthRequest(this.email);
  @override
  List<Object> get props => [email];
}

class VerifyCodeRequest extends AuthenticationEvent {
  final String email;
  final String code;
  const VerifyCodeRequest(this.email, this.code);
  @override
  List<Object> get props => [email, code];
}

