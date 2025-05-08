import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged({required this.email});

  @override
  List<Object> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged({required this.password});

  @override
  List<Object> get props => [];
}

class LoginSubmitEmailPasswordEvent extends LoginEvent {
  final String emailPhone;
  final String password;

  const LoginSubmitEmailPasswordEvent({required this.emailPhone, required this.password});

  @override
  List<Object> get props => [emailPhone, password];
}
