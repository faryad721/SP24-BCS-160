class Patient {
  const Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.condition,
    required this.notes,
    required this.lastVisit,
    this.imagePath,
    this.docPath,
  });

  final int? id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String condition;
  final String notes;
  final String lastVisit;
  final String? imagePath;
  final String? docPath;

  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? condition,
    String? notes,
    String? lastVisit,
    String? imagePath,
    String? docPath,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      lastVisit: lastVisit ?? this.lastVisit,
      imagePath: imagePath ?? this.imagePath,
      docPath: docPath ?? this.docPath,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'condition': condition,
      'notes': notes,
      'last_visit': lastVisit,
      'image_path': imagePath,
      'doc_path': docPath,
    };
  }

  static Patient fromMap(Map<String, Object?> map) {
    return Patient(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      age: (map['age'] as int?) ?? 0,
      gender: (map['gender'] as String?) ?? 'Unknown',
      phone: (map['phone'] as String?) ?? '',
      condition: (map['condition'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      lastVisit: (map['last_visit'] as String?) ?? '',
      imagePath: map['image_path'] as String?,
      docPath: map['doc_path'] as String?,
    );
  }
}
