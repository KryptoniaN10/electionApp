import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../machine_models/audit/audit_log_model.dart';
import '../machine_models/audit/vote_backup_model.dart';

/// Hive service for local NoSQL storage.
/// Boxes: 'vote_backups', 'audit_logs'
class LocalBackupService {
  static const String _voteBoxName = 'vote_backups';
  static const String _auditBoxName = 'audit_logs';

  Box<Map<dynamic, dynamic>>? _voteBox;
  Box<Map<dynamic, dynamic>>? _auditBox;

  /// Initializes Hive boxes. Call once in main.dart before runApp.
  Future<void> init() async {
    try {
      _voteBox = await Hive.openBox<Map<dynamic, dynamic>>(_voteBoxName);
      _auditBox = await Hive.openBox<Map<dynamic, dynamic>>(_auditBoxName);
      if (kDebugMode) {
        debugPrint(
          'Hive initialized: vote_backups=${_voteBox!.length}, audit_logs=${_auditBox!.length}',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Hive init failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Vote Backup CRUD
  // -------------------------------------------------------------------------

  /// Save a vote backup to local storage.
  Future<void> saveVoteBackup({
    required int voteId,
    required int electionId,
    required int candidateId,
    required String officerPasskey,
    DateTime? timestamp,
  }) async {
    final box = _voteBox;
    if (box == null) return;

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
  }

  /// Get all vote backups sorted by timestamp (newest first).
  List<VoteBackup> getAllVoteBackups() {
    final box = _voteBox;
    if (box == null) return <VoteBackup>[];

    final items = box.values.map((raw) {
      final map = Map<String, dynamic>.from(raw.cast<String, dynamic>());
      return VoteBackup(
        backupId: map['vote_id'] ?? 0,
        voteId: map['vote_id'] ?? 0,
        voteData: map,
        backupTimestamp: DateTime.tryParse(map['backup_timestamp'] ?? '') ?? DateTime.now(),
        backupSource: map['backup_source'] ?? 'local_hive',
        recoveryStatus: _parseStatus(map['recovery_status']),
      );
    }).toList();

    items.sort((a, b) => b.backupTimestamp.compareTo(a.backupTimestamp));
    return items;
  }

  /// Get only pending (unsynced) vote backups.
  List<VoteBackup> getPendingBackups() {
    return getAllVoteBackups().where((b) => b.recoveryStatus == BackupStatus.pending).toList();
  }

  /// Mark a vote as synced to cloud.
  Future<void> markVoteSynced(int voteId) async {
    final box = _voteBox;
    if (box == null) return;

    final key = voteId.toString();
    final raw = box.get(key);
    if (raw == null) return;

    final map = Map<String, dynamic>.from(raw.cast<String, dynamic>());
    map['recovery_status'] = 'restored';
    map['synced_to_cloud'] = true;
    map['synced_timestamp'] = DateTime.now().toIso8601String();
    await box.put(key, map.cast<dynamic, dynamic>());
  }

  /// Clear all vote backups (use with caution).
  Future<void> clearVoteBackups() async {
    await _voteBox?.clear();
  }

  // -------------------------------------------------------------------------
  // Audit Log CRUD
  // -------------------------------------------------------------------------

  /// Save an audit log entry to local storage.
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
    if (box == null) return;

    final key = DateTime.now().millisecondsSinceEpoch.toString();
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

    await box.put(key, data.cast<dynamic, dynamic>());
  }

  /// Get all audit logs sorted by timestamp (newest first).
  List<AuditLog> getAllAuditLogs() {
    final box = _auditBox;
    if (box == null) return <AuditLog>[];

    final items = box.values.map((raw) {
      final map = Map<String, dynamic>.from(raw.cast<String, dynamic>());
      return AuditLog(
        entryId: map['entry_id'] ?? 0,
        userId: map['user_id'] ?? 0,
        action: map['action'] ?? '',
        electionId: map['election_id'],
        details: map['details'] ?? '',
        ipAddress: map['ip_address'] ?? '127.0.0.1',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        logHash: map['log_hash'] ?? '',
        severity: _parseSeverity(map['severity']),
      );
    }).toList();

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  /// Clear all audit logs (use with caution).
  Future<void> clearAuditLogs() async {
    await _auditBox?.clear();
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
    final payload = '$entryId-$action-${DateTime.now().millisecondsSinceEpoch}';
    return base64Encode(payload.codeUnits).substring(0, 16);
  }
}
