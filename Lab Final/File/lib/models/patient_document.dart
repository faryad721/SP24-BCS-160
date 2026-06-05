class PatientDocument {
  PatientDocument({
    required this.id,
    required this.patientId,
    required this.name,
    required this.type,
    required this.path,
    required this.size,
    required this.addedAt,
  });

  final String id;
  final String patientId;
  final String name;
  final String type;
  final String path;
  final int size;
  final String addedAt;

  PatientDocument copyWith({
    String? name, String? type, String? path, int? size, String? addedAt,
  }) {
    return PatientDocument(
      id: id, patientId: patientId,
      name: name ?? this.name, type: type ?? this.type,
      path: path ?? this.path, size: size ?? this.size,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory PatientDocument.fromSupabase(Map<String, dynamic> m) =>
      PatientDocument(
        id: (m['id'] ?? '') as String,
        patientId: (m['patient_id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? '') as String,
        path: (m['path'] ?? '') as String,
        size: (m['size'] ?? 0) as int,
        addedAt: (m['added_at'] ?? '') as String,
      );

  Map<String, dynamic> toSupabase() => {
        'patient_id': patientId,
        'name': name,
        'type': type,
        'path': path,
        'size': size,
      };

  factory PatientDocument.fromMap(Map<String, dynamic> map) =>
      PatientDocument(
        id: map['id'] as String,
        patientId: map['patientId'] as String,
        name: (map['name'] ?? '') as String,
        type: (map['type'] ?? '') as String,
        path: (map['path'] ?? '') as String,
        size: (map['size'] ?? 0) as int,
        addedAt: (map['addedAt'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'patientId': patientId, 'name': name,
        'type': type, 'path': path, 'size': size, 'addedAt': addedAt,
      };
}
