import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task/models/subtask.dart';
import 'package:task/models/task.dart';
import 'package:task/models/task_bundle.dart';
import 'package:task/widgets/repeat_chip.dart';

class TaskFormResult {
  TaskFormResult({required this.task, required this.subtasks});

  final Task task;
  final List<Subtask> subtasks;
}

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.bundle});

  final TaskBundle? bundle;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _categoryController;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  RepeatType _repeatType = RepeatType.none;
  List<int> _repeatDays = [];
  final List<TextEditingController> _subtaskControllers = [];

  @override
  void initState() {
    super.initState();
    final bundle = widget.bundle;
    _titleController = TextEditingController(text: bundle?.task.title ?? '');
    _descController = TextEditingController(text: bundle?.task.description ?? '');
    _categoryController =
        TextEditingController(text: bundle?.task.category ?? '');
    final now = DateTime.now();
    _dueDate = bundle?.task.dueDate ?? now.add(const Duration(hours: 2));
    _dueTime = TimeOfDay.fromDateTime(_dueDate);
    _repeatType = bundle?.task.repeatType ?? RepeatType.none;
    _repeatDays = List.from(bundle?.task.repeatDays ?? []);
    if (bundle != null && bundle.subtasks.isNotEmpty) {
      for (final sub in bundle.subtasks) {
        _subtaskControllers.add(TextEditingController(text: sub.title));
      }
    } else {
      _subtaskControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _toggleRepeatDay(int day) {
    setState(() {
      if (_repeatDays.contains(day)) {
        _repeatDays.remove(day);
      } else {
        _repeatDays.add(day);
      }
    });
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );
    final effectiveRepeatType =
        _repeatType == RepeatType.weekly && _repeatDays.isEmpty
            ? RepeatType.none
            : _repeatType;
    final task = Task(
      id: widget.bundle?.task.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _categoryController.text.trim(),
      dueDate: dueDateTime,
      isCompleted: widget.bundle?.task.isCompleted ?? false,
      repeatType: effectiveRepeatType,
      repeatDays: effectiveRepeatType == RepeatType.weekly ? _repeatDays : [],
      createdAt: widget.bundle?.task.createdAt ?? DateTime.now(),
    );
    final subtasks = _subtaskControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .map((controller) => Subtask(
              id: null,
              taskId: task.id ?? 0,
              title: controller.text.trim(),
              isCompleted: false,
            ))
        .toList();
    Navigator.pop(context, TaskFormResult(task: task, subtasks: subtasks));
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bundle == null ? 'Create Task' : 'Edit Task'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Title required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(formatter.format(_dueDate)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(_dueTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RepeatType>(
              value: _repeatType,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: RepeatType.none,
                  child: Text('Does not repeat'),
                ),
                DropdownMenuItem(
                  value: RepeatType.daily,
                  child: Text('Daily'),
                ),
                DropdownMenuItem(
                  value: RepeatType.weekly,
                  child: Text('Weekly'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _repeatType = value);
                }
              },
            ),
            if (_repeatType == RepeatType.weekly) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  RepeatChip(
                    day: 1,
                    label: 'Mon',
                    selected: _repeatDays.contains(1),
                    onTap: _toggleRepeatDay,
                  ),
                  RepeatChip(
                    day: 2,
                    label: 'Tue',
                    selected: _repeatDays.contains(2),
                    onTap: _toggleRepeatDay,
                  ),
                  RepeatChip(
                    day: 3,
                    label: 'Wed',
                    selected: _repeatDays.contains(3),
                    onTap: _toggleRepeatDay,
                  ),
                  RepeatChip(
                    day: 4,
                    label: 'Thu',
                    selected: _repeatDays.contains(4),
                    onTap: _toggleRepeatDay,
                  ),
                  RepeatChip(
                    day: 5,
                    label: 'Fri',
                    selected: _repeatDays.contains(5),
                    onTap: _toggleRepeatDay,
                  ),
                  RepeatChip(
                    day: 6,
                    label: 'Sat',
                    selected: _repeatDays.contains(6),
                    onTap: _toggleRepeatDay,
                  ),
                  RepeatChip(
                    day: 7,
                    label: 'Sun',
                    selected: _repeatDays.contains(7),
                    onTap: _toggleRepeatDay,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Subtasks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._subtaskControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Subtask ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _subtaskControllers.length > 1
                          ? () => _removeSubtaskField(index)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addSubtaskField,
              icon: const Icon(Icons.add),
              label: const Text('Add subtask'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
