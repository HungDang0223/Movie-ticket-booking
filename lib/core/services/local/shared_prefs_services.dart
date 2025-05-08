import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  late SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save data based on type
  Future<void> saveValue(String key, dynamic value) async {
    if (_prefs == null) await init();
    
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is DateTime) {
      // Convert DateTime to ISO string format
      await _prefs!.setString(key, value.toIso8601String());
    } else if (value is Map<String, dynamic>) {
      // Convert any DateTime values in the map to ISO strings
      final encodableMap = _makeEncodable(value);
      String jsonString = jsonEncode(encodableMap);
      await _prefs!.setString(key, jsonString);
    } else {
      throw Exception("Unsupported type");
    }
  }

  /// Get data based on type
  dynamic getValue(String key, {Type? type}) {
    if (_prefs == null) return null;
    
    if (type == String) {
      return _prefs!.getString(key);
    } else if (type == int) {
      return _prefs!.getInt(key);
    } else if (type == bool) {
      return _prefs!.getBool(key);
    } else if (type == double) {
      return _prefs!.getDouble(key);
    } else if (type == DateTime) {
      final dateStr = _prefs!.getString(key);
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } else if (type == Map<String, dynamic>) {
      String? jsonString = _prefs!.getString(key);
      return jsonString != null ? jsonDecode(jsonString) : null;
    } else {
      throw Exception("Unsupported type");
    }
  }

  /// Remove value by key
  Future<void> removeValue(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  // Helper method to make map encodable
  Map<String, dynamic> _makeEncodable(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value);
    });
  }
}