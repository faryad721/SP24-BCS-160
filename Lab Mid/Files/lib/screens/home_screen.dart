import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:task/data/task_database.dart';
import 'package:task/models/sound_preference.dart';
import 'package:task/models/task.dart';
import 'package:task/models/task_bundle.dart';
import 'package:task/screens/task_form_screen.dart';
import 'package:task/services/export_service.dart';
import 'package:task/services/notification_service.dart';
import 'package:task/widgets/task_card.dart';
import 'package:task/widgets/task_details_sheet.dart';

enum ExportType { csv, pdf }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.soundPreference,
    required this.onThemeChanged,
    required this.onSoundChanged,
  });

  final ThemeMode themeMode;
  final SoundPreference soundPreference;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<SoundPreference> onSoundChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskDatabase _database = TaskDatabase.instance;
  final ExportService _exportService = ExportService();
  final DateFormat _dateFormat = DateFormat('EEE, MMM d · h:mm a');

  bool _loading = true;
  List<TaskBundle> _bundles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _database.resetRepeatTasksIfNeeded();
    _bundles = await _database.fetchTaskBundles();
    setState(() => _loading = false);
  }

  Future<void> _openTaskForm({TaskBundle? bundle}) async {
    final result = await Navigator.push<TaskFormResult>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(bundle: bundle),
      ),
    );
    if (result == null) {
      return;
    }
    if (bundle == null) {
      final newId = await _database.insertTask(result.task);
      await _database.replaceSubtasks(
        newId,
        result.subtasks.map((sub) => sub.copyWith(taskId: newId)).toList(),
      );
      await NotificationService.instance.scheduleTaskNotification(
        result.task.copyWith(id: newId),
        widget.soundPreference,
      );
    } else {
      await _database.updateTask(result.task);
      await _database.replaceSubtasks(result.task.id!, result.subtasks);
      await NotificationService.instance.cancelNotification(result.task.id!);
      await NotificationService.instance.scheduleTaskNotification(
        result.task,
        widget.soundPreference,
      );
    }
    await _load();
  }

  Future<void> _deleteTask(TaskBundle bundle) async {
    await _database.deleteTask(bundle.task.id!);
    await NotificationService.instance.cancelNotification(bundle.task.id!);
    await _load();
  }

  Future<void> _confirmDelete(TaskBundle bundle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          'Are you sure you want to delete "${bundle.task.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _deleteTask(bundle);
    }
  }

  Future<void> _toggleComplete(TaskBundle bundle, bool value) async {
    await _database.markTaskCompleted(bundle.task.id!, value);
    if (value) {
      await NotificationService.instance.cancelNotification(bundle.task.id!);
    } else {
      await NotificationService.instance.scheduleTaskNotification(
        bundle.task.copyWith(isCompleted: false),
        widget.soundPreference,
      );
    }
    await _load();
  }

  List<TaskBundle> _todayTasks() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1)).subtract(
      const Duration(milliseconds: 1),
    );
    return _bundles.where((bundle) {
      final due = bundle.task.dueDate.toLocal();
      return !bundle.task.isCompleted &&
          (due.isAtSameMomentAs(startOfToday) ||
              (due.isAfter(startOfToday) && due.isBefore(endOfToday)));
    }).toList();
  }

  List<TaskBundle> _upcomingTasks() {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    return _bundles.where((bundle) {
      final due = bundle.task.dueDate.toLocal();
      return !bundle.task.isCompleted && due.isAfter(endOfToday);
    }).toList();
  }

  List<TaskBundle> _completedTasks() {
    return _bundles.where((bundle) => bundle.task.isCompleted).toList();
  }

  List<TaskBundle> _repeatedTasks() {
    return _bundles
        .where((bundle) => bundle.task.repeatType != RepeatType.none)
        .toList();
  }

  Future<void> _exportTasks(ExportType type) async {
    final bundles = _bundles;
    if (bundles.isEmpty) {
      _showSnack('Nothing to export yet.');
      return;
    }
    File file;
    if (type == ExportType.csv) {
      file = await _exportService.exportCsv(bundles);
    } else {
      file = await _exportService.exportPdf(bundles);
    }
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Task Export',
      text: 'Here is your task export from TaskFlow.',
    );
  }

  Future<void> _emailTasks() async {
    final bundles = _bundles;
    if (bundles.isEmpty) {
      _showSnack('Nothing to email yet.');
      return;
    }
    final file = await _exportService.exportPdf(bundles);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TaskFlow Export',
      text: 'Sharing your tasks via email.',
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TaskFlow',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Export',
              icon: const Icon(Icons.file_upload_outlined),
              onPressed: () => _showExportSheet(context),
            ),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.tune),
              onPressed: () => _showSettingsSheet(context),
            ),
          ],
          bottom: TabBar(
            labelColor: colorScheme.onSurface,
            indicatorColor: colorScheme.secondary,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Repeated'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openTaskForm(),
          icon: const Icon(Icons.add),
          label: const Text('New Task'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTaskList(_todayTasks(), emptyMessage: 'No tasks due today.'),
                  _buildTaskList(_upcomingTasks(),
                      emptyMessage: 'No upcoming tasks yet.'),
                  _buildTaskList(_completedTasks(),
                      emptyMessage: 'No completed tasks yet.'),
                  _buildTaskList(_repeatedTasks(),
                      emptyMessage: 'No repeated tasks yet.'),
                ],
              ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskBundle> bundles, {required String emptyMessage}) {
    if (bundles.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bundles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final bundle = bundles[index];
        return TaskCard(
          bundle: bundle,
          dateFormat: _dateFormat,
          onToggleCompleted: (value) => _toggleComplete(bundle, value),
          onEdit: () => _openTaskForm(bundle: bundle),
          onDelete: () => _confirmDelete(bundle),
          onOpenDetails: () => _openDetails(bundle),
        );
      },
    );
  }

  Future<void> _openDetails(TaskBundle bundle) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskDetailsSheet(
          bundle: bundle,
          onUpdate: (updated) async {
            await _database.updateTask(updated.task);
            await _database.replaceSubtasks(updated.task.id!, updated.subtasks);
            await _load();
          },
        );
      },
    );
  }

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: const Text('Export to CSV'),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportTasks(ExportType.csv);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Export to PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportTasks(ExportType.pdf);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email export (PDF)'),
                onTap: () async {
                  Navigator.pop(context);
                  await _emailTasks();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Customize',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: widget.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onThemeChanged(value);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notification sound'),
                subtitle: const Text('Default, chime, or silent'),
                trailing: DropdownButton<SoundPreference>(
                  value: widget.soundPreference,
                  items: const [
                    DropdownMenuItem(
                      value: SoundPreference.defaultSound,
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: SoundPreference.chime,
                      child: Text('Chime'),
                    ),
                    DropdownMenuItem(
                      value: SoundPreference.silent,
                      child: Text('Silent'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onSoundChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
