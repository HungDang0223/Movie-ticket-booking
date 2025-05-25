import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/login_use_case.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    required this.authRepository,
    required this.authenticationBloc
  }) : super(const LoginInitial()) {
    on<LoginSubmitEmailPasswordEvent>(_onLoginSubmit);
  }

  void _onLoginSubmit(
      LoginSubmitEmailPasswordEvent event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      final loginUseCase = LoginUseCase(authRepository);
      final result = await loginUseCase.call(SignInParams(
        emailOrPhone: event.emailPhone,
        password: event.password,
      ));

      if (result.isSuccess && result.data != null) {
        print("sucessss");
        String accessToken = result.data?.accessToken ?? '';
        print("accessToken: $accessToken");
        // Notify AuthenticationBloc about successful login
        authenticationBloc.add(LoggedIn());
        emit(LoginSuccess(accessToken));
      } else {
        emit(LoginFailed(result.failure!.message));
      }
    } catch (e) {
      emit(LoginFailed(e.toString()));
    }
  }
}
