class Session {
  final String sessionToken;
  final int userId;
  final int machineId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isValid;

  Session({
    required this.sessionToken,
    required this.userId,
    required this.machineId,
    required this.createdAt,
    required this.expiresAt,
    required this.isValid,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionToken: json['session_token'],
      userId: json['user_id'],
      machineId: json['machine_id'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isValid: json['is_valid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_token': sessionToken,
      'user_id': userId,
      'machine_id': machineId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_valid': isValid,
    };
  }
}