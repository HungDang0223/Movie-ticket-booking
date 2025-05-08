import '../../../../core/services/local/shared_prefs_services.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveSettings(SettingsModel settings);
  Future<SettingsModel?> getSettings();
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPrefService _prefsService;

  SettingsLocalDataSourceImpl(this._prefsService);

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    await _prefsService.saveValue('settings', settings.toJson());
  }

  @override
  Future<SettingsModel?> getSettings() async {
    final settingsJson = _prefsService.getValue('settings', type: Map<String, dynamic>);
    if (settingsJson == null) return null;
    return SettingsModel.fromJson(settingsJson);
  }

  @override
  Future<void> clearSettings() async {
    await _prefsService.removeValue('settings');
  }
} 