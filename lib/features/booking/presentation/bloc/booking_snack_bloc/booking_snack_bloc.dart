import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/booking/domain/repositories/booking_snack_repository.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/bloc.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_snack_bloc/booking_snack_event.dart';
import 'package:movie_tickets/features/booking/presentation/bloc/booking_snack_bloc/booking_snack_state.dart';

class BookingSnackBloc extends Bloc<BookingSnackEvent, BookingSnackState> {
  final BookingSnackRepository _repository;
  BookingSnackBloc({required BookingSnackRepository repository})
      : _repository = repository,
        super(BookingSnackInitial());

}