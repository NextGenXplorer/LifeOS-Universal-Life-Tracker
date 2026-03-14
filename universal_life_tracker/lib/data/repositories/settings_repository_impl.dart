import 'package:lifeos/domain/entities/settings.dart';
import 'package:lifeos/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyHapticEnabled = 'haptic_enabled';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUserId = 'user_id';

  @override
  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppSettings(
      darkMode: prefs.getBool(_keyDarkMode) ?? true,
      notificationsEnabled: prefs.getBool(_keyNotificationsEnabled) ?? true,
      biometricEnabled: prefs.getBool(_keyBiometricEnabled) ?? false,
      hapticEnabled: prefs.getBool(_keyHapticEnabled) ?? true,
      soundEnabled: prefs.getBool(_keySoundEnabled) ?? true,
      onboardingComplete: prefs.getBool(_keyOnboardingComplete) ?? false,
      userId: prefs.getString(_keyUserId),
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyDarkMode, settings.darkMode);
    await prefs.setBool(_keyNotificationsEnabled, settings.notificationsEnabled);
    await prefs.setBool(_keyBiometricEnabled, settings.biometricEnabled);
    await prefs.setBool(_keyHapticEnabled, settings.hapticEnabled);
    await prefs.setBool(_keySoundEnabled, settings.soundEnabled);
    await prefs.setBool(_keyOnboardingComplete, settings.onboardingComplete);
    
    if (settings.userId != null) {
      await prefs.setString(_keyUserId, settings.userId!);
    }
  }

  @override
  Future<void> setSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Future<dynamic> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
}
