// lib/services/notification_service.dart
// Handles scheduling and showing local notifications
// Uses flutter_local_notifications package

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // Singleton pattern - only one instance exists
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  /// Must be called before scheduling any notifications
  Future<void> init() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Called when user taps a notification
  void _onNotificationTap(NotificationResponse response) {
    // The app handles this via navigation in main.dart
    // For now, just opening the app is sufficient
  }

  /// Schedule a daily repeating notification at a specific time
  /// [id] - unique notification ID (use task index 0-10)
  /// [title] - notification title
  /// [body] - notification body text
  /// [hour] - hour in 24h format (e.g., 6 for 6am)
  /// [minute] - minute (e.g., 30)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'dude_routine_channel', // channel ID
      'Dude Routine Reminders', // channel name
      channelDescription: 'Daily routine task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Get the next occurrence of this time
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Calculate the next occurrence of a specific time today or tomorrow
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel ALL notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Schedule all 11 routine notifications
  Future<void> scheduleAllRoutineNotifications() async {
    // Cancel existing ones first to avoid duplicates
    await cancelAllNotifications();

    // List of all tasks with their notification details
    final tasks = [
      {'id': 0, 'name': 'Wake Up', 'hour': 6, 'minute': 30},
      {'id': 1, 'name': 'ABC Juice', 'hour': 8, 'minute': 15},
      {'id': 2, 'name': 'Breakfast', 'hour': 9, 'minute': 0},
      {'id': 3, 'name': 'Lunch', 'hour': 13, 'minute': 30},
      {'id': 4, 'name': 'Banana', 'hour': 16, 'minute': 20},
      {'id': 5, 'name': 'Coffee', 'hour': 17, 'minute': 15},
      {'id': 6, 'name': 'Gym', 'hour': 19, 'minute': 15},
      {'id': 7, 'name': 'Dinner', 'hour': 21, 'minute': 0},
      {'id': 8, 'name': 'GF Time', 'hour': 21, 'minute': 15},
      {'id': 9, 'name': 'Work', 'hour': 22, 'minute': 0},
      {'id': 10, 'name': 'Sleep', 'hour': 23, 'minute': 30},
    ];

    for (final task in tasks) {
      await scheduleDailyNotification(
        id: task['id'] as int,
        title: '⏰ ${task['name']}',
        body: 'Time for ${task['name']}! Did you complete it?',
        hour: task['hour'] as int,
        minute: task['minute'] as int,
      );
    }
  }
}
