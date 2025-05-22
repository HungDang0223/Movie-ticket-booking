import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/authentication/data/models/auth_response.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<SignupResponse, SignUpParams> {
  final AuthRepository authRepository;
  SignUpUseCase(this.authRepository);

  @override
  Future<Result<SignupResponse>> call(SignUpParams params) async {
    return await authRepository.signUpWithUserInfo(
        params.fullName,
        params.email,
        params.phoneNumber,
        params.password,
        params.address,
        params.dateOfBirth ?? DateTime(DateTime.now().year - 13, DateTime.now().month, DateTime.now().day),
        params.gender ?? 'Nam');
  }
}

class SignUpParams {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  String? gender;
  DateTime? dateOfBirth;
  final String address;

  SignUpParams(
      {required this.fullName,
      required this.email,
      required this.phoneNumber,
      required this.password,
      required this.address,
      this.gender,
      this.dateOfBirth});
}
