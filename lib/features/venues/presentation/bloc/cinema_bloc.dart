import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/venues/domain/repositories/cinema_repository.dart';
import 'package:movie_tickets/features/venues/presentation/bloc/cinema_event.dart';
import 'package:movie_tickets/features/venues/presentation/bloc/cinema_state.dart';
import 'package:movie_tickets/features/venues/presentation/pages/cinema_page.dart' as cinema_page;

class CinemaBloc extends Bloc<CinemaEvent, CinemaState> {
  final CinemaRepository _cinemaRepository;
  CinemaBloc(this._cinemaRepository) : super(CinemaInitial()) {
    on<GetCinemas>(_onGetCinemas);
    on<GetCinemasByCityId>(_onGetCinemasByCityId);
    on<GetCinemasByCityName>(_onGetCinemasByCityName);
  }

  Future<void> _onGetCinemas(GetCinemas event, Emitter<CinemaState> emit) async {
    emit(CinemaLoading());
    final result = await _cinemaRepository.getCinemas();
    if (result.isSuccess) {
      if (result.data != null) {
        emit(CinemaLoadedSuccess(result.data!));
      } else {
        emit(CinemaLoadedFailure('No cinemas found.'));
      }
    } else {
      emit(CinemaLoadedFailure(result.failure!.message));
    }
  }

  Future<void> _onGetCinemasByCityId(GetCinemasByCityId event, Emitter<CinemaState> emit) async {
    emit(CinemaLoading());
    final result = await _cinemaRepository.getCinemasByCityId(event.cityId);
    if (result.isSuccess) {
      if (result.data != null && result.data!.isNotEmpty) {
        emit(CinemaLoadedSuccess(result.data!));
      } else {
        emit(CinemaLoadedFailure('No cinemas found.'));
      }
    } else {
      emit(CinemaLoadedFailure(result.failure!.message));
    }
  }

  Future<void> _onGetCinemasByCityName(GetCinemasByCityName event, Emitter<CinemaState> emit) async {
    emit(CinemaLoading());
    final result = await _cinemaRepository.getCinemasByCityName(event.cityName);
    if (result.isSuccess) {
      if (result.data != null && result.data!.isNotEmpty) {
        emit(CinemaLoadedSuccess(result.data!));
      } else {
        emit(CinemaLoadedFailure('No cinemas found.'));
      }
    } else {
      emit(CinemaLoadedFailure(result.failure!.message));
    }
  }
}