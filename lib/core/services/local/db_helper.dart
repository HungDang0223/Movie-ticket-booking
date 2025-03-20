import 'dart:developer';

import 'package:movie_tickets/core/services/local/ticket_dao.dart';
import 'package:movie_tickets/features/booking/data/models/ticket.dart';
import 'package:sqflite/sqflite.dart';

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

   await TicketDAO.insert(Ticket(
     1,
     'King Kong',
     '10:40',
     "D:/KLTN/movie_tickets/assets/images/movie/61d30e82f43b1cab9f49e576ae457086@2x.png",
     DateTime.now().millisecondsSinceEpoch,
     'BHD Star Cineplex',
     'G4;G9;G12',
   ));

    var result = await TicketDAO.getAll();
    log(result.toString());
  }

  static Database get db => _db;
}
