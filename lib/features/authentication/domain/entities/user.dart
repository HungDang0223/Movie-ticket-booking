abstract class User {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final DateTime dateOfBirth;
  final String? gender;
  final String? address;
  final String? accountStatus;
  final String? refreshToken;
  final String? refreshTokenExpiry;
  final List<dynamic> bookings;
  final List<dynamic> reviews;
  final List<dynamic> favourites;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.accountStatus,
    required this.refreshToken,
    required this.refreshTokenExpiry,
    required this.bookings,
    required this.reviews,
    required this.favourites,
  });
}
