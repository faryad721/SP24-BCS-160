class Appointment {
  Appointment({
    required this.id,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.notes,
    required this.fee,
    required this.createdAt,
  });

  final String id;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String date;
  final String time;
  final String type;
  final String status;
  final String notes;
  final double fee;
  final String createdAt;

  static const List<String> types = ['In-Person', 'Video Call', 'Phone Call'];
  static const List<String> statuses = ['Upcoming', 'Completed', 'Cancelled'];

  static const Map<String, Map<String, dynamic>> statusConfig = {
    'Upcoming':  {'color': 0xFF1565C0, 'bg': 0xFFE3F2FD},
    'Completed': {'color': 0xFF2E7D32, 'bg': 0xFFE8F5E9},
    'Cancelled': {'color': 0xFFB71C1C, 'bg': 0xFFFFEBEE},
  };

  factory Appointment.fromSupabase(Map<String, dynamic> m) => Appointment(
        id: (m['id'] ?? '') as String,
        patientName: (m['patient_name'] ?? '') as String,
        doctorId: (m['doctor_id'] ?? '') as String,
        doctorName: (m['doctor_name'] ?? '') as String,
        doctorSpecialty: (m['doctor_specialty'] ?? '') as String,
        date: m['date']?.toString() ?? '',
        time: (m['time'] ?? '') as String,
        type: (m['type'] ?? 'In-Person') as String,
        status: (m['status'] ?? 'Upcoming') as String,
        notes: (m['notes'] ?? '') as String,
        fee: ((m['fee'] ?? 0) as num).toDouble(),
        createdAt: (m['created_at'] ?? '') as String,
      );

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      Appointment.fromSupabase(json);

  Map<String, dynamic> toSupabase() => {
        'patient_name': patientName,
        'doctor_id': doctorId.isEmpty ? null : doctorId,
        'doctor_name': doctorName,
        'doctor_specialty': doctorSpecialty,
        'date': date,
        'time': time,
        'type': type,
        'status': status,
        'notes': notes,
        'fee': fee,
      };

  Appointment copyWith({String? status}) => Appointment(
        id: id, patientName: patientName, doctorId: doctorId,
        doctorName: doctorName, doctorSpecialty: doctorSpecialty,
        date: date, time: time, type: type,
        status: status ?? this.status,
        notes: notes, fee: fee, createdAt: createdAt,
      );
}
