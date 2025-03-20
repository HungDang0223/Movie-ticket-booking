import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupSubmitForm extends SignupEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  String? gender;
  DateTime? dateOfBirth;
  final String address;

  SignupSubmitForm({required this.fullName, required this.email, required this.phoneNumber, required this.password, required this.address, this.gender, this.dateOfBirth});


  @override
  List<Object> get props => [fullName, email, phoneNumber, password];

  @override
  String toString() {
    return 'Submitted{fullName: $fullName, email: $email, phoneNumber: $phoneNumber, password: $password, gender: $gender, dateOfBirth: $dateOfBirth, address: $address}';
  }
}
