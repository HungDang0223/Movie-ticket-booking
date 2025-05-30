import 'package:movie_tickets/features/booking/data/models/combo.dart';
import 'package:movie_tickets/features/booking/data/models/snack.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_snack_repository.dart';

class BookingSnackRepositoryImpl extends BookingSnackRepository {
  @override
  Future<void> addSnackToBooking(String bookingId, String snackId) {
    // TODO: implement addSnackToBooking
    throw UnimplementedError();
  }

  @override
  Future<Combo> getAllCOmbos() {
    // TODO: implement getAllCOmbos
    throw UnimplementedError();
  }

  @override
  Future<Snack> getAllSnacks() {
    // TODO: implement getAllSnacks
    throw UnimplementedError();
  }

  @override
  Future<List<Snack>> getSnacksByCategory(String categoryName) {
    // TODO: implement getSnacksByCategory
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getSnacksForBooking(String bookingId) {
    // TODO: implement getSnacksForBooking
    throw UnimplementedError();
  }

  @override
  Future<void> removeSnackFromBooking(String bookingId, String snackId) {
    // TODO: implement removeSnackFromBooking
    throw UnimplementedError();
  }

}