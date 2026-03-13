class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'instructor'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'role': role};
  }

  bool get isInstructor => role == 'instructor';
  bool get isStudent => role == 'student';
}
