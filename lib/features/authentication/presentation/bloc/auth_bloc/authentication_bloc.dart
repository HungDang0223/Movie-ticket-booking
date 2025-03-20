import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/authentication_event.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/authentication_state.dart';
import 'package:movie_tickets/core/services/local/db_helper.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository authRepository;

  AuthenticationBloc({required this.authRepository}) : super(Uninitialized()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthenticationState> emit) async {
    try {
      final isSignedIn = await authRepository.isSignedIn();

      // Initialize database
      await DbHelper.init();

      // Show splash screen delay
      await Future.delayed(Duration(seconds: 2));

      if (isSignedIn) {
        final name = authRepository.getCurrentUser().data!.fullName;
        emit(Authenticated(name ?? 'name'));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    final name = authRepository.getCurrentUser().data!.fullName;
    print(authRepository.getCurrentUser().data!.fullName);
    emit(Authenticated(name ?? "name"));
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthenticationState> emit) {
    authRepository.logOut();
    emit(Unauthenticated());
  }
}
