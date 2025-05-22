import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/signup_use_case.dart';

import 'bloc.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;

  SignupBloc({required this.authRepository}) : super(const SignupInitial()) {
    on<SignupSubmitForm>(_onFormSubmitted);
  }

  Future<void> _onFormSubmitted(
    SignupSubmitForm event,
    Emitter<SignupState> emit,
  ) async {
    emit(const SignupLoading());

    try {
      final signupUseCase = SignUpUseCase(authRepository);
      final result = await signupUseCase.call(
        SignUpParams(
          fullName: event.fullName,
          email: event.email,
          phoneNumber: event.phoneNumber,
          password: event.password,
          gender: event.gender,
          dateOfBirth: event.dateOfBirth,
          address: event.address)
      );
      if (result.isSuccess) {
        print(result.data);
        if (result.data != null) {
          emit(SignupSuccess(result.data!));
        } else {
          emit(const SignupFailed("Signup response data is null"));
        }
      } else {
        emit(SignupFailed(result.data!.message));
      }
      
    } catch (e) {
      emit(SignupFailed(e.toString()));
    }
  }
}
