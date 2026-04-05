import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task/models/sound_preference.dart';
import 'package:task/models/task.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskNotification(
    Task task,
    SoundPreference soundPreference,
  ) async {
    if (task.id == null) {
      return;
    }
    final scheduled = tz.TZDateTime.from(task.dueDate, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }
    final androidDetails = AndroidNotificationDetails(
      'taskflow_due',
      'Task Due Reminders',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundPreference != SoundPreference.silent,
      sound: soundPreference == SoundPreference.chime
          ? const RawResourceAndroidNotificationSound('task_chime')
          : null,
    );
    await _plugin.zonedSchedule(
      task.id!,
      task.title,
      task.description.isEmpty ? 'Task is due now.' : task.description,
      scheduled,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int taskId) async {
    await _plugin.cancel(taskId);
  }
}
