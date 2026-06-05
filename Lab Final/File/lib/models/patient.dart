class Patient {
  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.email,
    required this.diagnosis,
    required this.notes,
    required this.bloodType,
    required this.gender,
    required this.address,
    required this.imageUri,
    required this.allergies,
    required this.medications,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.weight,
    required this.height,
    required this.status,
    required this.appointmentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String age;
  final String phone;
  final String email;
  final String diagnosis;
  final String notes;
  final String bloodType;
  final String gender;
  final String address;
  final String imageUri;
  final String allergies;
  final String medications;
  final String emergencyContact;
  final String emergencyPhone;
  final String weight;
  final String height;
  final String status;
  final String appointmentDate;
  final String createdAt;
  final String updatedAt;

  Patient copyWith({
    String? name, String? age, String? phone, String? email,
    String? diagnosis, String? notes, String? bloodType, String? gender,
    String? address, String? imageUri, String? allergies, String? medications,
    String? emergencyContact, String? emergencyPhone, String? weight,
    String? height, String? status, String? appointmentDate,
    String? createdAt, String? updatedAt,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name, age: age ?? this.age,
      phone: phone ?? this.phone, email: email ?? this.email,
      diagnosis: diagnosis ?? this.diagnosis, notes: notes ?? this.notes,
      bloodType: bloodType ?? this.bloodType, gender: gender ?? this.gender,
      address: address ?? this.address, imageUri: imageUri ?? this.imageUri,
      allergies: allergies ?? this.allergies, medications: medications ?? this.medications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      weight: weight ?? this.weight, height: height ?? this.height,
      status: status ?? this.status, appointmentDate: appointmentDate ?? this.appointmentDate,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ─── Supabase (snake_case columns) ────────────────────────────────────────
  factory Patient.fromSupabase(Map<String, dynamic> m) => Patient(
    id: (m['id'] ?? '') as String,
    name: (m['name'] ?? '') as String,
    age: (m['age'] ?? '') as String,
    phone: (m['phone'] ?? '') as String,
    email: (m['email'] ?? '') as String,
    diagnosis: (m['diagnosis'] ?? '') as String,
    notes: (m['notes'] ?? '') as String,
    bloodType: (m['blood_type'] ?? '') as String,
    gender: (m['gender'] ?? '') as String,
    address: (m['address'] ?? '') as String,
    imageUri: (m['image_uri'] ?? '') as String,
    allergies: (m['allergies'] ?? '') as String,
    medications: (m['medications'] ?? '') as String,
    emergencyContact: (m['emergency_contact'] ?? '') as String,
    emergencyPhone: (m['emergency_phone'] ?? '') as String,
    weight: (m['weight'] ?? '') as String,
    height: (m['height'] ?? '') as String,
    status: (m['status'] ?? 'Active') as String,
    appointmentDate: (m['appointment_date'] ?? '') as String,
    createdAt: (m['created_at'] ?? '') as String,
    updatedAt: (m['updated_at'] ?? '') as String,
  );

  Map<String, dynamic> toSupabase() => {
    'name': name, 'age': age, 'phone': phone, 'email': email,
    'diagnosis': diagnosis, 'notes': notes, 'blood_type': bloodType,
    'gender': gender, 'address': address, 'image_uri': imageUri,
    'allergies': allergies, 'medications': medications,
    'emergency_contact': emergencyContact, 'emergency_phone': emergencyPhone,
    'weight': weight, 'height': height, 'status': status,
    'appointment_date': appointmentDate,
  };

  // ─── Legacy local DB (camelCase) ─────────────────────────────────────────
  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
    id: map['id'] as String,
    name: (map['name'] ?? '') as String, age: (map['age'] ?? '') as String,
    phone: (map['phone'] ?? '') as String, email: (map['email'] ?? '') as String,
    diagnosis: (map['diagnosis'] ?? '') as String, notes: (map['notes'] ?? '') as String,
    bloodType: (map['bloodType'] ?? '') as String, gender: (map['gender'] ?? '') as String,
    address: (map['address'] ?? '') as String, imageUri: (map['imageUri'] ?? '') as String,
    allergies: (map['allergies'] ?? '') as String, medications: (map['medications'] ?? '') as String,
    emergencyContact: (map['emergencyContact'] ?? '') as String,
    emergencyPhone: (map['emergencyPhone'] ?? '') as String,
    weight: (map['weight'] ?? '') as String, height: (map['height'] ?? '') as String,
    status: (map['status'] ?? 'Active') as String,
    appointmentDate: (map['appointmentDate'] ?? '') as String,
    createdAt: (map['createdAt'] ?? '') as String,
    updatedAt: (map['updatedAt'] ?? '') as String,
  );

  factory Patient.fromJson(Map<String, dynamic> json) => Patient.fromMap(json);
  Map<String, dynamic> toMap() => toSupabase()
    ..addAll({'id': id, 'createdAt': createdAt, 'updatedAt': updatedAt});
  Map<String, dynamic> toJson() => toMap();
}
