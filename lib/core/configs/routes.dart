import 'package:flutter/material.dart';
import 'package:movie_tickets/features/booking/presentation/pages/seat_booking.dart';
import 'package:movie_tickets/features/booking/presentation/pages/showing_movie_booking.dart';
import 'package:movie_tickets/features/booking/presentation/pages/snack_booking.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/features/movies/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login/login_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/register/signup_page.dart';
import 'package:movie_tickets/features/movies/presentation/pages/movie_detail.dart';
import 'package:movie_tickets/features/payment/presentation/pages/payment_page.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return _materialRoute(HomePage());

      case '/login':
        return _materialRoute(LoginPage());

      case '/signup':
        return _materialRoute(SignupPage());

      case '/movie_detail':
        final movie = settings.arguments as MovieModel;
        return _materialRoute(MovieDetailScreen(movie: movie,));

      case '/showing_movie_booking':
        return _materialRoute(ShowingMovieBookingScreen());
        
      case '/seat_booking':
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SeatBookingScreen(
          movieTitle: args['movieTitle'],
          theaterName: args['theaterName'],
          showTime: args['showTime'], 
          showDate: args['showDate']
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
        
      default:
        return _materialRoute(LoginPage());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}