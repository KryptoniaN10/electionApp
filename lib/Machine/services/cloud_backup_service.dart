/// Example Firebase integration for LocalBackupService
/// This shows how to add cloud sync capabilities

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/local_backup_service.dart';

/// Cloud sync service for syncing local backups to Firebase
class CloudBackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalBackupService _local = LocalBackupService.getInstance();

  static const String _voteBackupsCollection = 'vote_backups';
  static const String _auditLogsCollection = 'audit_logs';
  static const String _machineId = 'machine_001'; // Should come from settings

  /// Sync pending backups to Firebase
  Future<void> syncPendingVotes() async {
    try {
      final pending = _local.getPendingBackups();
      
      for (final backup in pending) {
        await _firestore
            .collection(_voteBackupsCollection)
            .doc('${_machineId}_${backup.voteId}')
            .set(backup.toJson())
            .then((_) {
              // After successful cloud save, mark as synced locally
              _local.markVoteSynced(backup.voteId);
            });
      }
    } catch (e) {
      print('Error syncing votes to Firebase: $e');
      rethrow;
    }
  }

  /// Fetch votes from Firebase for specific election
  Future<List<Map<String, dynamic>>> fetchVotesFromCloud(int electionId) async {
    try {
      final snapshot = await _firestore
          .collection(_voteBackupsCollection)
          .where('election_id', isEqualTo: electionId)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching votes from Firebase: $e');
      return [];
    }
  }

  /// Sync audit logs to Firebase
  Future<void> syncAuditLogs() async {
    try {
      final logs = _local.getAllAuditLogs();
      
      for (final log in logs) {
        await _firestore
            .collection(_auditLogsCollection)
            .add(log.toJson());
      }
    } catch (e) {
      print('Error syncing audit logs to Firebase: $e');
      rethrow;
    }
  }

  /// Listen to real-time vote updates from Firebase
  Stream<QuerySnapshot> watchVoteBackups(int electionId) {
    return _firestore
        .collection(_voteBackupsCollection)
        .where('election_id', isEqualTo: electionId)
        .snapshots();
  }
}
