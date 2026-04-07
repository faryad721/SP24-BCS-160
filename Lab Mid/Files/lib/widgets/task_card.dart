import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task/models/task.dart';
import 'package:task/models/task_bundle.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.bundle,
    required this.dateFormat,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenDetails,
  });

  final TaskBundle bundle;
  final DateFormat dateFormat;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onToggleCompleted(!bundle.task.isCompleted),
        onLongPress: onOpenDetails,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: bundle.task.isCompleted,
                  onChanged: (value) {
                    if (value != null) {
                      onToggleCompleted(value);
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          decoration: bundle.task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bundle.task.description.isEmpty
                            ? 'No description added.'
                            : bundle.task.description,
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bundle.task.category.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bundle.task.category,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Details',
                  icon: const Icon(Icons.info_outline),
                  onPressed: onOpenDetails,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(dateFormat.format(bundle.task.dueDate)),
                const Spacer(),
                if (bundle.task.repeatType != RepeatType.none)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bundle.task.repeatType == RepeatType.daily
                          ? 'Repeats daily'
                          : 'Repeats weekly',
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: bundle.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.secondary,
              backgroundColor: colorScheme.secondary.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress ${(bundle.progress * 100).round()}%',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
