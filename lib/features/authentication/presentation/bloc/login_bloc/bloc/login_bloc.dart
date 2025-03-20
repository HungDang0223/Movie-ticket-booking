import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/errors/failures.dart';
import 'package:movie_tickets/core/utils/validators.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/login_use_case.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(const LoginInitial()) {
    on<LoginSubmitEmailPasswordEvent>(_onLoginSubmit);
  }

  void _onLoginSubmit(
      LoginSubmitEmailPasswordEvent event, Emitter<LoginState> emit) async {
        emit(const LoginLoading());
    try {
      
      final loginUseCase = LoginUseCase(authRepository);
      final result = await loginUseCase.call(SignInParams(
        emailOrPhone: event.email,
        password: event.password,
      ));

      if (result.isSuccess) {
        print("sucessss");
        emit(LoginSuccess(result.data?.accessToken ?? ''));
      } else {
        emit(LoginFailed(result.failure!.message));
      }
    } catch (e) {
      emit(LoginFailed(e.toString()));
    }
  }
}
