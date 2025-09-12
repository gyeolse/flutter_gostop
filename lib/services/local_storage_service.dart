import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // String methods
  Future<void> setString(String key, String value) async {
    await _init();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _init();
    return _prefs!.getString(key);
  }

  // Int methods
  Future<void> setInt(String key, int value) async {
    await _init();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await _init();
    return _prefs!.getInt(key);
  }

  // Bool methods
  Future<void> setBool(String key, bool value) async {
    await _init();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _init();
    return _prefs!.getBool(key);
  }

  // Double methods
  Future<void> setDouble(String key, double value) async {
    await _init();
    await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _init();
    return _prefs!.getDouble(key);
  }

  // List<String> methods
  Future<void> setStringList(String key, List<String> value) async {
    await _init();
    await _prefs!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await _init();
    return _prefs!.getStringList(key);
  }

  // Remove and clear methods
  Future<void> remove(String key) async {
    await _init();
    await _prefs!.remove(key);
  }

  Future<void> clear() async {
    await _init();
    await _prefs!.clear();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    await _init();
    return _prefs!.containsKey(key);
  }

  // Get all keys
  Future<Set<String>> getAllKeys() async {
    await _init();
    return _prefs!.getKeys();
  }
}