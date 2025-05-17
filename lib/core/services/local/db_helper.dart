import 'dart:developer';

import 'package:movie_tickets/core/services/local/ticket_dao.dart';
import 'package:sqflite/sqflite.dart';

import '../../../features/booking/data/models/models.dart';

class DbHelper {
  static late Database _db;

  static _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE "${TicketDAO.TABLE_NAME}" ( "${TicketDAO.COL_ID}" INTEGER PRIMARY KEY AUTOINCREMENT, "${TicketDAO.COL_SHOW_NAME}" TEXT,"${TicketDAO.COL_SHOW_BANNER}" TEXT, "${TicketDAO.COL_SHOW_TIME_SLOT}" TEXT, "${TicketDAO.COL_BOOK_TIME}" INTEGER, "${TicketDAO.COL_CINE_NAME}" TEXT, "${TicketDAO.COL_SEAT}" TEXT );');

    log('_onCreate. version $version');
  }

  static Future init() async {
    _db = await openDatabase(
      'findseat.db',
      version: 1,
      singleInstance: true,
      onCreate: _onCreate,
    );

    // Sample data for Showing
    final showing1 = ShowingMovie(
      showingId: 1,
      cinemaName: "CGV Aeon Mall",
      screenName: "Screen 1",
      startTime: 'DateTime.now()',
      endTime: 'DateTime.now().add(const Duration(hours: 3))',
      language: "English",
      subtitleLanguage: "Vietnamese",
      showingFormat: "2D",
      showingDate: DateTime.now(),
      screenId: 1,
      seatCount: 100,
    );

    // Sample data for seats
    const seats1 = BookingSeat(
      showingId: "1",
      seats: [
        Seat(
          seatId: 1,
          showingId: 1,
          seatType: "Regular",
          screenName: "Screen 1",
          rowName: "G",
          seatNumber: "4"
        ),
        Seat(
          seatId: 2,
          showingId: 1,
          seatType: "Regular",
          screenName: "Screen 1",
          rowName: "G",
          seatNumber: "5"
        ),
      ]
    );

    // Sample data for snacks
    final snacks1 = BookingSnack(
      bookingId: 1,
      snack: Snack(
        snackId: 1,
        name: "Popcorn Large",
        description: "Fresh popcorn",
        price: 5.99,
        imageUrl: "assets/images/popcorn.jpg"
      ),
      quantity: 2
    );

    // Sample data for combos
    const combos1 = BookingCombo(
      bookingId: 1,
      combo: Combo(
        comboId: 1,
        comboName: "Family Pack",
        imageUrl: "assets/images/combo1.jpg",
        description: "2 Popcorn + 2 Coke",
        price: 15
      ),
      quantity: 1
    );

    // Insert ticket
    await TicketDAO.insert(Ticket(
      bookingId: 1,
      userId: "user123",
      showing: showing1,
      bookTime: DateTime.now(),
      amount: 50,
      seats: seats1,
      snacks: snacks1,
      combos: combos1
    ));

    // Retrieve and log all tickets
    var result = await TicketDAO.getAll();
    log(result.toString());
  }

  static Database get db => _db;
}
