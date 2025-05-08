import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;
  final String? photoUrl;
  final int points;
  final int level;
  final String? phoneNumber;

  const UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.points,
    required this.level,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, photoUrl, points, level, phoneNumber];
}

class Settings extends Equatable {
  final bool isDarkMode;
  final String currentLanguage;
  final Map<String, bool> notificationSettings;
  final UserProfile userProfile;

  const Settings({
    required this.isDarkMode,
    required this.currentLanguage,
    required this.notificationSettings,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [isDarkMode, currentLanguage, notificationSettings, userProfile];
} 