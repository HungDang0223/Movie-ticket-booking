import 'package:movie_tickets/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_remote_data_source.dart';

class AuthReposImpl {
  final AuthRemoteDatasource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  AuthReposImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  // Future<Either<Failure, User>> login(String email, String password) async {
  //   try {
  //     final user = await authRemoteDataSource.login(email, password);
  //     authLocalDataSource.saveUser(user);
  //     return Right(user);
  //   } on ServerException {
  //     return Left(ServerFailure());
  //   }
  // }

  // Future<Either<Failure, User>> register(String email, String password) async {
  //   try {
  //     final user = await authRemoteDataSource.register(email, password);
  //     authLocalDataSource.saveUser(user);
  //     return Right(user);
  //   } on ServerException {
  //     return Left(ServerFailure());
  //   }
  // }

  // Future<Either<Failure, User>> getCurrentUser() async {
  //   try {
  //     final user = await authLocalDataSource.getUser();
  //     return Right(user);
  //   } on CacheException {
  //     return Left(CacheFailure());
  //   }
  // }

  // Future<void> logout() async {
  //   await authLocalDataSource.removeUser();
  // }
}