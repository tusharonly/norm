import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:norm/src/models/habit_model.dart';
import 'package:norm/src/models/reminder_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'habit_reminders',
        'Habit Reminders',
        description: 'Notifications for habit reminders',
        importance: Importance.max,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      debugPrint('Notification channel created');
    }

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  Future<bool> requestPermissions() async {
    debugPrint('📱 Requesting notification permissions...');

    if (!await Permission.notification.isGranted) {
      debugPrint('Requesting notification permission...');
      final notificationStatus = await Permission.notification.request();
      debugPrint('Notification permission: ${notificationStatus.isGranted}');

      if (!notificationStatus.isGranted) {
        debugPrint('❌ Notification permission denied');
        return false;
      }
    } else {
      debugPrint('✅ Notification permission already granted');
    }

    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('Exact alarm permission status: $exactAlarmStatus');

      if (!exactAlarmStatus.isGranted) {
        debugPrint('Requesting exact alarm permission...');
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('Exact alarm permission after request: $result');

        if (!result.isGranted) {
          debugPrint(
            '⚠️ Exact alarm permission not granted. Scheduled notifications may not work properly.',
          );
          return false;
        }
      } else {
        debugPrint('✅ Exact alarm permission already granted');
      }
    }

    debugPrint('✅ All notification permissions granted');
    return true;
  }

  Future<void> scheduleHabitReminders(HabitModel habit) async {
    if (!_initialized) {
      debugPrint('⚠️ NotificationService not initialized. Initializing now...');
      await initialize();
    }

    await cancelHabitReminders(habit.id);

    debugPrint('Scheduling reminders for habit: ${habit.name}');
    for (final reminder in habit.reminders) {
      await _scheduleReminder(habit, reminder);
    }

    final pending = await getPendingNotifications();
    debugPrint('Total pending notifications: ${pending.length}');
  }

  Future<void> _scheduleReminder(
    HabitModel habit,
    ReminderModel reminder,
  ) async {
    for (final day in reminder.selectedDays) {
      final notificationId = _generateNotificationId(
        habit.id,
        reminder.id,
        day,
      );

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminder.hour,
        reminder.minute,
      );

      while (scheduledDate.weekday != day) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      try {
        debugPrint(
          'Scheduling notification #$notificationId for ${habit.name} '
          'on day $day at ${reminder.hour}:${reminder.minute} '
          '(${scheduledDate.toString()})',
        );

        await _notifications.zonedSchedule(
          notificationId,
          'Norm Reminder: ${habit.name}',
          'Time to log your habit!',
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_reminders',
              'Habit Reminders',
              channelDescription: 'Notifications for habit reminders',
              importance: Importance.high,
              priority: Priority.high,
              color: habit.color,
              playSound: true,
              enableVibration: true,
              largeIcon: const DrawableResourceAndroidBitmap(
                '@mipmap/ic_launcher',
              ),
            ),
          ),
          payload: habit.id,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        debugPrint('✅ Notification #$notificationId scheduled successfully');
      } catch (e, stackTrace) {
        debugPrint('❌ Error scheduling notification #$notificationId: $e');
        debugPrint(stackTrace.toString());
      }
    }
  }

  Future<void> cancelHabitReminders(String habitId) async {
    final pendingNotifications = await _notifications
        .pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      if (notification.payload == habitId) {
        await _notifications.cancel(notification.id);
      }
    }
  }

  int _generateNotificationId(String habitId, String reminderId, int day) {
    final habitHash = habitId.hashCode.abs() % 10000;
    final reminderHash = reminderId.hashCode.abs() % 100;
    return habitHash * 1000 + reminderHash * 10 + day;
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
