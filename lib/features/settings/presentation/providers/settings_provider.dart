import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/prefs_service.dart';

class SettingsState {
  final bool darkMode;
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String language;
  final bool autoBackup;
  final int autoBackupIntervalDays;

  SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.language = 'en',
    this.autoBackup = false,
    this.autoBackupIntervalDays = 7,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? language,
    bool? autoBackup,
    int? autoBackupIntervalDays,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      language: language ?? this.language,
      autoBackup: autoBackup ?? this.autoBackup,
      autoBackupIntervalDays: autoBackupIntervalDays ?? this.autoBackupIntervalDays,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final PrefsService _prefs = PrefsService();

  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = SettingsState(
      darkMode: _prefs.getBool('darkMode', defaultValue: false),
      notificationsEnabled: _prefs.getBool('notificationsEnabled', defaultValue: true),
      reminderHour: int.tryParse(_prefs.getString('reminderHour')) ?? 9,
      reminderMinute: int.tryParse(_prefs.getString('reminderMinute')) ?? 0,
      language: _prefs.getString('language') ?? 'en',
      autoBackup: _prefs.getBool('autoBackup', defaultValue: false),
      autoBackupIntervalDays: int.tryParse(_prefs.getString('autoBackupIntervalDays')) ?? 7,
    );
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await _prefs.setBool('darkMode', value);
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _prefs.setBool('notificationsEnabled', value);
  }

  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _prefs.setString('reminderHour', hour.toString());
    await _prefs.setString('reminderMinute', minute.toString());
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _prefs.setString('language', language);
  }

  Future<void> setAutoBackup(bool value) async {
    state = state.copyWith(autoBackup: value);
    await _prefs.setBool('autoBackup', value);
  }

  Future<void> setAutoBackupInterval(int days) async {
    state = state.copyWith(autoBackupIntervalDays: days);
    await _prefs.setString('autoBackupIntervalDays', days.toString());
  }

  Future<void> resetToDefaults() async {
    await _prefs.setBool('darkMode', false);
    await _prefs.setBool('notificationsEnabled', true);
    await _prefs.setString('reminderHour', '9');
    await _prefs.setString('reminderMinute', '0');
    await _prefs.setString('language', 'en');
    await _prefs.setBool('autoBackup', false);
    await _prefs.setString('autoBackupIntervalDays', '7');
    state = SettingsState();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
