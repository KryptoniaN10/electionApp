class PollSession {
  final int sessionId;
  final int electionId;
  final int machineId;
  final int grantedBy;
  final int? voterId;
  final String sessionToken;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus sessionStatus;
  final int? durationSeconds;
  final String? qrCodeHash;

  PollSession({
    required this.sessionId,
    required this.electionId,
    required this.machineId,
    required this.grantedBy,
    this.voterId,
    required this.sessionToken,
    required this.startTime,
    this.endTime,
    required this.sessionStatus,
    this.durationSeconds,
    this.qrCodeHash,
  });

  factory PollSession.fromJson(Map<String, dynamic> json) {
    return PollSession(
      sessionId: json['session_id'],
      electionId: json['election_id'],
      machineId: json['machine_id'],
      grantedBy: json['granted_by'],
      voterId: json['voter_id'],
      sessionToken: json['session_token'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      sessionStatus: SessionStatus.fromString(json['session_status']),
      durationSeconds: json['duration_seconds'],
      qrCodeHash: json['qr_code_hash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'election_id': electionId,
      'machine_id': machineId,
      'granted_by': grantedBy,
      'voter_id': voterId,
      'session_token': sessionToken,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'session_status': sessionStatus.toString().split('.').last,
      'duration_seconds': durationSeconds,
      'qr_code_hash': qrCodeHash,
    };
  }
}

enum SessionStatus {
  pending,
  active,
  completed,
  expired;

  static SessionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return SessionStatus.pending;
      case 'active':
        return SessionStatus.active;
      case 'completed':
        return SessionStatus.completed;
      case 'expired':
        return SessionStatus.expired;
      default:
        return SessionStatus.pending;
    }
  }
}