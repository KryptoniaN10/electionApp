class UserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final int? classId;
  final String role; // student, officer, admin
  final String? studentId;
  final String urlOfPhoto;
  final String? house;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.classId,
    required this.role,
    this.studentId,
    required this.urlOfPhoto,
    this.house,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      classId: json['class_id'],
      role: json['role'] ?? 'student',
      studentId: json['student_id'],
      urlOfPhoto: json['photoUrl'],
      house: json['house'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'class_id': classId,
      'role': role,
      'student_id': studentId,
      'photoUrl': urlOfPhoto,
      'house': house,
      'is_active': isActive,
    };
  }

  // Helper for full name
  String get fullName => '$firstName $lastName';
}