// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['userId'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      accountStatus: json['accountStatus'] as String?,
      refreshToken: json['refreshToken'] as String?,
      refreshTokenExpiry: json['refreshTokenExpiry'] as String?,
      bookings: json['bookings'] as List<dynamic>,
      reviews: json['reviews'] as List<dynamic>,
      favourites: json['favourites'] as List<dynamic>,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'address': instance.address,
      'accountStatus': instance.accountStatus,
      'refreshToken': instance.refreshToken,
      'refreshTokenExpiry': instance.refreshTokenExpiry,
      'bookings': instance.bookings,
      'reviews': instance.reviews,
      'favourites': instance.favourites,
    };
