import '../../domain/entities/settings.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.name,
    super.email,
    super.photoUrl,
    super.points,
    super.level,
    super.phoneNumber,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      points: json['points'] as int,
      level: json['level'] as int,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'level': level,
      'phoneNumber': phoneNumber,
    };
  }
}

class SettingsModel extends Settings {
  const SettingsModel({
    required super.isDarkMode,
    required super.languageCode,
    required super.countryCode,
    required super.notificationSettings,
    required super.userProfile,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] as bool,
      languageCode: json['languageCode'] ?? 'vi',
      countryCode: json['countryCode'] ?? 'VN',
      notificationSettings: Map<String, bool>.from(json['notificationSettings'] as Map),
      userProfile: UserProfileModel.fromJson(json['userProfile'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'languageCode': languageCode,
      'countryCode': countryCode,
      'notificationSettings': notificationSettings,
      'userProfile': (userProfile as UserProfileModel).toJson(),
    };
  }
} 