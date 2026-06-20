class StudentImportModel {
  final String firstName;
  final String lastName;
  final String? studentId;
  final int? classId;
  final String? email;
  final String? house;
  final String role;

  StudentImportModel({
    required this.firstName,
    required this.lastName,
    this.studentId,
    this.classId,
    this.email,
    this.house,
    this.role = 'student',
  });

  factory StudentImportModel.fromMap(Map<String, dynamic> map) {
    return StudentImportModel(
      firstName: map['first_name'] ?? map['firstName'] ?? '',
      lastName: map['last_name'] ?? map['lastName'] ?? '',
      studentId: map['student_id'] ?? map['studentId'],
      classId: map['class_id'] ?? map['classId'],
      email: map['email'],
      house: map['house'],
      role: map['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'student_id': studentId,
      'class_id': classId,
      'email': email,
      'house': house,
      'role': role,
    };
  }
}