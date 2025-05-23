import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/signup_use_case.dart';
import 'bloc.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository _authRepository;
  final SignUpUseCase _signupUseCase;

  SignupBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _signupUseCase = SignUpUseCase(authRepository),
        super(const SignupInitial()) {
    on<SignupSubmitForm>(_onFormSubmitted);
  }

  Future<void> _onFormSubmitted(
    SignupSubmitForm event,
    Emitter<SignupState> emit,
  ) async {
    if (state is SignupLoading) return; // Prevent multiple simultaneous requests
    
    emit(const SignupLoading());

    try {
      // Validate required fields
      if (!_validateSignupData(event)) {
        emit(const SignupFailed('Please fill in all required fields'));
        return;
      }

      final result = await _signupUseCase.call(
        SignUpParams(
          fullName: event.fullName.trim(),
          email: event.email.trim().toLowerCase(),
          phoneNumber: event.phoneNumber.trim(),
          password: event.password,
          gender: event.gender,
          dateOfBirth: event.dateOfBirth,
          address: event.address.trim(),
        ),
      );

      if (result.isSuccess && result.data != null) {
        emit(SignupSuccess(result.data!));
      } else {
        final errorMessage = result.failure?.message ?? 
                           result.data?.message ?? 
                           'Signup failed';
        emit(SignupFailed(errorMessage));
      }
    } catch (e) {
      emit(SignupFailed('Network error: ${e.toString()}'));
    }
  }

  bool _validateSignupData(SignupSubmitForm event) {
    return event.fullName.trim().isNotEmpty &&
           event.email.trim().isNotEmpty &&
           event.phoneNumber.trim().isNotEmpty &&
           event.password.isNotEmpty;
  }
}