class VoteBackup {
  final int backupId;
  final int voteId;
  final Map<String, dynamic> voteData;
  final DateTime backupTimestamp;
  final String backupSource;
  final BackupStatus recoveryStatus;

  VoteBackup({
    required this.backupId,
    required this.voteId,
    required this.voteData,
    required this.backupTimestamp,
    required this.backupSource,
    required this.recoveryStatus,
  });

  factory VoteBackup.fromJson(Map<String, dynamic> json) {
    return VoteBackup(
      backupId: json['backup_id'],
      voteId: json['vote_id'],
      voteData: json['vote_data'],
      backupTimestamp: DateTime.parse(json['backup_timestamp']),
      backupSource: json['backup_source'],
      recoveryStatus: BackupStatus.fromString(json['recovery_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backup_id': backupId,
      'vote_id': voteId,
      'vote_data': voteData,
      'backup_timestamp': backupTimestamp.toIso8601String(),
      'backup_source': backupSource,
      'recovery_status': recoveryStatus.toString().split('.').last,
    };
  }
}

enum BackupStatus {
  pending,
  restored,
  failed;

  static BackupStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return BackupStatus.pending;
      case 'restored':
        return BackupStatus.restored;
      case 'failed':
        return BackupStatus.failed;
      default:
        return BackupStatus.pending;
    }
  }
}