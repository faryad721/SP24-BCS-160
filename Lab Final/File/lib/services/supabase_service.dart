import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/patient.dart';
import '../models/patient_document.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/message.dart';

/// Central service for all Supabase database operations.
/// Every table operation goes through this class.
class SupabaseService {
  static SupabaseClient get _db => SupabaseConfig.client;

  static String? get _uid => _db.auth.currentUser?.id;

  // ─── PATIENTS ───────────────────────────────────────────────────────────────

  static Future<List<Patient>> getPatients() async {
    final uid = _uid;
    if (uid == null) return [];
    final res = await _db
        .from('patients')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (res as List).map((r) => Patient.fromSupabase(r)).toList();
  }

  static Future<Patient> insertPatient(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    final row = {
      ...data,
      'user_id': uid,
    };
    final res = await _db.from('patients').insert(row).select().single();
    return Patient.fromSupabase(res);
  }

  static Future<void> updatePatient(String id, Map<String, dynamic> data) async {
    await _db.from('patients').update(data).eq('id', id);
  }

  static Future<void> deletePatient(String id) async {
    await _db.from('patients').delete().eq('id', id);
  }

  // ─── PATIENT DOCUMENTS ───────────────────────────────────────────────────────

  static Future<List<PatientDocument>> getDocuments(String patientId) async {
    final uid = _uid;
    if (uid == null) return [];
    final res = await _db
        .from('patient_documents')
        .select()
        .eq('patient_id', patientId)
        .eq('user_id', uid)
        .order('added_at', ascending: false);
    return (res as List).map((r) => PatientDocument.fromSupabase(r)).toList();
  }

  static Future<PatientDocument> insertDocument(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    final row = {...data, 'user_id': uid};
    final res =
        await _db.from('patient_documents').insert(row).select().single();
    return PatientDocument.fromSupabase(res);
  }

  static Future<void> deleteDocument(String id) async {
    await _db.from('patient_documents').delete().eq('id', id);
  }

  // ─── DOCTORS ────────────────────────────────────────────────────────────────

  static Future<List<Doctor>> getDoctors() async {
    final res = await _db
        .from('doctors')
        .select()
        .order('rating', ascending: false);
    return (res as List).map((r) => Doctor.fromSupabase(r)).toList();
  }

  // ─── APPOINTMENTS ────────────────────────────────────────────────────────────

  static Future<List<Appointment>> getAppointments() async {
    final uid = _uid;
    if (uid == null) return [];
    final res = await _db
        .from('appointments')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: true);
    return (res as List).map((r) => Appointment.fromSupabase(r)).toList();
  }

  static Future<Appointment> insertAppointment(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    final row = {...data, 'user_id': uid};
    final res =
        await _db.from('appointments').insert(row).select().single();
    return Appointment.fromSupabase(res);
  }

  static Future<void> updateAppointmentStatus(
      String id, String status) async {
    await _db.from('appointments').update({'status': status}).eq('id', id);
  }

  static Future<void> deleteAppointment(String id) async {
    await _db.from('appointments').delete().eq('id', id);
  }

  // ─── MESSAGES ───────────────────────────────────────────────────────────────

  static Future<List<ChatMessage>> getMessages({
    required String myId,
    required String otherId,
  }) async {
    final res = await _db
        .from('messages')
        .select()
        .or('and(sender_id.eq.$myId,receiver_id.eq.$otherId),and(sender_id.eq.$otherId,receiver_id.eq.$myId)')
        .order('created_at', ascending: true);
    return (res as List).map((r) => ChatMessage.fromSupabase(r)).toList();
  }

  static Future<ChatMessage> sendMessage(Map<String, dynamic> data) async {
    final res = await _db.from('messages').insert(data).select().single();
    return ChatMessage.fromSupabase(res);
  }

  static Future<void> markMessagesRead({
    required String myId,
    required String senderId,
  }) async {
    await _db
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', myId)
        .eq('sender_id', senderId)
        .eq('is_read', false);
  }

  /// Subscribe to new messages in a conversation (Supabase Realtime).
  static RealtimeChannel subscribeToMessages({
    required String myId,
    required String otherId,
    required void Function(ChatMessage) onMessage,
  }) {
    return _db
        .channel('messages_${myId}_$otherId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final msg = ChatMessage.fromSupabase(payload.newRecord);
            if ((msg.senderId == myId && msg.receiverId == otherId) ||
                (msg.senderId == otherId && msg.receiverId == myId)) {
              onMessage(msg);
            }
          },
        )
        .subscribe();
  }
}
