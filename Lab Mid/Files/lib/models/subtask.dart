class Subtask {
  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
  });

  final int? id;
  final int taskId;
  final String title;
  final bool isCompleted;

  Subtask copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  static Subtask fromMap(Map<String, Object?> map) {
    return Subtask(
      id: map['id'] as int?,
      taskId: map['task_id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }
}
