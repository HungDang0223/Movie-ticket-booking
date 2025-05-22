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
    on<SendEmailAuthRequest>(_sendEmailAuthRequest);
    on<VerifyCodeRequest>(_verifyCode);
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthenticationState> emit) async {
    try {
      final isSignedIn = await authRepository.isSignedIn();

      // Initialize database
      await DbHelper.init();

      // Show splash screen delay
      await Future.delayed(const Duration(seconds: 2));

      if (isSignedIn) {
        final result = await authRepository.getCurrentUser();
        final name = result.data!.fullName;
        emit(Authenticated(name));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future _onLoggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    final result = await authRepository.getCurrentUser();
    final name = result.data!.fullName;
    print(name);
    emit(Authenticated(name));
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthenticationState> emit) {
    authRepository.logOut();
    emit(Unauthenticated());
  }

  Future _sendEmailAuthRequest(SendEmailAuthRequest event, Emitter<AuthenticationState> emit) async {
    emit(EmailVerificationInitial());
    try {
      final result = await authRepository.sendEmailAuthRequest(event.email);
      if (result.isSuccess) {
        emit(EmailRequestSentSuccessfully());
      } else {
        emit(SendEmailRequestFailed(result.failure!.message));
      }
    } catch (e) {
      emit(SendEmailRequestFailed(e.toString()));
    }
  }

  Future _verifyCode(VerifyCodeRequest event, Emitter<AuthenticationState> emit) async {
    emit(EmailVerificationInitial());
    try {
      final result = await authRepository.verifyCode(event.email, event.code);
      if (result.isSuccess) {
        emit(EmailVerificatedSuccessfully());
      } else {
        emit(EmailVerificateFailed(result.failure!.message));
      }
    } catch (e) {
      emit(EmailVerificateFailed(e.toString()));
    }
  }
}
