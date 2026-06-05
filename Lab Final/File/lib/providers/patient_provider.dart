import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../models/patient_document.dart';
import '../services/supabase_service.dart';
import '../utils/file_storage.dart';

class PatientProvider extends ChangeNotifier {
  PatientProvider() {
    _init();
  }

  final List<Patient> _patients = [];
  final List<PatientDocument> _documents = [];
  bool _loading = true;
  String? _error;

  List<Patient> get patients => List.unmodifiable(_patients);
  List<PatientDocument> get documents => List.unmodifiable(_documents);
  bool get loading => _loading;
  String? get error => _error;

  Patient? getPatient(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PatientDocument> documentsFor(String patientId) =>
      _documents.where((d) => d.patientId == patientId).toList();

  Future<void> _init() async {
    await _loadPatients();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await _loadPatients();
  }

  Future<Patient> addPatient(Map<String, String> data) async {
    final now = DateTime.now().toIso8601String();
    final supabaseData = {
      'name': data['name'] ?? '',
      'age': data['age'] ?? '',
      'phone': data['phone'] ?? '',
      'email': data['email'] ?? '',
      'diagnosis': data['diagnosis'] ?? '',
      'notes': data['notes'] ?? '',
      'blood_type': data['bloodType'] ?? '',
      'gender': data['gender'] ?? '',
      'address': data['address'] ?? '',
      'image_uri': data['imageUri'] ?? '',
      'allergies': data['allergies'] ?? '',
      'medications': data['medications'] ?? '',
      'emergency_contact': data['emergencyContact'] ?? '',
      'emergency_phone': data['emergencyPhone'] ?? '',
      'weight': data['weight'] ?? '',
      'height': data['height'] ?? '',
      'status': data['status'] ?? 'Active',
      'appointment_date': data['appointmentDate'] ?? '',
    };

    try {
      final patient = await SupabaseService.insertPatient(supabaseData);
      _patients.insert(0, patient);
      notifyListeners();
      return patient;
    } catch (e) {
      // Offline fallback — create local record
      final id = '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999999)}';
      final patient = Patient(
        id: id, name: data['name'] ?? '', age: data['age'] ?? '',
        phone: data['phone'] ?? '', email: data['email'] ?? '',
        diagnosis: data['diagnosis'] ?? '', notes: data['notes'] ?? '',
        bloodType: data['bloodType'] ?? '', gender: data['gender'] ?? '',
        address: data['address'] ?? '', imageUri: data['imageUri'] ?? '',
        allergies: data['allergies'] ?? '', medications: data['medications'] ?? '',
        emergencyContact: data['emergencyContact'] ?? '',
        emergencyPhone: data['emergencyPhone'] ?? '',
        weight: data['weight'] ?? '', height: data['height'] ?? '',
        status: data['status'] ?? 'Active',
        appointmentDate: data['appointmentDate'] ?? '',
        createdAt: now, updatedAt: now,
      );
      _patients.insert(0, patient);
      notifyListeners();
      return patient;
    }
  }

  Future<void> updatePatient(String id, Map<String, String> data) async {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final supabaseData = {
      'name': data['name'], 'age': data['age'], 'phone': data['phone'],
      'email': data['email'], 'diagnosis': data['diagnosis'],
      'notes': data['notes'], 'blood_type': data['bloodType'],
      'gender': data['gender'], 'address': data['address'],
      'image_uri': data['imageUri'], 'allergies': data['allergies'],
      'medications': data['medications'],
      'emergency_contact': data['emergencyContact'],
      'emergency_phone': data['emergencyPhone'],
      'weight': data['weight'], 'height': data['height'],
      'status': data['status'], 'appointment_date': data['appointmentDate'],
    };

    final updated = _patients[index].copyWith(
      name: data['name'], age: data['age'], phone: data['phone'],
      email: data['email'], diagnosis: data['diagnosis'], notes: data['notes'],
      bloodType: data['bloodType'], gender: data['gender'],
      address: data['address'], imageUri: data['imageUri'],
      allergies: data['allergies'], medications: data['medications'],
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
      weight: data['weight'], height: data['height'],
      status: data['status'], appointmentDate: data['appointmentDate'],
      updatedAt: DateTime.now().toIso8601String(),
    );

    _patients[index] = updated;
    notifyListeners();

    try {
      await SupabaseService.updatePatient(id, supabaseData);
    } catch (e) {
      if (kDebugMode) print('Supabase updatePatient error: $e');
    }
  }

  Future<void> deletePatient(String id) async {
    final patient = getPatient(id);
    final docsToDelete = _documents.where((d) => d.patientId == id).toList();
    _patients.removeWhere((p) => p.id == id);
    _documents.removeWhere((d) => d.patientId == id);
    notifyListeners();

    if (patient != null) {
      await FileStorage.deleteIfExists(patient.imageUri);
    }
    for (final doc in docsToDelete) {
      await FileStorage.deleteIfExists(doc.path);
    }

    try {
      await SupabaseService.deletePatient(id);
    } catch (e) {
      if (kDebugMode) print('Supabase deletePatient error: $e');
    }
  }

  Future<void> addDocument({
    required String patientId,
    required String name,
    required String type,
    required String path,
    required int size,
  }) async {
    try {
      final doc = await SupabaseService.insertDocument({
        'patient_id': patientId,
        'name': name,
        'type': type,
        'path': path,
        'size': size,
      });
      _documents.insert(0, doc);
    } catch (e) {
      final now = DateTime.now().toIso8601String();
      final id = '${DateTime.now().millisecondsSinceEpoch}';
      _documents.insert(0, PatientDocument(
        id: id, patientId: patientId, name: name,
        type: type, path: path, size: size, addedAt: now,
      ));
    }
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    final idx = _documents.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    final doc = _documents[idx];
    _documents.removeAt(idx);
    notifyListeners();
    await FileStorage.deleteIfExists(doc.path);
    try {
      await SupabaseService.deleteDocument(id);
    } catch (e) {
      if (kDebugMode) print('Supabase deleteDocument error: $e');
    }
  }

  Future<void> _loadPatients() async {
    try {
      final loaded = await SupabaseService.getPatients();
      _patients..clear()..addAll(loaded);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Failed to load patients from Supabase: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
