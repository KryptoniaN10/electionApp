import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../machine_models/audit/audit_log_model.dart';
import '../machine_models/audit/vote_backup_model.dart';

/// Hive service for local NoSQL storage.
/// Boxes: 'vote_backups', 'audit_logs'
///
/// IMPORTANT: Call [init()] once in main.dart before runApp():
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await LocalBackupService.getInstance().init();
///   runApp(const MyApp());
/// }
/// ```
class LocalBackupService {
  static const String _voteBoxName = 'vote_backups';
  static const String _auditBoxName = 'audit_logs';

  static LocalBackupService? _instance;
  bool _isInitialized = false;

  Box<Map<dynamic, dynamic>>? _voteBox;
  Box<Map<dynamic, dynamic>>? _auditBox;

  // Private constructor for singleton
  LocalBackupService._();

  /// Returns singleton instance. All providers must use this.
  static LocalBackupService getInstance() {
    _instance ??= LocalBackupService._();
    return _instance!;
  }

  /// Initializes Hive boxes. Call once in main.dart before runApp.
  Future<void> init() async {
    if (_isInitialized) return; // Prevent reinit

    try {
      _voteBox = await Hive.openBox<Map<dynamic, dynamic>>(_voteBoxName);
      _auditBox = await Hive.openBox<Map<dynamic, dynamic>>(_auditBoxName);
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint(
          '[LocalBackupService] Initialized: vote_backups=${_voteBox!.length}, audit_logs=${_auditBox!.length}',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalBackupService] Init failed: $e');
      rethrow;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  // -------------------------------------------------------------------------
  // Vote Backup CRUD
  // -------------------------------------------------------------------------

  /// Save a vote backup to local storage.
  /// Throws exception if box is not initialized.
  Future<void> saveVoteBackup({
    required int voteId,
    required int electionId,
    required int candidateId,
    required String officerPasskey,
    DateTime? timestamp,
  }) async {
    final box = _voteBox;
    if (box == null) {
      throw Exception(
        'Vote box not initialized. Call LocalBackupService.getInstance().init() first.',
      );
    }

    try {
      final key = voteId.toString();
      final data = <String, dynamic>{
        'vote_id': voteId,
        'election_id': electionId,
        'candidate_id': candidateId,
        'officer_passkey': officerPasskey,
        'backup_timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
        'backup_source': 'local_hive',
        'recovery_status': 'pending',
        'synced_to_cloud': false,
      };

      await box.put(key, data.cast<dynamic, dynamic>());

      if (kDebugMode) {
        debugPrint(
          '[LocalBackupService] Vote backup saved: voteId=$voteId, electionId=$electionId',
        );
      }
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error saving vote backup: $e');
      rethrow;
    }
  }

  /// Get all vote backups sorted by timestamp (newest first).
  /// Returns empty list if box is not initialized.
  List<VoteBackup> getAllVoteBackups() {
    final box = _voteBox;
    if (box == null) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Vote box not initialized, returning empty list',
        );
      return <VoteBackup>[];
    }

    try {
      final items = box.values
          .map((raw) {
            try {
              final map = Map<String, dynamic>.from(
                raw.cast<String, dynamic>(),
              );
              return VoteBackup(
                backupId: map['vote_id'] ?? 0,
                voteId: map['vote_id'] ?? 0,
                voteData: map,
                backupTimestamp:
                    DateTime.tryParse(map['backup_timestamp'] ?? '') ??
                    DateTime.now(),
                backupSource: map['backup_source'] ?? 'local_hive',
                recoveryStatus: _parseStatus(map['recovery_status']),
              );
            } catch (e) {
              if (kDebugMode)
                debugPrint(
                  '[LocalBackupService] Error parsing vote backup entry: $e',
                );
              return null;
            }
          })
          .whereType<VoteBackup>()
          .toList();

      items.sort((a, b) => b.backupTimestamp.compareTo(a.backupTimestamp));
      return items;
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error retrieving vote backups: $e');
      return <VoteBackup>[];
    }
  }

  /// Get only pending (unsynced) vote backups.
  List<VoteBackup> getPendingBackups() {
    try {
      return getAllVoteBackups()
          .where((b) => b.recoveryStatus == BackupStatus.pending)
          .toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error retrieving pending backups: $e');
      return <VoteBackup>[];
    }
  }

  /// Get vote backups for a specific election.
  List<VoteBackup> getBackupsForElection(int electionId) {
    try {
      return getAllVoteBackups()
          .where((b) => (b.voteData['election_id'] as int?) == electionId)
          .toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Error retrieving backups for election: $e',
        );
      return <VoteBackup>[];
    }
  }

  /// Get vote backup by specific vote ID.
  /// Returns null if not found.
  VoteBackup? getVoteBackupById(int voteId) {
    try {
      final box = _voteBox;
      if (box == null) return null;

      final raw = box.get(voteId.toString());
      if (raw == null) return null;

      final map = Map<String, dynamic>.from(raw.cast<String, dynamic>());
      return VoteBackup(
        backupId: map['vote_id'] ?? 0,
        voteId: map['vote_id'] ?? 0,
        voteData: map,
        backupTimestamp:
            DateTime.tryParse(map['backup_timestamp'] ?? '') ?? DateTime.now(),
        backupSource: map['backup_source'] ?? 'local_hive',
        recoveryStatus: _parseStatus(map['recovery_status']),
      );
    } catch (e) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Error retrieving vote backup by ID: $e',
        );
      return null;
    }
  }

  /// Get vote backup count
  int getVoteBackupCount() {
    return getAllVoteBackups().length;
  }

  /// Mark a vote as synced to cloud.
  Future<void> markVoteSynced(int voteId) async {
    final box = _voteBox;
    if (box == null) {
      throw Exception(
        'Vote box not initialized. Call LocalBackupService.getInstance().init() first.',
      );
    }

    try {
      final key = voteId.toString();
      final raw = box.get(key);
      if (raw == null) {
        if (kDebugMode)
          debugPrint(
            '[LocalBackupService] Vote not found for sync: voteId=$voteId',
          );
        return;
      }

      final map = Map<String, dynamic>.from(raw.cast<String, dynamic>());
      map['recovery_status'] = 'restored';
      map['synced_to_cloud'] = true;
      map['synced_timestamp'] = DateTime.now().toIso8601String();
      await box.put(key, map.cast<dynamic, dynamic>());

      if (kDebugMode) {
        debugPrint(
          '[LocalBackupService] Vote marked as synced: voteId=$voteId',
        );
      }
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error marking vote as synced: $e');
      rethrow;
    }
  }

  /// Clear all vote backups (use with caution).
  Future<void> clearVoteBackups() async {
    try {
      await _voteBox?.clear();
      if (kDebugMode)
        debugPrint('[LocalBackupService] All vote backups cleared');
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error clearing vote backups: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Audit Log CRUD
  // -------------------------------------------------------------------------

  /// Save an audit log entry to local storage.
  /// Uses unique key to prevent collisions (milliseconds + random).
  Future<void> saveAuditLog({
    required int entryId,
    required String action,
    required String details,
    int? electionId,
    int? userId,
    String? ipAddress,
    AuditSeverity severity = AuditSeverity.info,
  }) async {
    final box = _auditBox;
    if (box == null) {
      throw Exception(
        'Audit box not initialized. Call LocalBackupService.getInstance().init() first.',
      );
    }

    try {
      // Generate unique key: timestamp_randomNumber
      final uniqueKey =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

      final data = <String, dynamic>{
        'entry_id': entryId,
        'action': action,
        'details': details,
        'election_id': electionId,
        'user_id': userId,
        'ip_address': ipAddress ?? '127.0.0.1',
        'timestamp': DateTime.now().toIso8601String(),
        'severity': severity.name,
        'log_hash': _generateLogHash(entryId, action),
      };

      await box.put(uniqueKey, data.cast<dynamic, dynamic>());

      if (kDebugMode) {
        debugPrint(
          '[LocalBackupService] Audit log saved: action=$action, severity=$severity',
        );
      }
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error saving audit log: $e');
      rethrow;
    }
  }

  /// Get all audit logs sorted by timestamp (newest first).
  /// Returns empty list if box is not initialized.
  List<AuditLog> getAllAuditLogs() {
    final box = _auditBox;
    if (box == null) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Audit box not initialized, returning empty list',
        );
      return <AuditLog>[];
    }

    try {
      final items = box.values
          .map((raw) {
            try {
              final map = Map<String, dynamic>.from(
                raw.cast<String, dynamic>(),
              );
              return AuditLog(
                entryId: map['entry_id'] ?? 0,
                userId: map['user_id'] ?? 0,
                action: map['action'] ?? '',
                electionId: map['election_id'],
                details: map['details'] ?? '',
                ipAddress: map['ip_address'] ?? '127.0.0.1',
                timestamp:
                    DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
                logHash: map['log_hash'] ?? '',
                severity: _parseSeverity(map['severity']),
              );
            } catch (e) {
              if (kDebugMode)
                debugPrint(
                  '[LocalBackupService] Error parsing audit log entry: $e',
                );
              return null;
            }
          })
          .whereType<AuditLog>()
          .toList();

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error retrieving audit logs: $e');
      return <AuditLog>[];
    }
  }

  /// Get audit logs by action type.
  List<AuditLog> getLogsByAction(String action) {
    try {
      return getAllAuditLogs().where((log) => log.action == action).toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error retrieving logs by action: $e');
      return <AuditLog>[];
    }
  }

  /// Get audit logs by severity level.
  List<AuditLog> getLogsBySeverity(AuditSeverity severity) {
    try {
      return getAllAuditLogs()
          .where((log) => log.severity == severity)
          .toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Error retrieving logs by severity: $e',
        );
      return <AuditLog>[];
    }
  }

  /// Get audit logs within date range.
  List<AuditLog> getLogsByDateRange(DateTime start, DateTime end) {
    try {
      return getAllAuditLogs()
          .where(
            (log) =>
                log.timestamp.isAfter(start) && log.timestamp.isBefore(end),
          )
          .toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Error retrieving logs by date range: $e',
        );
      return <AuditLog>[];
    }
  }

  /// Get audit logs for specific user.
  List<AuditLog> getLogsByUserId(int userId) {
    try {
      return getAllAuditLogs().where((log) => log.userId == userId).toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error retrieving logs by user ID: $e');
      return <AuditLog>[];
    }
  }

  /// Get audit logs for specific election.
  List<AuditLog> getLogsByElectionId(int electionId) {
    try {
      return getAllAuditLogs()
          .where((log) => log.electionId == electionId)
          .toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint(
          '[LocalBackupService] Error retrieving logs by election ID: $e',
        );
      return <AuditLog>[];
    }
  }

  /// Get audit log count
  int getAuditLogCount() {
    return getAllAuditLogs().length;
  }

  /// Clear all audit logs (use with caution).
  Future<void> clearAuditLogs() async {
    try {
      await _auditBox?.clear();
      if (kDebugMode) debugPrint('[LocalBackupService] All audit logs cleared');
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocalBackupService] Error clearing audit logs: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static BackupStatus _parseStatus(String? value) {
    switch (value) {
      case 'restored':
        return BackupStatus.restored;
      case 'failed':
        return BackupStatus.failed;
      default:
        return BackupStatus.pending;
    }
  }

  static AuditSeverity _parseSeverity(String? value) {
    switch (value) {
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

  static String _generateLogHash(int entryId, String action) {
    final payload =
        '$entryId-$action-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(99999)}';
    return base64Encode(payload.codeUnits).substring(0, 16);
  }
}
