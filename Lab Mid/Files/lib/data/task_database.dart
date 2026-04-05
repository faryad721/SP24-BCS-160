import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:task/models/subtask.dart';
import 'package:task/models/task.dart';
import 'package:task/models/task_bundle.dart';

class TaskDatabase {
  TaskDatabase._();

  static final TaskDatabase instance = TaskDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'task_flow.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          due_date TEXT NOT NULL,
          is_completed INTEGER NOT NULL,
          repeat_type TEXT NOT NULL,
          repeat_days TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
        ''');
        await db.execute('''
        CREATE TABLE subtasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          is_completed INTEGER NOT NULL,
          FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE tasks ADD COLUMN category TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
    return _db!;
  }

  Future<List<TaskBundle>> fetchTaskBundles() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        t.id as task_id,
        t.title as task_title,
        t.description as task_description,
        t.category as task_category,
        t.due_date as task_due_date,
        t.is_completed as task_completed,
        t.repeat_type as task_repeat_type,
        t.repeat_days as task_repeat_days,
        t.created_at as task_created_at,
        s.id as sub_id,
        s.title as sub_title,
        s.is_completed as sub_completed
      FROM tasks t
      LEFT JOIN subtasks s ON t.id = s.task_id
      ORDER BY t.due_date ASC
    ''');

    final Map<int, TaskBundle> bundleMap = {};
    for (final row in rows) {
      final taskId = row['task_id'] as int;
      final task = Task(
        id: taskId,
        title: row['task_title'] as String? ?? '',
        description: row['task_description'] as String? ?? '',
        category: row['task_category'] as String? ?? '',
        dueDate: DateTime.parse(row['task_due_date'] as String),
        isCompleted: (row['task_completed'] as int? ?? 0) == 1,
        repeatType: RepeatType.values.firstWhere(
          (value) => value.name == row['task_repeat_type'],
          orElse: () => RepeatType.none,
        ),
        repeatDays: (row['task_repeat_days'] as String? ?? '')
            .split(',')
            .where((value) => value.trim().isNotEmpty)
            .map(int.parse)
            .toList(),
        createdAt: DateTime.parse(row['task_created_at'] as String),
      );

      bundleMap.putIfAbsent(taskId, () => TaskBundle(task: task, subtasks: []));

      if (row['sub_id'] != null) {
        bundleMap[taskId]!.subtasks.add(
              Subtask(
                id: row['sub_id'] as int,
                taskId: taskId,
                title: row['sub_title'] as String? ?? '',
                isCompleted: (row['sub_completed'] as int? ?? 0) == 1,
              ),
            );
      }
    }
    return bundleMap.values.toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [id]);
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> replaceSubtasks(int taskId, List<Subtask> subtasks) async {
    final db = await database;
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [taskId]);
    for (final subtask in subtasks) {
      await db.insert('subtasks', subtask.toMap());
    }
  }

  Future<void> updateSubtask(Subtask subtask) async {
    final db = await database;
    await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<void> markTaskCompleted(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetRepeatTasksIfNeeded() async {
    final bundles = await fetchTaskBundles();
    for (final bundle in bundles) {
      if (bundle.task.repeatType == RepeatType.none) {
        continue;
      }
      if (!bundle.task.isCompleted) {
        continue;
      }
      final nextDue = _nextRepeatDate(bundle.task);
      if (nextDue.isAfter(DateTime.now())) {
        final updatedTask = bundle.task.copyWith(
          dueDate: nextDue,
          isCompleted: false,
        );
        await updateTask(updatedTask);
        final resetSubtasks = bundle.subtasks
            .map((sub) => sub.copyWith(isCompleted: false))
            .toList();
        await replaceSubtasks(bundle.task.id!, resetSubtasks);
      }
    }
  }

  DateTime _nextRepeatDate(Task task) {
    final now = DateTime.now();
    var candidate = task.dueDate;
    if (task.repeatType == RepeatType.daily) {
      while (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }
    if (task.repeatType == RepeatType.weekly && task.repeatDays.isNotEmpty) {
      var search =
          candidate.isAfter(now) ? candidate : now.add(const Duration(days: 1));
      for (var i = 0; i < 14; i++) {
        if (task.repeatDays.contains(search.weekday)) {
          return DateTime(
            search.year,
            search.month,
            search.day,
            task.dueDate.hour,
            task.dueDate.minute,
          );
        }
        search = search.add(const Duration(days: 1));
      }
    }
    return now.add(const Duration(days: 1));
  }
}
