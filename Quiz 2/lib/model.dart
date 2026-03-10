class User {

  int? id;
  String name;
  String email;
  String age;
  String image;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.image,
  });

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'image': image,
    };

  }

  factory User.fromMap(Map<String, dynamic> map) {

    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      image: map['image'],
    );

  }

}