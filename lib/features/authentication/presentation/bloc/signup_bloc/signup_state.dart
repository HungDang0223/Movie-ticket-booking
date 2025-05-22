import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';

abstract class SignupState {
  const SignupState();
}

class SignupInitial extends SignupState {
  const SignupInitial();
}

class SignupLoading extends SignupState {
  const SignupLoading();
}

class SignupSuccess extends SignupState {
  final SignupResponse data;
  const SignupSuccess(this.data);
}

class SignupFailed extends SignupState {
  final String message;

  const SignupFailed(this.message);
}