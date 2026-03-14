import 'package:lifeos/domain/entities/settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> setSetting(String key, dynamic value);
  Future<dynamic> getSetting(String key);
}
