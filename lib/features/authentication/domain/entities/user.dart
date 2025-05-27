abstract class User {
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String? accountStatus;
  final String role;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
      this.gender = "Nam",
      required this.address,
      this.accountStatus = "active",
      this.role = 'user',
      this.isDeleted = false,
      this.createdAt,
      this.updatedAt,
      required this.rankId,
      this.totalPoints = 0,
      this.totalPaid = 0,
      this.photoPath,
      this.refreshToken,
      this.refreshTokenExpiry});
  
}
