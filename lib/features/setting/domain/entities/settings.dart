import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? name;
  final String? email;
  final String? photoUrl;
  final int? points;
  final int? level;
  final String? phoneNumber;

  const UserProfile({
    this.name,
    this.email,
    this.photoUrl,
    this.points,
    this.level,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, photoUrl, points, level, phoneNumber];
}

class Settings extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final String countryCode;
  final Map<String, bool> notificationSettings;
  final UserProfile userProfile;

  const Settings({
    required this.isDarkMode,
    required this.languageCode,
    required this.countryCode,
    required this.notificationSettings,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [isDarkMode, languageCode, countryCode, notificationSettings];
} 