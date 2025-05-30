import 'package:movie_tickets/features/booking/data/models/models.dart';

abstract class BookingSnackRepository {
  Future<Snack> getAllSnacks();
  Future<List<Snack>> getSnacksByCategory(String categoryName);
  Future<Combo> getAllCOmbos();
  Future<void> addSnackToBooking(String bookingId, String snackId);
  Future<void> removeSnackFromBooking(String bookingId, String snackId);
  Future<List<String>> getSnacksForBooking(String bookingId);
}