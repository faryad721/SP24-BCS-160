import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await AppController.bootstrap();
  runApp(TaskProRoot(controller: controller));
}

class TaskProRoot extends StatelessWidget {
  const TaskProRoot({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TaskPro Studio',
          themeMode: controller.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: DashboardScreen(controller: controller),
        );
      },
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E8D92),
      brightness: brightness,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF07151A) : const Color(0xFFF5F7F3),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF11242A) : Colors.white,
      contentTextStyle: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF173138),
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: isDark ? const Color(0xFF0D1E25) : Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFF2F5EF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF7DE3DE) : const Color(0xFF0E8D92),
          width: 1.6,
        ),
      ),
    ),
  );
}

enum RepeatMode { none, daily, weekly }

extension RepeatModeLabel on RepeatMode {
  String get label => switch (this) {
        RepeatMode.none => 'No repeat',
        RepeatMode.daily => 'Daily',
        RepeatMode.weekly => 'Selected days',
      };
}

enum NotificationSoundProfile { ripple, pulse, focus }

extension NotificationSoundProfileLabel on NotificationSoundProfile {
  String get label => switch (this) {
        NotificationSoundProfile.ripple => 'Ripple',
        NotificationSoundProfile.pulse => 'Pulse',
        NotificationSoundProfile.focus => 'Focus',
      };

  bool get playsSound => this != NotificationSoundProfile.focus;
}

class SubtaskItem {
  const SubtaskItem({
    required this.title,
    this.isDone = false,
  });

  final String title;
  final bool isDone;

  SubtaskItem copyWith({
    String? title,
    bool? isDone,
  }) {
    return SubtaskItem(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  factory SubtaskItem.fromJson(Map<String, dynamic> json) {
    return SubtaskItem(
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

class TaskItem {
  const TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.repeatMode,
    required this.repeatWeekdays,
    required this.subtasks,
    required this.colorValue,
    required this.notificationSound,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final RepeatMode repeatMode;
  final List<int> repeatWeekdays;
  final List<SubtaskItem> subtasks;
  final int colorValue;
  final NotificationSoundProfile notificationSound;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  double get progress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1 : 0;
    }

    final done = subtasks.where((item) => item.isDone).length;
    return done / subtasks.length;
  }

  bool get isRepeating => repeatMode != RepeatMode.none;

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    RepeatMode? repeatMode,
    List<int>? repeatWeekdays,
    List<SubtaskItem>? subtasks,
    int? colorValue,
    NotificationSoundProfile? notificationSound,
    bool? isCompleted,
    Object? completedAt = _marker,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      repeatMode: repeatMode ?? this.repeatMode,
      repeatWeekdays: repeatWeekdays ?? this.repeatWeekdays,
      subtasks: subtasks ?? this.subtasks,
      colorValue: colorValue ?? this.colorValue,
      notificationSound: notificationSound ?? this.notificationSound,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: identical(completedAt, _marker)
          ? this.completedAt
          : completedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'repeat_mode': repeatMode.name,
      'repeat_weekdays': repeatWeekdays.join(','),
      'subtasks_json':
          jsonEncode(subtasks.map((item) => item.toJson()).toList()),
      'color_value': colorValue,
      'notification_sound': notificationSound.name,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    final rawSubtasks = (jsonDecode(map['subtasks_json'] as String? ?? '[]')
            as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final weekdayText = map['repeat_weekdays'] as String? ?? '';

    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      repeatMode: RepeatMode.values.byName(
        map['repeat_mode'] as String? ?? RepeatMode.none.name,
      ),
      repeatWeekdays: weekdayText.isEmpty
          ? const []
          : weekdayText
              .split(',')
              .where((value) => value.isNotEmpty)
              .map(int.parse)
              .toList(),
      subtasks: rawSubtasks.map(SubtaskItem.fromJson).toList(),
      colorValue:
          map['color_value'] as int? ?? const Color(0xFF0E8D92).toARGB32(),
      notificationSound: NotificationSoundProfile.values.byName(
        map['notification_sound'] as String? ??
            NotificationSoundProfile.ripple.name,
      ),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at'] as String),
    );
  }
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.repeatMode,
    required this.repeatWeekdays,
    required this.subtasks,
    required this.notificationSound,
  });

  final String title;
  final String description;
  final DateTime dueDate;
  final RepeatMode repeatMode;
  final List<int> repeatWeekdays;
  final List<SubtaskItem> subtasks;
  final NotificationSoundProfile notificationSound;
}

class TaskDatabase {
  TaskDatabase._(this._database);

  final Database _database;

  static Future<TaskDatabase> create() async {
    final dbPath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(dbPath, 'taskpro.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            due_date TEXT NOT NULL,
            repeat_mode TEXT NOT NULL,
            repeat_weekdays TEXT NOT NULL,
            subtasks_json TEXT NOT NULL,
            color_value INTEGER NOT NULL,
            notification_sound TEXT NOT NULL,
            is_completed INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            completed_at TEXT
          )
        ''');
      },
    );
    return TaskDatabase._(database);
  }

  Future<List<TaskItem>> fetchTasks() async {
    final rows = await _database.query('tasks', orderBy: 'due_date ASC');
    return rows.map(TaskItem.fromMap).toList();
  }

  Future<int> insert(TaskItem task) async {
    return _database.insert(
      'tasks',
      task.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(TaskItem task) async {
    await _database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> delete(int taskId) async {
    await _database.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }
}

class NotificationService {
  NotificationService._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<NotificationService> create() async {
    tz.initializeTimeZones();
    final plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings);
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return NotificationService._(plugin);
  }

  Future<void> scheduleTask(TaskItem task) async {
    if (task.id == null || task.isCompleted || task.dueDate.isBefore(DateTime.now())) {
      return;
    }

    final profile = task.notificationSound;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'taskpro_${profile.name}',
        'Task reminders ${profile.label}',
        channelDescription: 'Due date reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: profile.playsSound,
        enableVibration: true,
        color: Color(task.colorValue),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: profile.playsSound,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: profile.playsSound,
      ),
    );

    await _plugin.zonedSchedule(
      task.id!,
      task.title,
      'Due ${DateFormat('hh:mm a').format(task.dueDate)} • ${task.description}',
      tz.TZDateTime.from(task.dueDate.toUtc(), tz.UTC),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTask(int taskId) async {
    await _plugin.cancel(taskId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> preview(NotificationSoundProfile profile) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'preview_${profile.name}',
        'Preview ${profile.label}',
        importance: Importance.max,
        priority: Priority.high,
        playSound: profile.playsSound,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: profile.playsSound,
      ),
    );
    await _plugin.show(
      900001,
      'TaskPro Studio',
      'Previewing the ${profile.label} reminder style.',
      details,
    );
  }
}

class AppController extends ChangeNotifier {
  AppController._({
    required ThemeMode themeMode,
    required NotificationSoundProfile appSound,
    required List<TaskItem> tasks,
    TaskDatabase? database,
    NotificationService? notifications,
    SharedPreferences? preferences,
  })  : _themeMode = themeMode,
        _appSound = appSound,
        _tasks = tasks,
        _database = database,
        _notifications = notifications,
        _preferences = preferences;

  static const _themeKey = 'theme_mode';
  static const _soundKey = 'notification_sound';
  static const _markerValue = Object();

  ThemeMode _themeMode;
  NotificationSoundProfile _appSound;
  List<TaskItem> _tasks;
  final TaskDatabase? _database;
  final NotificationService? _notifications;
  final SharedPreferences? _preferences;

  ThemeMode get themeMode => _themeMode;
  NotificationSoundProfile get appSound => _appSound;
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  List<TaskItem> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return !task.isCompleted && _isSameDate(task.dueDate, today);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<TaskItem> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList()
      ..sort((a, b) {
        final aTime = a.completedAt ?? a.dueDate;
        final bTime = b.completedAt ?? b.dueDate;
        return bTime.compareTo(aTime);
      });
  }

  List<TaskItem> get repeatedTasks {
    return _tasks.where((task) => task.isRepeating && !task.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<TaskItem> get upcomingTasks {
    final today = _dateOnly(DateTime.now());
    return _tasks.where((task) {
      return !task.isCompleted && _dateOnly(task.dueDate).isAfter(today);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  int get completedCount => _tasks.where((task) => task.isCompleted).length;

  double get overallProgress {
    if (_tasks.isEmpty) {
      return 0;
    }

    final total = _tasks.fold<double>(0, (sum, task) => sum + task.progress);
    return total / _tasks.length;
  }

  static Future<AppController> bootstrap() async {
    final preferences = await SharedPreferences.getInstance();
    final database = await TaskDatabase.create();
    final notifications = await NotificationService.create();
    final themeText = preferences.getString(_themeKey) ?? ThemeMode.dark.name;
    final soundText = preferences.getString(_soundKey) ??
        NotificationSoundProfile.ripple.name;

    final controller = AppController._(
      themeMode: ThemeMode.values.byName(themeText),
      appSound: NotificationSoundProfile.values.byName(soundText),
      tasks: await database.fetchTasks(),
      database: database,
      notifications: notifications,
      preferences: preferences,
    );

    await controller._normalizeRepeatCycles();
    await controller._rescheduleNotifications();
    return controller;
  }

  factory AppController.preview() {
    return AppController._(
      themeMode: ThemeMode.dark,
      appSound: NotificationSoundProfile.ripple,
      tasks: [
        TaskItem(
          id: 1,
          title: 'Product pitch rehearsal',
          description: 'Finalize slides, transitions, and timing blocks.',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          repeatMode: RepeatMode.none,
          repeatWeekdays: const [],
          subtasks: const [
            SubtaskItem(title: 'Review timing', isDone: true),
            SubtaskItem(title: 'Dry run with notes'),
          ],
          colorValue: const Color(0xFFF28B50).toARGB32(),
          notificationSound: NotificationSoundProfile.ripple,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> addTask(TaskDraft draft) async {
    final baseTask = TaskItem(
      title: draft.title,
      description: draft.description,
      dueDate: draft.dueDate,
      repeatMode: draft.repeatMode,
      repeatWeekdays: draft.repeatWeekdays,
      subtasks: draft.subtasks,
      colorValue: _palette[_tasks.length % _palette.length].toARGB32(),
      notificationSound: draft.notificationSound,
      createdAt: DateTime.now(),
    );

    if (_database == null) {
      _tasks = [baseTask, ..._tasks];
      notifyListeners();
      return;
    }

    final taskId = await _database.insert(baseTask);
    final saved = baseTask.copyWith(id: taskId);
    _tasks = [saved, ..._tasks];
    await _notifications?.scheduleTask(saved);
    notifyListeners();
  }

  Future<void> updateTask(TaskItem task) async {
    _replaceTask(task);
    await _database?.update(task);
    if (task.id != null) {
      await _notifications?.cancelTask(task.id!);
      await _notifications?.scheduleTask(task);
    }
    notifyListeners();
  }

  Future<void> deleteTask(TaskItem task) async {
    final taskId = task.id;
    if (taskId != null) {
      await _database?.delete(taskId);
      await _notifications?.cancelTask(taskId);
    }
    _tasks = _tasks.where((item) => item.id != task.id).toList();
    notifyListeners();
  }

  Future<String> toggleCompletion(TaskItem task) async {
    if (task.isRepeating && !task.isCompleted) {
      final nextDue = _nextOccurrence(task);
      final rolledTask = task.copyWith(
        dueDate: nextDue,
        isCompleted: false,
        completedAt: null,
        subtasks: task.subtasks
            .map((item) => item.copyWith(isDone: false))
            .toList(),
      );
      await updateTask(rolledTask);
      return 'Task completed and moved into its next repeat cycle.';
    }

    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: task.isCompleted ? null : DateTime.now(),
      subtasks: task.isCompleted
          ? task.subtasks
          : task.subtasks.map((item) => item.copyWith(isDone: true)).toList(),
    );
    await updateTask(updated);
    return updated.isCompleted
        ? 'Task moved to the completed board.'
        : 'Task moved back to your active lists.';
  }

  Future<void> updateSubtask(TaskItem task, int index, bool isDone) async {
    final subtasks = [...task.subtasks];
    subtasks[index] = subtasks[index].copyWith(isDone: isDone);
    await updateTask(task.copyWith(subtasks: subtasks));
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    await _preferences?.setString(_themeKey, value.name);
    notifyListeners();
  }

  Future<void> setNotificationSound(NotificationSoundProfile value) async {
    _appSound = value;
    await _preferences?.setString(_soundKey, value.name);
    notifyListeners();
  }

  Future<void> previewNotification() async {
    await _notifications?.preview(_appSound);
  }

  Future<File> exportCsv() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        directory.path,
        'taskpro_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      ),
    );
    final buffer = StringBuffer()
      ..writeln(
        'Title,Description,Due Date,Status,Repeat,Progress,Notification Sound',
      );

    for (final task in _tasks) {
      buffer.writeln(
        [
          _csv(task.title),
          _csv(task.description),
          _csv(DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate)),
          _csv(task.isCompleted ? 'Completed' : 'Pending'),
          _csv(task.repeatMode.label),
          _csv('${(task.progress * 100).round()}%'),
          _csv(task.notificationSound.label),
        ].join(','),
      );
    }

    await file.writeAsString(buffer.toString());
    return file;
  }

  Future<File> exportPdf() async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Text(
              'TaskPro Studio Export',
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            ..._tasks.map(
              (task) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(14),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      task.title,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(task.description),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Due: ${DateFormat('EEE, dd MMM yyyy • hh:mm a').format(task.dueDate)}',
                    ),
                    pw.Text(
                      'Status: ${task.isCompleted ? 'Completed' : 'Pending'}',
                    ),
                    pw.Text('Progress: ${(task.progress * 100).round()}%'),
                    pw.Text('Repeat: ${task.repeatMode.label}'),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await document.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        directory.path,
        'taskpro_export_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> shareFile(File file, String subject) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject,
        text: 'Shared from TaskPro Studio',
      ),
    );
  }

  Future<void> exportToEmail() async {
    final lines = _tasks.map((task) {
      return '- ${task.title} | ${DateFormat('dd MMM, hh:mm a').format(task.dueDate)} | '
          '${task.isCompleted ? 'Completed' : 'Pending'}';
    }).join('\n');

    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'TaskPro Studio Export',
        'body': 'Task summary:\n\n$lines',
      },
    );
    await launchUrl(uri);
  }

  Future<void> _normalizeRepeatCycles() async {
    final today = DateTime.now();
    var changed = false;
    final normalized = <TaskItem>[];

    for (final task in _tasks) {
      if (!task.isRepeating) {
        normalized.add(task);
        continue;
      }

      var current = task;
      while (!current.isCompleted &&
          _dateOnly(current.dueDate).isBefore(_dateOnly(today))) {
        current = current.copyWith(
          dueDate: _nextOccurrence(current),
          subtasks:
              current.subtasks.map((item) => item.copyWith(isDone: false)).toList(),
        );
        changed = true;
      }
      normalized.add(current);
    }

    _tasks = normalized;
    if (changed) {
      for (final task in _tasks) {
        if (task.id != null) {
          await _database?.update(task);
        }
      }
    }
  }

  Future<void> _rescheduleNotifications() async {
    await _notifications?.cancelAll();
    for (final task in _tasks.where((item) => !item.isCompleted)) {
      await _notifications?.scheduleTask(task);
    }
  }

  void _replaceTask(TaskItem updated) {
    _tasks = _tasks.map((task) {
      if (task.id == updated.id && task.id != null) {
        return updated;
      }
      return task;
    }).toList();
  }

  DateTime _nextOccurrence(TaskItem task) {
    final base = task.dueDate;
    final now = DateTime.now();
    switch (task.repeatMode) {
      case RepeatMode.none:
        return base;
      case RepeatMode.daily:
        var next = base.add(const Duration(days: 1));
        while (_dateOnly(next).isBefore(_dateOnly(now))) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case RepeatMode.weekly:
        final selected = task.repeatWeekdays.isEmpty
            ? [base.weekday]
            : [...task.repeatWeekdays]..sort();
        var cursor = base.add(const Duration(days: 1));
        while (true) {
          if (selected.contains(cursor.weekday) &&
              !_dateOnly(cursor).isBefore(_dateOnly(now))) {
            return cursor;
          }
          cursor = cursor.add(const Duration(days: 1));
        }
    }
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final sections = [
      _TodayBoard(controller: controller),
      _CompletedBoard(controller: controller),
      _RepeatedBoard(controller: controller),
      _StudioBoard(controller: controller),
    ];

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: _backgroundDecoration(context),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -20,
                child: _GlowOrb(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.22),
                  size: 220,
                ),
              ),
              Positioned(
                top: 120,
                left: -40,
                child: _GlowOrb(
                  color: const Color(0xFFF28B50).withValues(alpha: 0.15),
                  size: 180,
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _HeroHeader(
                      controller: controller,
                      currentIndex: _currentIndex,
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: sections[_currentIndex],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(context, controller),
              backgroundColor: const Color(0xFFF28B50),
              foregroundColor: const Color(0xFF132127),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('New Task'),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.wb_sunny_outlined),
                selectedIcon: Icon(Icons.wb_sunny),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt),
                label: 'Completed',
              ),
              NavigationDestination(
                icon: Icon(Icons.repeat_outlined),
                selectedIcon: Icon(Icons.repeat),
                label: 'Repeated',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Studio',
              ),
            ],
            onDestinationSelected: (value) {
              setState(() => _currentIndex = value);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    AppController controller, {
    TaskItem? task,
  }) async {
    final result = await showModalBottomSheet<TaskDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskEditorSheet(
          initialTask: task,
          defaultSound: task?.notificationSound ?? controller.appSound,
        );
      },
    );

    if (!context.mounted || result == null) {
      return;
    }

    if (task == null) {
      await controller.addTask(result);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added to your planner.')),
      );
      return;
    }

    await controller.updateTask(
      task.copyWith(
        title: result.title,
        description: result.description,
        dueDate: result.dueDate,
        repeatMode: result.repeatMode,
        repeatWeekdays: result.repeatWeekdays,
        subtasks: result.subtasks,
        notificationSound: result.notificationSound,
      ),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully.')),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.controller,
    required this.currentIndex,
  });

  final AppController controller;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final labels = ['Today Task', 'Completed Task', 'Repeated Task', 'Studio'];
    final titles = [
      'Shape a beautiful day.',
      'Track what you finished.',
      'Keep recurring routines alive.',
      'Control themes, exports, and reminders.',
    ];

    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.74),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labels[currentIndex],
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF28B50),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              titles[currentIndex],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(
                  label: 'Tasks',
                  value: controller.tasks.length.toString(),
                ),
                _StatChip(
                  label: 'Done',
                  value: controller.completedCount.toString(),
                ),
                _StatChip(
                  label: 'Progress',
                  value: '${(controller.overallProgress * 100).round()}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayBoard extends StatelessWidget {
  const _TodayBoard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final todayTasks = controller.todayTasks;
    final upcomingTasks = controller.upcomingTasks;
    return ListView(
      key: const ValueKey('today'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        _OverviewBand(controller: controller),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Today Timeline',
          subtitle: 'Due now, due soon, and every detail in one flow.',
        ),
        const SizedBox(height: 14),
        if (todayTasks.isEmpty)
          const _EmptyState(
            title: 'No tasks due today',
            message: 'Create a task and TaskPro Studio will light up this board.',
          )
        else
          ...todayTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TaskCard(
                task: task,
                onComplete: () => _handleCompletion(context, task),
                onDelete: () => _handleDelete(context, task),
                onEdit: () => _openEdit(context, task),
                onSubtaskToggled: (index, value) {
                  controller.updateSubtask(task, index, value);
                },
              ),
            ),
          ),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Upcoming Tasks',
          subtitle: 'Future-dated tasks stay visible here before their due day arrives.',
        ),
        const SizedBox(height: 14),
        if (upcomingTasks.isEmpty)
          const _EmptyState(
            title: 'No upcoming tasks',
            message: 'Tasks for tomorrow or later will appear here.',
          )
        else
          ...upcomingTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TaskCard(
                task: task,
                onComplete: () => _handleCompletion(context, task),
                onDelete: () => _handleDelete(context, task),
                onEdit: () => _openEdit(context, task),
                onSubtaskToggled: (index, value) {
                  controller.updateSubtask(task, index, value);
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleCompletion(BuildContext context, TaskItem task) async {
    final message = await controller.toggleCompletion(task);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleDelete(BuildContext context, TaskItem task) async {
    await controller.deleteTask(task);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task removed from the planner.')),
    );
  }

  Future<void> _openEdit(BuildContext context, TaskItem task) async {
    final state = context.findAncestorStateOfType<_DashboardScreenState>();
    await state?._openEditor(context, controller, task: task);
  }
}

class _CompletedBoard extends StatelessWidget {
  const _CompletedBoard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final completed = controller.completedTasks;
    return ListView(
      key: const ValueKey('completed'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        const _SectionTitle(
          title: 'Completed Flow',
          subtitle: 'Every finished task lands here with its progress snapshot.',
        ),
        const SizedBox(height: 14),
        if (completed.isEmpty)
          const _EmptyState(
            title: 'Nothing completed yet',
            message: 'Mark a task as complete and it will appear here automatically.',
          )
        else
          ...completed.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TaskCard(
                task: task,
                onComplete: () async {
                  final message = await controller.toggleCompletion(task);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                },
                onDelete: () async {
                  await controller.deleteTask(task);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completed task deleted.')),
                  );
                },
                onEdit: () async {
                  final state =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  await state?._openEditor(context, controller, task: task);
                },
                onSubtaskToggled: (index, value) {},
              ),
            ),
          ),
      ],
    );
  }
}

class _RepeatedBoard extends StatelessWidget {
  const _RepeatedBoard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final repeated = controller.repeatedTasks;
    return ListView(
      key: const ValueKey('repeated'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        const _SectionTitle(
          title: 'Repeat Engine',
          subtitle: 'Daily habits and selected weekday cycles reset automatically.',
        ),
        const SizedBox(height: 14),
        if (repeated.isEmpty)
          const _EmptyState(
            title: 'No repeating tasks',
            message: 'Add a daily or selected-days routine to build momentum here.',
          )
        else
          ...repeated.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TaskCard(
                task: task,
                onComplete: () async {
                  final message = await controller.toggleCompletion(task);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                },
                onDelete: () async {
                  await controller.deleteTask(task);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Repeating task deleted.')),
                  );
                },
                onEdit: () async {
                  final state =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  await state?._openEditor(context, controller, task: task);
                },
                onSubtaskToggled: (index, value) {
                  controller.updateSubtask(task, index, value);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _StudioBoard extends StatelessWidget {
  const _StudioBoard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('studio'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        const _SectionTitle(
          title: 'Customization + Export',
          subtitle: 'Theme controls, reminder sound style, exports, and quick actions.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.phone_android),
                    ),
                  ],
                  selected: {controller.themeMode},
                  onSelectionChanged: (values) {
                    controller.setThemeMode(values.first);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Notification Sound Style',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<NotificationSoundProfile>(
                  initialValue: controller.appSound,
                  items: NotificationSoundProfile.values.map((profile) {
                    return DropdownMenuItem(
                      value: profile,
                      child: Text(profile.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setNotificationSound(value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () async {
                    await controller.previewNotification();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification preview sent.')),
                    );
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Preview Reminder'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Center',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final file = await controller.exportCsv();
                        await controller.shareFile(file, 'TaskPro CSV Export');
                      },
                      icon: const Icon(Icons.table_view),
                      label: const Text('Export CSV'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final file = await controller.exportPdf();
                        await controller.shareFile(file, 'TaskPro PDF Export');
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export PDF'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await controller.exportToEmail();
                      },
                      icon: const Icon(Icons.email),
                      label: const Text('Export Email'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewBand extends StatelessWidget {
  const _OverviewBand({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        title: 'Today',
        value: controller.todayTasks.length.toString(),
        color: const Color(0xFF0E8D92)
      ),
      (
        title: 'Completed',
        value: controller.completedCount.toString(),
        color: const Color(0xFFF28B50)
      ),
      (
        title: 'Repeating',
        value: controller.repeatedTasks.length.toString(),
        color: const Color(0xFF78C5A1)
      ),
    ];

    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: card == cards.last ? 0 : 10),
            child: Card(
              color: card.color.withValues(alpha: 0.16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card.value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
    required this.onSubtaskToggled,
  });

  final TaskItem task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final void Function(int index, bool value) onSubtaskToggled;

  @override
  Widget build(BuildContext context) {
    final color = Color(task.colorValue);
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.74),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaPill(
                            icon: Icons.schedule,
                            text: DateFormat('EEE • hh:mm a').format(task.dueDate),
                          ),
                          _MetaPill(
                            icon: Icons.sync,
                            text: task.repeatMode.label,
                          ),
                          _MetaPill(
                            icon: Icons.notifications_active_outlined,
                            text: task.notificationSound.label,
                          ),
                          if (task.isRepeating)
                            _MetaPill(
                              icon: Icons.event_repeat,
                              text:
                                  'Next ${DateFormat('dd MMM').format(_previewNextOccurrence(task))}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'complete':
                        onComplete();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'complete', child: Text('Toggle complete')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: task.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 6),
            Text(
              '${(task.progress * 100).round()}% progress',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (task.isRepeating) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_repeat, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Upcoming next date: ${DateFormat('EEE, dd MMM yyyy • hh:mm a').format(_previewNextOccurrence(task))}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...task.subtasks.asMap().entries.map(
                (entry) => CheckboxListTile(
                  value: entry.value.isDone,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: task.isCompleted
                      ? null
                      : (value) {
                          onSubtaskToggled(entry.key, value ?? false);
                        },
                  title: Text(entry.value.title),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: task.isCompleted
                        ? const Color(0xFF78C5A1)
                        : const Color(0xFF173138),
                  ),
                  icon: Icon(task.isCompleted ? Icons.undo : Icons.task_alt),
                  label: Text(task.isCompleted ? 'Reopen' : 'Complete'),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    this.initialTask,
    required this.defaultSound,
  });

  final TaskItem? initialTask;
  final NotificationSoundProfile defaultSound;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late RepeatMode _repeatMode;
  late NotificationSoundProfile _sound;
  late List<SubtaskItem> _subtasks;
  late Set<int> _weekdays;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(hours: 2));
    _repeatMode = task?.repeatMode ?? RepeatMode.none;
    _sound = task?.notificationSound ?? widget.defaultSound;
    _subtasks = [...?task?.subtasks];
    _weekdays = {...?task?.repeatWeekdays};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 40, 12, viewInsets + 12),
      child: Card(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialTask == null ? 'Create Task' : 'Edit Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build a polished task with repeat rules, subtasks, and notification styling.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(DateFormat('EEE, dd MMM').format(_dueDate)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(DateFormat('hh:mm a').format(_dueDate)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RepeatMode>(
                  initialValue: _repeatMode,
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  items: RepeatMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _repeatMode = value);
                    }
                  },
                ),
                if (_repeatMode == RepeatMode.weekly) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final selected = _weekdays.contains(weekday);
                      return FilterChip(
                        label: Text(labels[index]),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _weekdays.add(weekday);
                            } else {
                              _weekdays.remove(weekday);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<NotificationSoundProfile>(
                  initialValue: _sound,
                  decoration: const InputDecoration(labelText: 'Reminder sound'),
                  items: NotificationSoundProfile.values.map((profile) {
                    return DropdownMenuItem(
                      value: profile,
                      child: Text(profile.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sound = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        decoration: const InputDecoration(hintText: 'Add a subtask'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _addSubtask, child: const Text('Add')),
                  ],
                ),
                const SizedBox(height: 12),
                if (_subtasks.isEmpty)
                  const Text('No subtasks yet.')
                else
                  ..._subtasks.asMap().entries.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: entry.value.isDone,
                        onChanged: (value) {
                          setState(() {
                            _subtasks[entry.key] = entry.value.copyWith(
                              isDone: value ?? false,
                            );
                          });
                        },
                      ),
                      title: Text(entry.value.title),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() => _subtasks.removeAt(entry.key));
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.rocket_launch),
                    label: Text(
                      widget.initialTask == null ? 'Create Task' : 'Save Changes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueDate.hour,
          _dueDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _subtasks = [..._subtasks, SubtaskItem(title: text)];
      _subtaskController.clear();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_repeatMode == RepeatMode.weekly && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one weekday for repeating tasks.')),
      );
      return;
    }

    Navigator.pop(
      context,
      TaskDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        repeatMode: _repeatMode,
        repeatWeekdays: _weekdays.toList()..sort(),
        subtasks: _subtasks,
        notificationSound: _sound,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
              ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_motion, size: 46),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}

Decoration _backgroundDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    gradient: LinearGradient(
      colors: isDark
          ? const [
              Color(0xFF051118),
              Color(0xFF0A2028),
              Color(0xFF102E2B),
            ]
          : const [
              Color(0xFFF8F8F2),
              Color(0xFFE8F5EF),
              Color(0xFFDFF0F3),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _isSameDate(DateTime a, DateTime b) => _dateOnly(a) == _dateOnly(b);

DateTime _previewNextOccurrence(TaskItem task) {
  if (!task.isRepeating) {
    return task.dueDate;
  }

  switch (task.repeatMode) {
    case RepeatMode.none:
      return task.dueDate;
    case RepeatMode.daily:
      return task.dueDate.add(const Duration(days: 1));
    case RepeatMode.weekly:
      final selected = task.repeatWeekdays.isEmpty
          ? [task.dueDate.weekday]
          : [...task.repeatWeekdays]..sort();
      var cursor = task.dueDate.add(const Duration(days: 1));
      while (true) {
        if (selected.contains(cursor.weekday)) {
          return cursor;
        }
        cursor = cursor.add(const Duration(days: 1));
      }
  }
}

String _csv(String value) => '"${value.replaceAll('"', '""')}"';

const _marker = AppController._markerValue;

const List<Color> _palette = [
  Color(0xFF0E8D92),
  Color(0xFFF28B50),
  Color(0xFF78C5A1),
  Color(0xFFE06767),
  Color(0xFF5C8DF6),
];
