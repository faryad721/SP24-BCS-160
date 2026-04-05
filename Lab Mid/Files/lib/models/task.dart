enum RepeatType { none, daily, weekly }

class Task {
  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.isCompleted,
    required this.repeatType,
    required this.repeatDays,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final bool isCompleted;
  final RepeatType repeatType;
  final List<int> repeatDays;
  final DateTime createdAt;

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    RepeatType? repeatType,
    List<int>? repeatDays,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'repeat_type': repeatType.name,
      'repeat_days': repeatDays.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Task fromMap(Map<String, Object?> map) {
    final repeatDays = (map['repeat_days'] as String? ?? '')
        .split(',')
        .where((value) => value.trim().isNotEmpty)
        .map(int.parse)
        .toList();
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      repeatType: RepeatType.values.firstWhere(
        (value) => value.name == map['repeat_type'],
        orElse: () => RepeatType.none,
      ),
      repeatDays: repeatDays,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
