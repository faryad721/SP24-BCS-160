import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/supabase_service.dart';
import 'dart:math';

class AppointmentProvider extends ChangeNotifier {
  final List<Appointment> _appointments = [];
  bool _loading = true;
  String? _error;

  List<Appointment> get appointments => List.unmodifiable(_appointments);
  bool get loading => _loading;
  String? get error => _error;

  List<Appointment> get upcoming => _appointments
      .where((a) => a.status == 'Upcoming')
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<Appointment> get completed =>
      _appointments.where((a) => a.status == 'Completed').toList();

  List<Appointment> get cancelled =>
      _appointments.where((a) => a.status == 'Cancelled').toList();

  AppointmentProvider() {
    _load();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await SupabaseService.getAppointments();
      _appointments..clear()..addAll(loaded);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Failed to load appointments: $e');
      // Load sample data as fallback when not connected
      if (_appointments.isEmpty) _loadSamples();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _loadSamples() {
    final now = DateTime.now();
    final doctors = Doctor.sampleDoctors;
    _appointments.addAll([
      Appointment(
        id: 'sample-a1',
        patientName: 'You',
        doctorId: doctors[0].id,
        doctorName: doctors[0].name,
        doctorSpecialty: doctors[0].specialty,
        date: _fmtDate(now.add(const Duration(days: 2))),
        time: '10:00 AM',
        type: 'Video Call',
        status: 'Upcoming',
        notes: 'Follow-up on medication and blood pressure check.',
        fee: doctors[0].consultationFee,
        createdAt: now.toIso8601String(),
      ),
      Appointment(
        id: 'sample-a2',
        patientName: 'You',
        doctorId: doctors[2].id,
        doctorName: doctors[2].name,
        doctorSpecialty: doctors[2].specialty,
        date: _fmtDate(now.subtract(const Duration(days: 5))),
        time: '11:00 AM',
        type: 'In-Person',
        status: 'Completed',
        notes: 'Annual wellness checkup.',
        fee: doctors[2].consultationFee,
        createdAt: now.subtract(const Duration(days: 7)).toIso8601String(),
      ),
    ]);
  }

  Future<void> bookAppointment({
    required Doctor doctor,
    required String date,
    required String time,
    required String type,
    required String notes,
    required String patientName,
  }) async {
    final data = {
      'patient_name': patientName,
      'doctor_id': null, // doctors table uses uuid; local sample ids won't match
      'doctor_name': doctor.name,
      'doctor_specialty': doctor.specialty,
      'date': date,
      'time': time,
      'type': type,
      'status': 'Upcoming',
      'notes': notes,
      'fee': doctor.consultationFee,
    };

    try {
      final appt = await SupabaseService.insertAppointment(data);
      _appointments.insert(0, appt);
    } catch (e) {
      // Offline fallback
      final id = '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}';
      _appointments.insert(0, Appointment(
        id: id,
        patientName: patientName,
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        date: date, time: time, type: type,
        status: 'Upcoming', notes: notes, fee: doctor.consultationFee,
        createdAt: DateTime.now().toIso8601String(),
      ));
      if (kDebugMode) print('Booked appointment offline: $e');
    }
    notifyListeners();
  }

  Future<void> cancelAppointment(String id) async {
    _updateLocalStatus(id, 'Cancelled');
    try {
      await SupabaseService.updateAppointmentStatus(id, 'Cancelled');
    } catch (e) {
      if (kDebugMode) print('Cancel appointment Supabase error: $e');
    }
  }

  Future<void> completeAppointment(String id) async {
    _updateLocalStatus(id, 'Completed');
    try {
      await SupabaseService.updateAppointmentStatus(id, 'Completed');
    } catch (e) {
      if (kDebugMode) print('Complete appointment Supabase error: $e');
    }
  }

  void _updateLocalStatus(String id, String status) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    _appointments[idx] = _appointments[idx].copyWith(status: status);
    notifyListeners();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
