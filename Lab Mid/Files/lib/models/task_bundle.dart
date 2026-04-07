import 'package:task/models/subtask.dart';
import 'package:task/models/task.dart';

class TaskBundle {
  TaskBundle({required this.task, required this.subtasks});

  final Task task;
  final List<Subtask> subtasks;

  double get progress {
    if (subtasks.isEmpty) {
      return task.isCompleted ? 1 : 0;
    }
    final completed = subtasks.where((sub) => sub.isCompleted).length;
    return completed / subtasks.length;
  }
}
