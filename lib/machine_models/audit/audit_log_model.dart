class AuditLog {
  final int entryId;
  final int userId;
  final String action;
  final int? electionId;
  final String details;
  final String ipAddress;
  final DateTime timestamp;
  final String logHash;
  final AuditSeverity severity;

  AuditLog({
    required this.entryId,
    required this.userId,
    required this.action,
    this.electionId,
    required this.details,
    required this.ipAddress,
    required this.timestamp,
    required this.logHash,
    required this.severity,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      entryId: json['entry_id'],
      userId: json['user_id'],
      action: json['action'],
      electionId: json['election_id'],
      details: json['details'],
      ipAddress: json['ip_address'],
      timestamp: DateTime.parse(json['timestamp']),
      logHash: json['log_hash'],
      severity: AuditSeverity.fromString(json['severity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'user_id': userId,
      'action': action,
      'election_id': electionId,
      'details': details,
      'ip_address': ipAddress,
      'timestamp': timestamp.toIso8601String(),
      'log_hash': logHash,
      'severity': severity.toString().split('.').last,
    };
  }
}

enum AuditSeverity {
  info,
  warning,
  error,
  critical;

  static AuditSeverity fromString(String value) {
    switch (value) {
      case 'info':
        return AuditSeverity.info;
      case 'warning':
        return AuditSeverity.warning;
      case 'error':
        return AuditSeverity.error;
      case 'critical':
        return AuditSeverity.critical;
      default:
        return AuditSeverity.info;
    }
  }
}