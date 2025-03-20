import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:movie_tickets/features/authentication/domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User with EquatableMixin {
  UserModel(
      {required super.userId,
      required super.fullName,
      required super.email,
      required super.phoneNumber,
      required super.dateOfBirth,
      required super.gender,
      required super.address,
      required super.accountStatus,
      required super.refreshToken,
      required super.refreshTokenExpiry,
      required super.bookings,
      required super.reviews,
      required super.favourites});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // if userId = 0, it mean user login with google, not saved yet in db
  factory UserModel.fromGoogleSignInAccount(GoogleSignInAccount account) {
    return UserModel(
      userId: "tempId",
      fullName: account.displayName ?? "",
      email: account.email,
      phoneNumber: "",
      dateOfBirth: DateTime(2003, 1, 1),
      gender: "Nam",
      address: "",
      accountStatus: "Active",
      refreshToken: "",
      refreshTokenExpiry: "",
      bookings: [],
      reviews: [],
      favourites: [],
    );
  }

  @override
  String toString() {
    return 'User{uid: $userId, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, address: $address}}';
  }

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
