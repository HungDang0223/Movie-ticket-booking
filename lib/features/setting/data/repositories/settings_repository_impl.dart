import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;
  final AuthRepository _authRepository;

  SettingsRepositoryImpl(this._localDataSource, this._authRepository);

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = _authRepository.getCurrentUser();

      final settings = await getSettings();
      return {
        'name': null,
        'email': null,
        'photoUrl': null,
        'points': null,
        'level': null,
        'phoneNumber': null,
      };
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // Update local settings
      final currentSettings = await getSettings();
      final updatedProfile = UserProfileModel(
        name: profileData['name'] as String? ?? currentSettings.userProfile.name,
        email: currentSettings.userProfile.email,
        photoUrl: profileData['photoUrl'] as String?,
        points: currentSettings.userProfile.points,
        level: currentSettings.userProfile.level,
        phoneNumber: profileData['phoneNumber'] as String?,
      );

      final updatedSettings = SettingsModel(
        isDarkMode: currentSettings.isDarkMode,
        currentLanguage: currentSettings.currentLanguage,
        notificationSettings: currentSettings.notificationSettings,
        userProfile: updatedProfile,
      );

      await _localDataSource.saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = SettingsModel(
        isDarkMode: currentSettings.isDarkMode,
        currentLanguage: currentSettings.currentLanguage,
        notificationSettings: settings,
        userProfile: currentSettings.userProfile,
      );
      await _localDataSource.saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update notification settings: ${e.toString()}');
    }
  }

  @override
  Future<void> changeLanguage(String languageCode) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = SettingsModel(
        isDarkMode: currentSettings.isDarkMode,
        currentLanguage: languageCode,
        notificationSettings: currentSettings.notificationSettings,
        userProfile: currentSettings.userProfile,
      );
      await _localDataSource.saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to change language: ${e.toString()}');
    }
  }

  @override
  Future<void> changeTheme(bool isDarkMode) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = SettingsModel(
        isDarkMode: isDarkMode,
        currentLanguage: currentSettings.currentLanguage,
        notificationSettings: currentSettings.notificationSettings,
        userProfile: currentSettings.userProfile,
      );
      await _localDataSource.saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to change theme: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authRepository.logOut();
      await _localDataSource.clearSettings();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<Settings> getSettings() async {
    try {
      final settings = await _localDataSource.getSettings();
      if (settings != null) {
        return settings;
      }

      // final user = await _authRepository.getCurrentUser();

      // Create default settings for new user
      const defaultSettings = SettingsModel(
        isDarkMode: false,
        currentLanguage: 'en',
        notificationSettings: const {
          'movie_reminders': true,
          'booking_confirmations': true,
          'special_offers': true,
          'news_updates': true,
        },
        userProfile: const UserProfileModel(
          name: '',
          email:  '',
          photoUrl:  '',
          points: 0,
          level: 1,
          phoneNumber:  '',
        ),
      );

      await _localDataSource.saveSettings(defaultSettings);
      return defaultSettings;
    } catch (e) {
      throw Exception('Failed to get settings: ${e.toString()}');
    }
  }
} 