import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// Available theme modes for the app.
///
/// We keep this separate from Flutter's ThemeMode so it's easy to
/// persist with Hive and extend later if needed.
@HiveType(typeId: 3)
enum AppThemeMode {
  @HiveField(0)
  system,

  @HiveField(1)
  light,

  @HiveField(2)
  dark,
}

/// Application-level settings persisted via Hive.
///
/// Right now it only holds theme preferences, but you can
/// extend this later (e.g. default pay frequency, pay amount).
@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  final AppThemeMode themeMode;

  AppSettings({
    required this.themeMode,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() => 'AppSettings(themeMode: $themeMode)';
}
