abstract class User {
  final String userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String? address;
  final String? accountStatus;
  final String role;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rankId;
  final int totalPoints;
  final int totalPaid;
  final String? photoPath;
  final String? refreshToken;
  final DateTime? refreshTokenExpiry;

  User(
      {required this.userId,
      required this.fullName,
      required this.email,
      required this.phoneNumber,
      required this.dateOfBirth,
      required this.gender,
      required this.address,
      required this.accountStatus,
      required this.role,
      required this.isDeleted,
      required this.createdAt,
      required this.updatedAt,
      required this.rankId,
      required this.totalPoints,
      required this.totalPaid,
      required this.photoPath,
      required this.refreshToken,
      required this.refreshTokenExpiry});
  
}
