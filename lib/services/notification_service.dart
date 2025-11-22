import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Centralized service for local notifications.
///
/// Responsibilities:
/// - Initialize flutter_local_notifications.
/// - Schedule bill reminders.
/// - Cancel bill reminders by bill id.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezones (required for scheduled notifications).
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    _initialized = true;
  }

  /// Computes a stable notification ID from a bill id string.
  int _notificationIdForBillId(String billId) {
    // hashCode can be negative; normalize to a positive, bounded int.
    return billId.hashCode.abs() % 1000000;
  }

  /// Schedule a reminder for the given bill at [dueDate] 9:00 AM local time.
  ///
  /// If the date is in the past, this does nothing.
  Future<void> scheduleBillReminder({
    required String billId,
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    if (!_initialized) return;

    // Use date-only from dueDate, schedule for 9 AM local time.
    final now = DateTime.now();
    final scheduledDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9, // 9:00 AM
    );

    if (scheduledDate.isBefore(now)) {
      // Don't schedule reminders in the past.
      return;
    }

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final id = _notificationIdForBillId(billId);

    const androidDetails = AndroidNotificationDetails(
      'bill_reminders_channel',
      'Bill reminders',
      channelDescription: 'Reminders for upcoming bill due dates',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      'Upcoming bill due',
      '$billName is due today (\$${amount.toStringAsFixed(2)}).',
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Cancel the reminder for a bill (e.g. when bill is deleted).
  Future<void> cancelBillReminder(String billId) async {
    if (!_initialized) return;
    final id = _notificationIdForBillId(billId);
    await _plugin.cancel(id);
  }
}
