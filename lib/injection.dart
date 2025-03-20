
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_tickets/config/firebase_options.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/login_use_case.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/signup_use_case.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:movie_tickets/core/services/local/shared_prefs_services.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:movie_tickets/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/signup_bloc/bloc.dart';
import 'package:movie_tickets/user_remote_resource.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Firebase initialization
  final firebaseApp = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sl.registerSingleton(firebaseApp);

  // Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio instance with configuration
  final dio = Dio(BaseOptions(
    baseUrl: "http://192.168.1.2:5000/api/v1/",
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ))..interceptors.add(LogInterceptor(responseBody: true));

  sl.registerSingleton<Dio>(dio);

  // Shared Preferences Service
  final sharedPrefService = SharedPrefService();
  await sharedPrefService.init();
  sl.registerSingleton<SharedPrefService>(sharedPrefService);

  // Register data sources
  sl.registerSingleton<AuthRemoteDatasource>(AuthRemoteDatasource(sl<Dio>())); 
  sl.registerSingleton<AuthLocalDataSource>(AuthLocalDataSource());  
  sl.registerSingleton<UserRemoteResource>(UserRemoteResource(sl()));

  // Register repository
  sl.registerLazySingleton<AuthRepository>(() => AuthReposImpl());

  // Register use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));

  // Register blocs
  sl.registerFactory(() => AuthenticationBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => LoginBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => SignupBloc(authRepository: sl<AuthRepository>()));
}
