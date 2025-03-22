import 'dart:math';

import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/features/booking/presentation/pages/seat_booking.dart';

class ShowingMovieBookingScreen extends StatelessWidget {
  const ShowingMovieBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {},
        ),
        title: const Text(
          "ANH KHÔNG ĐAU",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          Transform.rotate(
              angle: -pi / 4,
              origin: Offset(1, -10),
              child: const Icon(
                Icons.send,
                color: AppColor.RED,
              )),
          SizedBox(width: 5,),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const DateSelector(),
          Expanded(child: const TheaterList()),
          BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Gợi ý Cho Bạn"),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tất Cả Các Rạp"),
            ],
          )
        ],
      ),
    );
  }
}

class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime selectedDate = DateTime.now();
  DateTime initDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - DateTime.monday));
  // DateTime? startDate;

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
                  margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(days[index],
                        style: const TextStyle(color: Colors.white)));
              }),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
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
          Text(selectedDate.toFormattedString())
        ],
      ),
    );
  }
}

class TheaterList extends StatelessWidget {
  const TheaterList({super.key});

  @override
  Widget build(BuildContext context) {
    final theaters = [
      "CGV Hà Nội Centerpoint",
      "CGV Indochina Plaza Hà Nội",
      "CGV Mac Plaza (Machinco)",
      "CGV Sun Grand Thụy Khuê",
      "CGV Tràng Tiền Plaza",
    ];

    return ListView.builder(
      itemCount: theaters.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
          initiallyExpanded: index == 0 ? true : false,
          title: Text(
            theaters[index],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          iconColor: Colors.red,
          childrenPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SeatBookingScreen(movieTitle: "title", theaterName: 'CGV hhh', showTime: '12/12/2000', showDate: '12/12/2000')));
                    },
                    style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: const Text("23:20", style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
