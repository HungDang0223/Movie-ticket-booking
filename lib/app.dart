import 'package:movie_tickets/core/configs/routes.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/features/booking/presentation/pages/movie_booking.dart';
import 'package:movie_tickets/features/home/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/movies/presentation/pages/movie_detail.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/login_bloc/bloc/bloc.dart';
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
        // home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        //     builder: (context, state) {
        //       if (state is Uninitialized) {
        //         return HomePage();
        //       } else if (state is Unauthenticated) {
        //         return const HomePage();
        //       } else if (state is Authenticated) {
        //         return HomePage();
        //       }
        //       return HomePage();
        //     },
          // )
        home: MovieBookingScreen()
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


  // static Widget runWidget() {
  //   WidgetsFlutterBinding.ensureInitialized();

  //   Bloc.observer = SimpleBlocObserver();

  //   return FutureBuilder(
  //     future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         final UserRepository userRepository = UserRepository();
  //         final HomeRepository homeRepository = HomeRepository();
  //         final ShowRepository showRepository = ShowRepository();
  //         final BookTimeSlotRepository bookTimeSlotRepository =
  //             RemoteBookTimeSlotRepository();
  //         final SessionRepository sessionRepository =
  //             SessionRepository(pref: LocalPref());
  //         final SeatSlotRepository seatSlotRepository =
  //             RemoteSeatSlotRepository();
  //         final TicketRepo ticketRepo = TicketRepo();

  //         return MultiRepositoryProvider(
  //           providers: [
  //             RepositoryProvider<UserRepository>(
  //                 create: (context) => userRepository),
  //             RepositoryProvider<HomeRepository>(
  //                 create: (context) => homeRepository),
  //             RepositoryProvider<ShowRepository>(
  //                 create: (context) => showRepository),
  //             RepositoryProvider<BookTimeSlotRepository>(
  //                 create: (context) => bookTimeSlotRepository),
  //             RepositoryProvider<SessionRepository>(
  //                 create: (context) => sessionRepository),
  //             RepositoryProvider<SeatSlotRepository>(
  //                 create: (context) => seatSlotRepository),
  //             RepositoryProvider<TicketRepo>(create: (context) => ticketRepo),
  //           ],
  //           child: MultiBlocProvider(
  //             providers: [
  //               BlocProvider(
  //                 create: (context) =>
  //                     AuthenticationBloc(userRepository: userRepository)
  //                       ..add(AppStarted()),
  //               ),
  //               BlocProvider(
  //                 create: (context) => HomeBloc(homeRepository: homeRepository),
  //               ),
  //             ],
  //             child: MyApp(router: goRoute,),
  //           ),
  //         );
  //       }

  //       return Container();
  //     },
  //   );
  // }
}
