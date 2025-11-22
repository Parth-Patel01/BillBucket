import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

/// Simple settings screen.
///
/// Currently supports:
/// - Theme selection: System / Light / Dark.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currentMode = settingsProvider.themeMode;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Appearance',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: const Text('Use system theme'),
                  value: AppThemeMode.system,
                  groupValue: currentMode,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setThemeMode(value);
                    }
                  },
                ),
                const Divider(height: 0),
                RadioListTile<AppThemeMode>(
                  title: const Text('Light theme'),
                  value: AppThemeMode.light,
                  groupValue: currentMode,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setThemeMode(value);
                    }
                  },
                ),
                const Divider(height: 0),
                RadioListTile<AppThemeMode>(
                  title: const Text('Dark theme'),
                  value: AppThemeMode.dark,
                  groupValue: currentMode,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setThemeMode(value);
                    }
                  },
                ),
              ],
            ),
          ),

          // Placeholder for future settings (e.g. pay frequency, pay amount)
          // You can add more ListTiles / Cards here later.
        ],
      ),
    );
  }
}
