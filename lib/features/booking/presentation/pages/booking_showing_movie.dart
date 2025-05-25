import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/core/utils/authentication_helper.dart';
import 'package:movie_tickets/core/utils/snackbar_utilies.dart';
import 'package:movie_tickets/features/booking/presentation/pages/booking_seat.dart';
import 'package:movie_tickets/features/movies/data/models/movie_model.dart';
import 'package:movie_tickets/injection.dart';

import '../bloc/bloc.dart';

class ShowingMovieBookingScreen extends StatefulWidget {
  final MovieModel movie;
  const ShowingMovieBookingScreen({super.key, required this.movie});

  @override
  State<ShowingMovieBookingScreen> createState() => _ShowingMovieBookingScreenState();
}

class _ShowingMovieBookingScreenState extends State<ShowingMovieBookingScreen> {
  DateTime selectedDate = DateTime.now();

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {},
        ),
        title: Text(
          widget.movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          Transform.rotate(
              angle: -pi / 4,
              origin: const Offset(1, -10),
              child: const Icon(
                Icons.send,
                color: AppColor.RED,
              )),
          const SizedBox(width: 5,),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),      body: Column(
        children: [
          DateSelector(
            onDateSelected: onDateSelected,
          ),
          Expanded(child: TheaterList(movie: widget.movie, selectedDate: selectedDate,)),
          BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Gợi ý Cho Bạn"),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tất Cả Các Rạp"),
            ],
            onTap: (value) {
              
            },
          )
        ],
      ),
    );
  }
}

class DateSelector extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const DateSelector({
    super.key, 
    required this.onDateSelected,
  });

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate = DateTime.now();
  DateTime initDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - DateTime.monday));

  List<String> days = ["Th2", "Th3", "Th4", "Th5", "Th6", "Th7", "CN"];

  @override
  Widget build(BuildContext context) {
    PageController page = PageController();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black,
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(days[index],
                        style: const TextStyle(color: Colors.white)));
              }),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: PageView.builder(
              controller: page,
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                DateTime startDate = initDate.add(Duration(days: 7 * (index)));
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    DateTime date = startDate.add(Duration(days: index));
                    return GestureDetector(                      
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                        widget.onDateSelected(date);
                      },
                      child: Container(
                        // width: 45,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedDate == date ? Colors.red : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(color: selectedDate == date ? Colors.white : Colors.grey),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TheaterList extends StatefulWidget {
  final MovieModel movie;
  final DateTime selectedDate;
  const TheaterList({super.key, required this.movie, required this.selectedDate});

  @override
  State<TheaterList> createState() => _TheaterListState();
}

class _TheaterListState extends State<TheaterList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowingMovieBloc, ShowingMovieState>(
      bloc: sl<ShowingMovieBloc>()..add(GetShowingMovieEvent(
        movieId: widget.movie.movieId,
        date: widget.selectedDate,
      )),
      builder: (context, state) {
        if (state is ShowingMovieLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ShowingMovieLoaded) {
          final cinemaShowings = state.showingMovies;
          return ListView.builder(
            itemCount: cinemaShowings.length,
            itemBuilder: (context, index) {
              final showings = cinemaShowings[index].showingMovies;
              return ExpansionTile(
                initiallyExpanded: index == 0 ? true : false,
                title: Text(
                  cinemaShowings[index].cinemaName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                iconColor: Colors.red,
                childrenPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: showings.length,
                        itemBuilder: (context, index) {
                          final showing = showings[index];
                          return Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
                                final isAuthenticated = await AuthenticationHelper.requireAuthentication(context);
                                if (!isAuthenticated) {
                                  SnackbarUtils.showAuthRequiredSnackbar(
                                    context,
                                    'Bạn cần đăng nhập để đặt chỗ ngồi',
                                  );
                                  return;
                                }

                                if (!context.mounted) return;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => BookingSeatPage(
                                  movie: widget.movie,
                                  showingMovie: showing,
                                  websocketUrl: 'ws://192.168.1.2:5000/ws/seat-reservation',
                                  userId: '43810148fb5b11efa5ff4c22c67a10e0',
                                )));
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                side: const BorderSide(color: Colors.red), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                showing.startTime.HH_mm(), 
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                                )
                              ),
                            ),
                          );
                        },
                      ),
                    )
                ],
              );
            },
          );
        } else if (state is ShowingMovieError) {
          return Center(child: Text(state.message));
        }
        return const Center(
          child: Text("No showings available"),
        );
      },
    );
  }
}
