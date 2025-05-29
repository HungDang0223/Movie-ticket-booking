import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/authentication/domain/entities/user.dart';

class UserModel extends User with EquatableMixin {
  UserModel(
      {required super.userId,
      required super.fullName,
      required super.email,
      required super.phoneNumber,
      required super.dateOfBirth,
      super.gender,
      required super.address,
      super.accountStatus,
      super.photoPath,
      super.refreshToken,
      super.refreshTokenExpiry,
      super.role,
      super.isDeleted,
      super.createdAt,
      super.updatedAt,
      required super.rankId,
      super.totalPoints,
      super.totalPaid});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? "",
      fullName: json['fullName'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'] ?? "Nam",
      address: json['address'] ?? "",
      accountStatus: json['accountStatus'] ?? "active",
      role: json['role'] ?? "user",
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      rankId: json['rankId'] ?? 1,
      totalPoints: json['totalPoints'] ?? 0,
      totalPaid: json['totalPaid'] ?? 0,
      photoPath: json['photoPath'] ?? "",
      refreshToken: json['refreshToken'] ?? "",
      refreshTokenExpiry: DateTime.parse(json['refreshTokenExpiry']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'accountStatus': accountStatus,
      'photoPath': photoPath,
      'refreshToken': refreshToken,
      'refreshTokenExpiry': refreshTokenExpiry?.toIso8601String(),
      'role': role,
      'isDeleted': isDeleted,
      'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt!.toIso8601String(),
      'rankId': rankId,
      'totalPoints': totalPoints,
      'totalPaid': totalPaid,
      
    };
  }

  factory UserModel.empty() {
    return UserModel(
      userId: "",
      fullName: "",
      email: "",
      phoneNumber: "",
      dateOfBirth: DateTime.now(),
      gender: "Nam",
      address: "",
      accountStatus: "active",
      role: "user",
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rankId: 1,
      totalPoints: 0,
      totalPaid: 0,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        phoneNumber,
        dateOfBirth,
        gender,
        address,
        accountStatus,
        photoPath,
        refreshToken,
        refreshTokenExpiry
      ];

  @override
  String toString() {
    return 'User{uid: $userId, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, address: $address}}';
  }
}
