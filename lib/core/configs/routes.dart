import 'package:flutter/material.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/email_verification_page.dart';
import 'package:movie_tickets/features/booking/presentation/pages/booking_seat.dart';
import 'package:movie_tickets/features/booking/presentation/pages/booking_showing_movie.dart';
import 'package:movie_tickets/features/booking/presentation/pages/booking_snack.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/signup_page.dart';
import 'package:movie_tickets/features/movies/presentation/pages/movie_detail.dart';
import 'package:movie_tickets/features/payment/presentation/pages/payment_page.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_bloc.dart';
import 'package:movie_tickets/features/setting/presentation/pages/account_options_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/change_password_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/password_verification_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/setting_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/user_info_page.dart';

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String movieDetail = '/movie_detail';
  static const String showingMovieBooking = '/showing_movie_booking';
  static const String seatBooking = '/seat_booking';
  static const String snackBooking = '/snack_booking';
  static const String payment = '/payment';
  static const String setting = '/setting';
  static const String passwordVerification = '/password-verification';
  static const String accountOptions = '/account-options';
  static const String userInfo = '/user-info';
  static const String changePassword = '/change-password';
  static const String emailVerification = '/email-verification';
}

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return _materialRoute(HomePage());

      case '/login':
        return _materialRoute(const LoginPage());

      case '/signup':
        return _materialRoute(SignupPage());

      case '/movie_detail':
        final movie = settings.arguments as MovieModel;
        return _materialRoute(MovieDetailScreen(movie: movie,));

      case '/showing_movie_booking':
        final movie = settings.arguments as MovieModel;
        return _materialRoute(ShowingMovieBookingScreen(movie: movie));
        
      case '/seat_booking':
        // movie + movie showing
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(BookingSeatScreen(
          movie: args['movie'],
          showingMovie: args['showingMovie'],
        ));

      case '/snack_booking':
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SnackSelectionScreen(
          movieTitle: args['movieTitle'],
          theaterName: args['theaterName'],
          showTime: args['showTime'],
          showDate: args['showDate'],
          selectedSeats: args['selectedSeats'],
          ticketPrice: args['ticketPrice']
        ));

      case '/payment':
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(PaymentPage(
          movieTitle: args['movieTitle'],
          theaterName: args['theaterName'], 
          showDate: args['showDate'],
          showTime: args['showTime'],
          selectedSeats: args['selectedSeats'],
          ticketPrice: args['ticketPrice'],
          selectedSnacks: args['selectedSnacks'],
          snacksPrice: args['snacksPrice'],
        ));

      case Routes.setting:
        return _materialRoute(const SettingPage());
      
      case Routes.passwordVerification:
        return _materialRoute(const PasswordVerificationPage());

      case Routes.accountOptions:
        return _materialRoute(const AccountOptionsPage());
      
      case Routes.userInfo:
        // final user = settings.arguments as UserModel;
        return _materialRoute(UserInfoPage());

      case Routes.changePassword:
        return _materialRoute(const ChangePasswordPage());
      
      case Routes.emailVerification:
        final email = settings.arguments as String;
        return _materialRoute(EmailVerificationPage(email: email));
        
      default:
        return _materialRoute(HomePage());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}