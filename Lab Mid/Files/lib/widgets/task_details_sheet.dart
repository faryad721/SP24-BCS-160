import 'package:flutter/material.dart';
import 'package:task/models/subtask.dart';
import 'package:task/models/task_bundle.dart';

class TaskDetailsSheet extends StatefulWidget {
  const TaskDetailsSheet({
    super.key,
    required this.bundle,
    required this.onUpdate,
  });

  final TaskBundle bundle;
  final ValueChanged<TaskBundle> onUpdate;

  @override
  State<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<TaskDetailsSheet> {
  late TaskBundle _bundle;

  @override
  void initState() {
    super.initState();
    _bundle = TaskBundle(
      task: widget.bundle.task,
      subtasks: widget.bundle.subtasks.map((s) => s.copyWith()).toList(),
    );
  }

  void _toggleSubtask(Subtask subtask, bool value) {
    setState(() {
      final index = _bundle.subtasks.indexWhere((s) => s.id == subtask.id);
      if (index != -1) {
        _bundle.subtasks[index] =
            _bundle.subtasks[index].copyWith(isCompleted: value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.bundle.task.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _bundle.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.secondary,
            backgroundColor: colorScheme.secondary.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          if (_bundle.task.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _bundle.task.category,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_bundle.task.category.isNotEmpty) const SizedBox(height: 12),
          Text('Subtasks', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_bundle.subtasks.isEmpty)
            Text(
              'No subtasks added yet.',
              style: TextStyle(color: Theme.of(context).hintColor),
            )
          else
            ..._bundle.subtasks.map((subtask) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: subtask.isCompleted,
                title: Text(subtask.title),
                onChanged: (value) {
                  if (value != null) {
                    _toggleSubtask(subtask, value);
                  }
                },
              );
            }),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              widget.onUpdate(_bundle);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text('Save progress'),
          ),
        ],
      ),
    );
  }
}
