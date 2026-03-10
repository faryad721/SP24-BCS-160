import 'dart:io';

import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../theme/app_theme.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.index,
  });

  final Patient patient;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 30)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Avatar(imagePath: patient.imagePath),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppTheme.dark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${patient.condition.isEmpty ? 'General Consultation' : patient.condition} • ${patient.age} yrs',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        patient.lastVisit.isEmpty
                            ? 'No visit recorded'
                            : 'Last visit: ${patient.lastVisit}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        image: imagePath == null || imagePath!.isEmpty
            ? null
            : DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              ),
      ),
      child: (imagePath == null || imagePath!.isEmpty)
          ? const Icon(Icons.person_rounded, color: AppTheme.brand)
          : null,
    );
  }
}
