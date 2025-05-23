import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user]; // Ensure proper equality comparison

  @override
  String toString() {
    return 'Authenticated{user: $user}';
  }
}

class Unauthenticated extends AuthenticationState {}

class EmailVerificationInitial extends AuthenticationState {}

class EmailRequestSentSuccessfully extends AuthenticationState {}

class SendEmailRequestFailed extends AuthenticationState {
  final String message;
  const SendEmailRequestFailed(this.message);
}

class EmailVerificatedSuccessfully extends AuthenticationState {}

class EmailVerificateFailed extends AuthenticationState {
  final String message;
  const EmailVerificateFailed(this.message);
}
