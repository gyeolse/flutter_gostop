import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/local_storage_service.dart';
import '../../core/constants.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final localStorage = ref.read(localStorageServiceProvider);
  return SettingsNotifier(localStorage);
});

class SettingsState {
  final bool isDarkMode;
  final bool isNotificationEnabled;
  final bool isSoundEnabled;
  final bool isLoading;

  const SettingsState({
    this.isDarkMode = false,
    this.isNotificationEnabled = true,
    this.isSoundEnabled = true,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isNotificationEnabled,
    bool? isSoundEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const String _notificationKey = 'notification_enabled';
  static const String _soundKey = 'sound_enabled';
  
  final LocalStorageService _localStorage;

  SettingsNotifier(this._localStorage) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final isDarkMode = await _localStorage.getBool(AppConstants.themeKey) ?? false;
      final isNotificationEnabled = await _localStorage.getBool(_notificationKey) ?? true;
      final isSoundEnabled = await _localStorage.getBool(_soundKey) ?? true;

      state = state.copyWith(
        isDarkMode: isDarkMode,
        isNotificationEnabled: isNotificationEnabled,
        isSoundEnabled: isSoundEnabled,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
    }
  }

  Future<void> toggleTheme() async {
    try {
      final newThemeMode = !state.isDarkMode;
      await _localStorage.setBool(AppConstants.themeKey, newThemeMode);
      
      state = state.copyWith(isDarkMode: newThemeMode);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling theme: $e');
      }
    }
  }

  Future<void> toggleNotification() async {
    try {
      final newNotificationEnabled = !state.isNotificationEnabled;
      await _localStorage.setBool(_notificationKey, newNotificationEnabled);
      
      state = state.copyWith(isNotificationEnabled: newNotificationEnabled);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling notification: $e');
      }
    }
  }

  Future<void> toggleSound() async {
    try {
      final newSoundEnabled = !state.isSoundEnabled;
      await _localStorage.setBool(_soundKey, newSoundEnabled);
      
      state = state.copyWith(isSoundEnabled: newSoundEnabled);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling sound: $e');
      }
    }
  }

  Future<void> clearCache() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 1));
      
      // Here you would implement actual cache clearing logic
      // For example, clearing image cache, temporary files, etc.
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
      state = state.copyWith(isLoading: false);
    }
  }
}