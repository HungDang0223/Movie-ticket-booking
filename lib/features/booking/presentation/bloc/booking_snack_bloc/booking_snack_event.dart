import 'package:equatable/equatable.dart';

class BookingSnackEvent extends Equatable {
  const BookingSnackEvent();

  @override
  List<Object?> get props => [];
}

class GetAllSnacksEvent extends BookingSnackEvent {}

class GetAllComboEvent extends BookingSnackEvent {}

class GetSnacksByCategory extends BookingSnackEvent {
  final String categoryName;
  GetSnacksByCategory(this.categoryName);
  @override
  // TODO: implement props
  List<Object?> get props => [categoryName];
}