import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _info;

  static const String _ownerName = 'Parth Patel';
  static const String _ownerEmail = 'patel.parth2201@gmail.com';
  static const String _githubUrl =
      'https://github.com/Parth-Patel01/BillBucket';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _info = info;
    });
  }

  Future<void> _launchExternal(Uri uri) async {
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $uri')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening link: $e')),
      );
    }
  }

  Future<void> _copyEmailToClipboard() async {
    await Clipboard.setData(const ClipboardData(text: _ownerEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email address copied')),
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _ownerEmail,
      queryParameters: {
        'subject': 'Bill Bucket feedback',
      },
    );
    await _launchExternal(uri);
  }

  Future<void> _openGithub() async {
    await _launchExternal(Uri.parse(_githubUrl));
  }

  Future<void> _rateApp() async {
    final packageName = _info?.packageName ?? 'dev.parth.billbucket';
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
    await _launchExternal(uri);
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currentMode = settingsProvider.themeMode;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ---------- APPEARANCE ----------
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

          // ---------- APP INFO ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'App Info',
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
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App version'),
                  subtitle: Text(
                    _info == null
                        ? 'Loading…'
                        : '${_info!.version} (Build ${_info!.buildNumber})',
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.apps_outlined),
                  title: const Text('Package name'),
                  subtitle: Text(_info?.packageName ?? 'Loading…'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.star_rate_outlined),
                  title: const Text('Rate this app'),
                  subtitle: const Text('Open store page'),
                  onTap: _rateApp,
                ),
              ],
            ),
          ),

          // ---------- DEVELOPER INFO ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Developer',
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
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Owner & developer'),
                  subtitle: Text(_ownerName),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contact email'),
                  subtitle: Text(_ownerEmail),
                  onTap: _copyEmailToClipboard,
                  trailing: IconButton(
                    icon: const Icon(Icons.send_outlined),
                    color: colorScheme.primary,
                    tooltip: 'Send email',
                    onPressed: _sendEmail,
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text('Open project profile'),
                  onTap: _openGithub,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---------- FOOTER ----------
          Center(
            child: Text(
              'Made with Flutter ❤️',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
