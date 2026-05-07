class Submission {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime? createdAt;

  Submission({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.createdAt,
  });

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      gender: map['gender'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
    };
  }
}
