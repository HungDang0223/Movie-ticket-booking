import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'package:movie_tickets/core/commons/app_nav_bar.dart';
import 'package:movie_tickets/core/configs/routes.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/showing_movie_bloc/showing_movie_bloc.dart';
import 'package:movie_tickets/features/movies/presentation/bloc/bloc.dart';
import 'package:movie_tickets/features/movies/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:movie_tickets/features/payment/presentation/pages/payment_page.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_bloc.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/setting_event.dart';
import 'package:movie_tickets/features/setting/presentation/bloc/settings_state.dart';
import 'package:movie_tickets/features/setting/presentation/pages/setting_page.dart';
import 'package:movie_tickets/features/venues/presentation/pages/venues_page.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/signup_bloc/bloc.dart';
import 'package:movie_tickets/core/utils/app_localizations.dart';

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
        BlocProvider(create: (context) => sl<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(create: (context) => sl<MovieBloc>()),
        BlocProvider(create: (context) => sl<ReviewBloc>()),
        BlocProvider(create: (context) => sl<ShowingMovieBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isDarkMode = state is SettingsLoaded ? state.isDarkMode : false;
          LocalJsonLocalization.delegate.directories = ['assets/i18n'];
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRoutes.onGenerateRoutes,
            title: 'Movie Ticket Booking',
            theme: ThemeData(
              primarySwatch: Colors.pink,
              brightness: Brightness.light,
              primaryColor: AppColor.DEFAULT,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.pink,
              brightness: Brightness.dark,
              primaryColor: AppColor.DEFAULT,
              scaffoldBackgroundColor: Colors.grey[900],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black12,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US')
            ],            
            localizationsDelegates: [
              LocalJsonLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],            
            locale: state is SettingsLoaded 
              ? Locale(state.languageCode, state.countryCode)
              : const Locale('vi', 'VN'),
            localeResolutionCallback: AppLocalizations.localeResolutionCallback,
            home: const MainScreen(), // Use SplashScreen as the initial screen
          );
        },
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
    const HomePage(),
    const VenuesPage(),
    const PaymentPage(
      movieTitle: "movieTitle",
      theaterName: "theaterName",
      showDate: "23/02/2025",
      showTime: "10:00",
      selectedSeats: ["1", "2", "3"],
      ticketPrice: 10000,
      selectedSnacks: {"Snack1": 10000, "Snack2": 10000},
      snacksPrice: 10000),
    const HomePage(), // Replace with GroupPage when available
    const SettingPage(),
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
