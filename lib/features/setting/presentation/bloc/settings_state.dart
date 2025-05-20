import 'package:equatable/equatable.dart';
import 'package:movie_tickets/features/setting/domain/entities/settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isDarkMode;
  final String languageCode;
  final String countryCode;
  final Map<String, bool> notificationSettings;
  final UserProfile userProfile;

  const SettingsLoaded({
    required this.isDarkMode,
    required this.languageCode,
    required this.countryCode,
    required this.notificationSettings,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [isDarkMode, languageCode, notificationSettings, userProfile];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}