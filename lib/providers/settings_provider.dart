import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/app_settings.dart';

/// Provider responsible for loading and updating app-wide settings.
///
/// Currently supports:
/// - Theme mode (system / light / dark).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required Box<AppSettings> settingsBox,
  }) : _settingsBox = settingsBox {
    _loadOrCreateDefaultSettings();
  }

  static const String _settingsKey = 'app_settings';

  final Box<AppSettings> _settingsBox;

  late AppSettings _settings;

  AppSettings get settings => _settings;

  AppThemeMode get themeMode => _settings.themeMode;

  /// Load existing settings from Hive or create sensible defaults.
  void _loadOrCreateDefaultSettings() {
    final existing = _settingsBox.get(_settingsKey);

    if (existing != null) {
      _settings = existing;
    } else {
      _settings = AppSettings(
        themeMode: AppThemeMode.system,
      );
      _settingsBox.put(_settingsKey, _settings);
    }
    notifyListeners();
  }

  /// Update the theme mode and persist to Hive.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == _settings.themeMode) return;

    _settings = _settings.copyWith(themeMode: mode);
    await _settingsBox.put(_settingsKey, _settings);
    notifyListeners();
  }
}
