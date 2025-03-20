import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String displayName;

  const Authenticated(this.displayName);

  @override
  List<Object> get props => [displayName]; // Ensure proper equality comparison

  @override
  String toString() {
    return 'Authenticated{displayName: $displayName}';
  }
}

class Unauthenticated extends AuthenticationState {}
