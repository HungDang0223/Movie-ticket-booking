import '../entities/settings.dart';

abstract class SettingsRepository {
  Future<void> updateProfile(Map<String, dynamic> profileData);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> updateNotificationSettings(Map<String, bool> settings);
  Future<void> changeLanguage(String languageCode, String countryCode);
  Future<void> changeTheme(bool isDarkMode);
  Future<void> signOut();
  Future<Map<String, dynamic>> getProfile();
  Future<Settings> getSettings();
} 