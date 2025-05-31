import 'package:flutter/material.dart';
import 'package:movie_tickets/app.dart';
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
import 'package:movie_tickets/features/setting/presentation/pages/account_options_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/change_password_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/password_verification_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/setting_page.dart';
import 'package:movie_tickets/features/setting/presentation/pages/user_info_page.dart';
import 'package:movie_tickets/features/venues/data/models/cinema.dart';
import 'package:movie_tickets/features/venues/presentation/pages/cinema_detail_page.dart';

class Routes {
  static const String home = '/home';
  static const String cinema = '/cinema';
  static const String movie = '/movie';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String cinemaDetail = '/cinema_detail';
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
        return _materialRoute(MainScreen(0));

      case '/cinema':
        return _materialRoute(MainScreen(1));

      case '/login':
        return _materialRoute(const LoginPage());

      case '/signup':
        return _materialRoute(const SignupPage());

      case '/cinema_detail':
        final cinema = settings.arguments as Cinema;
        return _materialRoute(CinemaDetailPage(cinema: cinema));

      case '/movie_detail':
        final movie = settings.arguments as MovieModel;
        return _materialRoute(MovieDetailScreen(movie: movie,));

      case 'Routes.showingMovieBooking':
        final args = settings.arguments as Map<String, dynamic>;
        final movie = args['movie'] as MovieModel?;
        final cinema = args['cinema'] as Cinema?;
        return _materialRoute(ShowingMovieBookingScreen(movie: movie, cinema: cinema));

      case '/seat_booking':
        // movie + movie showing
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(BookingSeatPage(
          title: args['title'],
          showingMovie: args['showingMovie'],
          websocketUrl: args['websocketUrl'],
          userId: args['userId'],
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
        return _materialRoute(const UserInfoPage());

      case Routes.changePassword:
        return _materialRoute(const ChangePasswordPage());
      
      case Routes.emailVerification:
        final email = settings.arguments as String;
        return _materialRoute(EmailVerificationPage(email: email));
        
      default:
        return _materialRoute(const HomePage());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}