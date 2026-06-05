import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import '../services/supabase_service.dart';

class DoctorsProvider extends ChangeNotifier {
  final List<Doctor> _doctors = [];
  bool _loading = true;
  String? _error;

  List<Doctor> get doctors =>
      _doctors.isEmpty ? Doctor.sampleDoctors : List.unmodifiable(_doctors);
  bool get loading => _loading;
  String? get error => _error;

  DoctorsProvider() {
    _load();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await SupabaseService.getDoctors();
      if (loaded.isNotEmpty) {
        _doctors..clear()..addAll(loaded);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Failed to load doctors from Supabase: $e');
      // Falls back to Doctor.sampleDoctors via getter above
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
