class User {
  final int userId;
  final String firstName;
  final String lastName;
  final int? classId;
  final UserRole role;
  final String? studentId;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.classId,
    required this.role,
    this.studentId,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      classId: json['class_id'],
      role: UserRole.fromString(json['role']),
      studentId: json['student_id'],
      email: json['email'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'class_id': classId,
      'role': role.toString().split('.').last,
      'student_id': studentId,
      'email': email,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum UserRole {
  admin,
  officer,
  student;

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'officer':
        return UserRole.officer;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }
}