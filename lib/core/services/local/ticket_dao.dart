import 'package:movie_tickets/core/services/local/db_helper.dart';
import 'package:movie_tickets/features/booking/data/models/ticket.dart';

class TicketDAO {
  static const TABLE_NAME = "my_ticket";

  static const COL_ID = "id";
  static const COL_SHOW_NAME = "show_name";
  static const COL_SHOW_BANNER = "show_banner";
  static const COL_SHOW_TIME_SLOT = "show_time_slot";
  static const COL_BOOK_TIME = "book_time";
  static const COL_CINE_NAME = "cine_name";
  static const COL_SEAT = "seat";

  static Future<int> insert(Ticket value) async {
    return await DbHelper.db.insert(TABLE_NAME, value.toJson());
  }

  static Future<List<Ticket>> getAll() async {
    var listMap =
        await DbHelper.db.query(TABLE_NAME, orderBy: '$COL_BOOK_TIME DESC');
    return listMap.map((jsonRaw) => Ticket.fromJson(jsonRaw)).toList();
  }
}
