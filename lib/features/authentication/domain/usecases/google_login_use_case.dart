import 'package:movie_tickets/core/usecase/use_case.dart';
import 'package:movie_tickets/core/utils/result.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';

class GoogleLoginUseCase implements UseCase<UserModel, void> {
  final AuthRepository _repository;

  GoogleLoginUseCase(this._repository);

  @override
  Future<Result<UserModel>> call(void params) async {
    return _repository.logInWithGoogle();
  }
}