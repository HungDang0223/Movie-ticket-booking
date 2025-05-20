
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_tickets/core/configs/firebase_options.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/login_use_case.dart';
import 'package:movie_tickets/features/authentication/domain/usecases/signup_use_case.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';
import 'package:movie_tickets/core/services/local/shared_prefs_services.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:movie_tickets/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:movie_tickets/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/signup_bloc/bloc.dart';
import 'package:movie_tickets/features/booking/data/datasources/booking_seat_remote_data_source.dart';
import 'package:movie_tickets/features/booking/data/datasources/showing_movie_remote_data_source.dart';
import 'package:movie_tickets/features/booking/data/repositories/booking_seat_repository_impl.dart';
import 'package:movie_tickets/features/booking/data/repositories/showing_movie_repository_impl.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_seat_repository.dart';
import 'package:movie_tickets/features/booking/domain/repositories/showing_movie_repository.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/bloc.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_seat_bloc/booking_seat_bloc.dart';
import 'package:movie_tickets/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/datasources/review_remote_datasource.dart';
import 'package:movie_tickets/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_tickets/features/movies/data/repositories/review_repository_impl.dart';
import 'package:movie_tickets/features/movies/domain/entities/movie.dart';
import 'package:movie_tickets/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_tickets/features/movies/domain/repositories/review_repository.dart';
import 'package:movie_tickets/features/movies/domain/usecases/get_list_movie_uc.dart';
import 'package:movie_tickets/features/movies/domain/usecases/get_movie_detail_uc.dart';
import 'package:movie_tickets/features/movies/domain/usecases/get_movie_review_uc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/review_bloc/review_bloc.dart';
import 'package:movie_tickets/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:movie_tickets/features/payment/domain/repositories/payment_repository.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:movie_tickets/features/setting/data/datasources/settings_local_datasource.dart';
import 'package:movie_tickets/features/setting/data/repositories/settings_repository_impl.dart';
import 'package:movie_tickets/features/setting/domain/repositories/settings_repository.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Firebase initialization
  final firebaseApp = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sl.registerSingleton(firebaseApp);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio instance with configuration
  final dio = Dio(BaseOptions(
    baseUrl: "https://skunk-elegant-hideously.ngrok-free.app/api/v1",
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning':'true',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 5),
  ))..interceptors.add(LogInterceptor(responseBody: true));

  sl.registerSingleton<Dio>(dio);

  // Shared Preferences Service
  final sharedPrefService = SharedPrefService();
  await sharedPrefService.init();
  sl.registerSingleton<SharedPrefService>(sharedPrefService);

  // Register data sources
  sl.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSource(sl())); 
  sl.registerSingleton<AuthLocalDataSource>(AuthLocalDataSource(sl()));  
  sl.registerSingleton<MovieRemoteDatasource>(MovieRemoteDatasource(sl()));
  sl.registerSingleton<ReviewRemoteDatasource>(ReviewRemoteDatasource(sl()));
  sl.registerSingleton<ShowingMovieRemoteDataSource>(ShowingMovieRemoteDataSource(sl()));
  sl.registerSingleton<SettingsLocalDataSource>(SettingsLocalDataSourceImpl(sl<SharedPrefService>()));
  sl.registerSingleton<BookingSeatRemoteDataSource>(BookingSeatRemoteDataSource());
  

  // Register repository
  sl.registerLazySingleton<AuthRepository>(() => AuthReposImpl(sl<AuthLocalDataSource>(), sl<AuthRemoteDataSource>()));
  sl.registerLazySingleton<MovieRepository>(() => MovieRepositoryImpl());
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl());
  sl.registerLazySingleton<ShowingMovieRepository>(() => ShowingMovieRepositoryImpl());
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl<SettingsLocalDataSource>(), sl<AuthRepository>()));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl());
  sl.registerLazySingleton<BookingSeatRepository>(() => BookingSeatRepositoryImpl(seatService: sl<BookingSeatRemoteDataSource>()));
  
  // Register use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetListMoviesUseCase(sl()));
  sl.registerLazySingleton(() => GetMovieDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetMovieModelUseCase(sl()));

  // Register blocs
  sl.registerFactory(() => AuthenticationBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => LoginBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => SignupBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => MovieBloc(movieRepository: sl<MovieRepository>()));
  sl.registerFactory(() => ReviewBloc(reviewRepository: sl<ReviewRepository>()));
  sl.registerFactory(() => ShowingMovieBloc(repository: sl<ShowingMovieRepository>()));
  sl.registerFactory(() => BookingSeatBloc(bookingSeatRepository: sl<BookingSeatRepositoryImpl>()));
  sl.registerFactory(() => PaymentBloc(paymentRepository: sl<PaymentRepository>()));
  sl.registerFactory(() => SettingsBloc(sl<SettingsRepository>()));
}
