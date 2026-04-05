import 'package:flutter/material.dart';

class RepeatChip extends StatelessWidget {
  const RepeatChip({
    super.key,
    required this.day,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final String label;
  final bool selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: colorScheme.secondary.withOpacity(0.2),
      onSelected: (_) => onTap(day),
    );
  }
}
