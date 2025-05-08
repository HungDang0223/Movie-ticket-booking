import 'package:movie_tickets/core/commons/app_nav_bar.dart';
import 'package:movie_tickets/core/configs/routes.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/features/booking/presentation/pages/showing_movie_booking.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/movie_bloc/movie_event.dart';
import 'package:movie_tickets/features/movies/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/movies/presentation/pages/movie_detail.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:movie_tickets/features/payment/presentation/pages/payment_page.dart';
import 'package:movie_tickets/features/setting/domain/repositories/settings_repository.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_bloc.dart';
import 'package:movie_tickets/features/setting/presentation/pages/setting_page.dart';
import 'package:movie_tickets/features/venues/presentation/pages/venues_page.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/signup_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login/login_page.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/register/signup_page.dart';
import 'package:movie_tickets/features/sc_splash.dart';

import 'features/authentication/presentation/bloc/auth_bloc/bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    initSystemDefault();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthenticationBloc>()..add(AppStarted())),
        BlocProvider(create: (context) => sl<LoginBloc>()),
        BlocProvider(create: (context) => sl<SignupBloc>()),
        BlocProvider(create: (context) => sl<PaymentBloc>()),
        BlocProvider(create: (context) => sl<SettingsBloc>()),
        BlocProvider(create: (context) => sl<MovieBloc>()..add(const GetListShowingMoviesEvent()),),
      ], // Get bloc from GetIt
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        title: 'Movie Ticket Booking',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColor.DEFAULT,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColor.DEFAULT),
          hoverColor: AppColor.GREEN,
          fontFamily: 'Poppins',
        ),
        // supportedLocales: [
        //   Locale('vi', 'VN'),
        //   Locale('en', 'US')
        // ],
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              // if (state is Uninitialized) {
              //   return LoginPage();
              // } else if (state is Unauthenticated) {
              //   return LoginPage();
              // } else if (state is Authenticated) {
              //   return MainScreen();
              // }
              return MainScreen();
            },
          )
          // home: PaymentPage(
          //     movieTitle: "movieTitle",
          //     theaterName: "theaterName",
          //     showDate: "23/02/2025",
          //     showTime: "10:00",
          //     selectedSeats: ["1", "2", "3"],
          //     ticketPrice: 100000,
          //     selectedSnacks: {"Snack1": 100000, "Snack2": 100000},
          //     snacksPrice: 100000)
          // home: LoginPage(),
      ),
    );
  }

  static void initSystemDefault() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColor.STATUS_BAR,
      ),
    );
  }
}

// First, create a new widget to handle the bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomePage(),
    VenuesPage(),
    PaymentPage(
      movieTitle: "movieTitle",
      theaterName: "theaterName",
      showDate: "23/02/2025",
      showTime: "10:00",
      selectedSeats: ["1", "2", "3"],
      ticketPrice: 100000,
      selectedSnacks: {"Snack1": 100000, "Snack2": 100000},
      snacksPrice: 100000),
    HomePage(), // Replace with GroupPage when available
    SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
