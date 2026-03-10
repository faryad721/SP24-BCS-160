import 'dart:io';

import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../data/file_storage.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import 'patient_form_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.patient});

  final Patient patient;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Patient _patient;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FileStorage _storage = FileStorage();

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientFormScreen(patient: _patient),
      ),
    );
    if (updated == true) {
      final refreshed = await _db.getPatients();
      final match = refreshed.firstWhere(
        (item) => item.id == _patient.id,
        orElse: () => _patient,
      );
      if (!mounted) return;
      setState(() => _patient = match);
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: const Text(
            'This will permanently remove the patient data and files.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    await _storage.deleteFile(_patient.imagePath);
    await _storage.deleteFile(_patient.docPath);
    await _db.deletePatient(_patient.id!);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _delete,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _HeroCard(patient: _patient),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Patient Information'),
            const SizedBox(height: 12),
            _InfoTile(label: 'Age', value: '${_patient.age} years'),
            _InfoTile(label: 'Gender', value: _patient.gender),
            _InfoTile(
                label: 'Phone',
                value: _patient.phone.isEmpty ? 'Not provided' : _patient.phone),
            _InfoTile(
              label: 'Condition',
              value: _patient.condition.isEmpty
                  ? 'General Consultation'
                  : _patient.condition,
            ),
            _InfoTile(
              label: 'Last Visit',
              value: _patient.lastVisit.isEmpty
                  ? 'Not recorded'
                  : _patient.lastVisit,
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Clinical Notes'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Text(
                _patient.notes.isEmpty
                    ? 'No notes added yet.'
                    : _patient.notes,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Attached Files'),
            const SizedBox(height: 12),
            _FileTile(
              title: 'Photo',
              path: _patient.imagePath,
              icon: Icons.photo_rounded,
            ),
            const SizedBox(height: 10),
            _FileTile(
              title: 'Document',
              path: _patient.docPath,
              icon: Icons.description_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final hasImage = patient.imagePath != null && patient.imagePath!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.brand, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.2),
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(patient.imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(Icons.person_rounded,
                    size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  patient.condition.isEmpty
                      ? 'General Consultation'
                      : patient.condition,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.title,
    required this.path,
    required this.icon,
  });

  final String title;
  final String? path;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hasFile = path != null && path!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
            child: Icon(icon, color: AppTheme.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasFile
                  ? path!.split(Platform.pathSeparator).last
                  : '$title not uploaded',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: hasFile ? Colors.black87 : Colors.black45),
            ),
          ),
          if (hasFile)
            const Icon(Icons.check_circle_rounded, color: AppTheme.accent),
        ],
      ),
    );
  }
}
