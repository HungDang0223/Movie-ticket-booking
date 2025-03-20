import 'package:flutter/material.dart';
import 'package:movie_tickets/features/home/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login/login_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/register/signup_page.dart';
import 'package:movie_tickets/features/movies/presentation/pages/movie_detail.dart';

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
      return _materialRoute(MovieDetailScreen());
        
      default:
        return _materialRoute(LoginPage());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}