import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import '../data/file_storage.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key, this.patient});

  final Patient? patient;

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _conditionController = TextEditingController();
  final _notesController = TextEditingController();
  final _lastVisitController = TextEditingController();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final FileStorage _storage = FileStorage();

  final List<String> _genders = const ['Male', 'Female', 'Other'];
  String _gender = 'Male';

  File? _imageFile;
  File? _docFile;
  bool _removeImage = false;
  bool _removeDoc = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    if (patient != null) {
      _nameController.text = patient.name;
      _ageController.text = patient.age.toString();
      _phoneController.text = patient.phone;
      _conditionController.text = patient.condition;
      _notesController.text = patient.notes;
      _lastVisitController.text = patient.lastVisit;
      _gender = patient.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    _notesController.dispose();
    _lastVisitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _removeImage = false;
    });
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() {
      _docFile = File(result.files.single.path!);
      _removeDoc = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = widget.patient != null && widget.patient!.lastVisit.isNotEmpty
        ? DateFormat('dd MMM yyyy').parse(widget.patient!.lastVisit)
        : now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;
    setState(() {
      _lastVisitController.text = DateFormat('dd MMM yyyy').format(date);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final basePatient = Patient(
        id: widget.patient?.id,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _gender,
        phone: _phoneController.text.trim(),
        condition: _conditionController.text.trim(),
        notes: _notesController.text.trim(),
        lastVisit: _lastVisitController.text.trim(),
        imagePath: widget.patient?.imagePath,
        docPath: widget.patient?.docPath,
      );

      final isNew = widget.patient == null;
      int patientId = widget.patient?.id ?? 0;
      String? imagePath = basePatient.imagePath;
      String? docPath = basePatient.docPath;

      if (isNew) {
        patientId = await _db.insertPatient(
          basePatient.copyWith(imagePath: null, docPath: null),
        );
      } else {
        if (_removeImage) {
          await _storage.deleteFile(imagePath);
          imagePath = null;
        }
        if (_removeDoc) {
          await _storage.deleteFile(docPath);
          docPath = null;
        }
      }

      if (_imageFile != null) {
        await _storage.deleteFile(imagePath);
        imagePath = await _storage.savePatientFile(
          patientId: patientId,
          source: _imageFile!,
          prefix: 'image',
        );
      }

      if (_docFile != null) {
        await _storage.deleteFile(docPath);
        docPath = await _storage.savePatientFile(
          patientId: patientId,
          source: _docFile!,
          prefix: 'doc',
        );
      }

      final updatedPatient = basePatient.copyWith(
        id: patientId,
        imagePath: imagePath,
        docPath: docPath,
      );

      await _db.updatePatient(updatedPatient);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $error'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingImage = widget.patient?.imagePath;
    final existingDoc = widget.patient?.docPath;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'New Patient' : 'Edit Patient'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_saving ? 'Saving...' : 'Save Record'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.brand,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Patient Details'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Age required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        items: _genders
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _gender = value);
                        },
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _conditionController,
                  decoration: const InputDecoration(labelText: 'Condition'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _lastVisitController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Last Visit',
                    suffixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Documents & Images'),
                const SizedBox(height: 12),
                _FileSection(
                  title: 'Patient Photo',
                  subtitle: 'Upload a profile or clinical image',
                  fileLabel: _imageFile?.path.split(Platform.pathSeparator).last ??
                      (existingImage?.split(Platform.pathSeparator).last ?? ''),
                  onPick: _pickImage,
                  onRemove: (_imageFile != null || existingImage != null)
                      ? () {
                          setState(() {
                            _imageFile = null;
                            _removeImage = true;
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 14),
                _FileSection(
                  title: 'Medical Document',
                  subtitle: 'Upload reports, prescriptions, or scans',
                  fileLabel: _docFile?.path.split(Platform.pathSeparator).last ??
                      (existingDoc?.split(Platform.pathSeparator).last ?? ''),
                  onPick: _pickDocument,
                  onRemove: (_docFile != null || existingDoc != null)
                      ? () {
                          setState(() {
                            _docFile = null;
                            _removeDoc = true;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FileSection extends StatelessWidget {
  const _FileSection({
    required this.title,
    required this.subtitle,
    required this.fileLabel,
    required this.onPick,
    this.onRemove,
  });

  final String title;
  final String subtitle;
  final String fileLabel;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileLabel.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasFile ? fileLabel : 'No file selected',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: hasFile ? Colors.black87 : Colors.black45),
                ),
              ),
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(hasFile ? 'Replace' : 'Upload'),
              ),
              if (onRemove != null)
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Remove'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
