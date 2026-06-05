class Doctor {
  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.bio,
    required this.availableDays,
    required this.consultationFee,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String phone;
  final String email;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int experience;
  final String bio;
  final List<String> availableDays;
  final double consultationFee;
  final bool isOnline;

  factory Doctor.fromSupabase(Map<String, dynamic> m) => Doctor(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        specialty: (m['specialty'] ?? '') as String,
        hospital: (m['hospital'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        imageUrl: (m['image_url'] ?? '') as String,
        rating: ((m['rating'] ?? 4.5) as num).toDouble(),
        reviewCount: (m['review_count'] ?? 0) as int,
        experience: (m['experience'] ?? 0) as int,
        bio: (m['bio'] ?? '') as String,
        availableDays: List<String>.from(m['available_days'] ?? []),
        consultationFee: ((m['consultation_fee'] ?? 0) as num).toDouble(),
        isOnline: (m['is_online'] ?? false) as bool,
      );

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor.fromSupabase(json);

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'specialty': specialty, 'hospital': hospital,
        'phone': phone, 'email': email, 'image_url': imageUrl,
        'rating': rating, 'review_count': reviewCount, 'experience': experience,
        'bio': bio, 'available_days': availableDays,
        'consultation_fee': consultationFee, 'is_online': isOnline,
      };

  static List<Doctor> get sampleDoctors => [
        Doctor(id: 'd1', name: 'Dr. Sarah Ahmed',  specialty: 'Cardiologist',       hospital: 'City Heart Center',       phone: '+1-555-0101', email: 'sarah.ahmed@cityheart.com',    imageUrl: '', rating: 4.9, reviewCount: 312, experience: 14, bio: 'Board-certified cardiologist specializing in preventive cardiology and heart failure management.',            availableDays: ['Mon','Wed','Fri'],            consultationFee: 150.0, isOnline: true),
        Doctor(id: 'd2', name: 'Dr. James Wilson', specialty: 'Neurologist',        hospital: 'NeuroHealth Institute',   phone: '+1-555-0102', email: 'james.wilson@neuroinst.com',  imageUrl: '', rating: 4.7, reviewCount: 198, experience: 11, bio: 'Expert in movement disorders, epilepsy, and neurodegenerative diseases.',                                   availableDays: ['Tue','Thu','Sat'],            consultationFee: 180.0, isOnline: false),
        Doctor(id: 'd3', name: 'Dr. Maria Santos', specialty: 'Pediatrician',       hospital: 'Kids Wellness Clinic',    phone: '+1-555-0103', email: 'maria.santos@kidswellness.com',imageUrl: '', rating: 4.8, reviewCount: 425, experience: 9,  bio: 'Dedicated to children\'s health from newborns through adolescence.',                                          availableDays: ['Mon','Tue','Wed','Thu','Fri'],consultationFee: 120.0, isOnline: true),
        Doctor(id: 'd4', name: 'Dr. Robert Chen',  specialty: 'Orthopedic Surgeon', hospital: 'Bone & Joint Center',     phone: '+1-555-0104', email: 'robert.chen@boneandjoint.com', imageUrl: '', rating: 4.6, reviewCount: 267, experience: 16, bio: 'Specializing in minimally invasive joint replacement and sports medicine.',                                    availableDays: ['Mon','Wed','Fri'],            consultationFee: 200.0, isOnline: false),
        Doctor(id: 'd5', name: 'Dr. Aisha Patel',  specialty: 'Dermatologist',      hospital: 'SkinCare Medical Center', phone: '+1-555-0105', email: 'aisha.patel@skincare.com',    imageUrl: '', rating: 4.9, reviewCount: 511, experience: 8,  bio: 'Expert in medical and cosmetic dermatology, including skin cancer screening and laser treatments.',            availableDays: ['Tue','Thu','Fri','Sat'],      consultationFee: 130.0, isOnline: true),
      ];
}
