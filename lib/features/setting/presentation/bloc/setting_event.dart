import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateProfile extends SettingsEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfile(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class ChangePassword extends SettingsEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword(this.currentPassword, this.newPassword);

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class UpdateNotificationSettings extends SettingsEvent {
  final Map<String, bool> settings;

  const UpdateNotificationSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ChangeLanguage extends SettingsEvent {
  final String languageCode;
  final String countryCode;

  const ChangeLanguage(this.languageCode, this.countryCode);

  @override
  List<Object?> get props => [languageCode];
}

class ChangeTheme extends SettingsEvent {
  final bool isDarkMode;

  const ChangeTheme(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class SignOut extends SettingsEvent {}