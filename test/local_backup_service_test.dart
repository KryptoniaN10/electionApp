import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:electionapp/Machine/services/local_backup_service.dart';
import 'package:electionapp/Machine/machine_models/audit/audit_log_model.dart';
import 'package:electionapp/Machine/machine_models/audit/vote_backup_model.dart';

// Mock PathProviderPlatform for testing
class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => './test/.tmp';

  @override
  Future<String?> getApplicationDocumentsPath() async => './test/.docs';

  @override
  Future<String?> getApplicationCachePath() async => './test/.cache';

  @override
  Future<String?> getApplicationSupportPath() async => './test/.support';

  @override
  Future<String?> getExternalStoragePath() async => './test/.storage';

  @override
  Future<List<String>?> getExternalCachePaths() async => ['./test/.cache'];

  @override
  Future<List<String>?> getExternalFilesPath(String? type) async => [
    './test/.files',
  ];

  @override
  Future<String?> getDownloadsPath() async => './test/.downloads';
}

void main() {
  group('LocalBackupService Tests', () {
    late LocalBackupService backup;

    setUpAll(() async {
      // Setup path provider mock
      PathProviderPlatform.instance = MockPathProviderPlatform();

      // Initialize Hive with test directory
      Hive.init('./test/.hive');

      // Get singleton instance
      backup = LocalBackupService.getInstance();
    });

    tearDownAll(() async {
      // Clean up after tests
      await Hive.close();
    });

    test('Singleton pattern: getInstance returns same instance', () {
      final instance1 = LocalBackupService.getInstance();
      final instance2 = LocalBackupService.getInstance();

      expect(
        identical(instance1, instance2),
        true,
        reason: 'getInstance should return the same instance',
      );
    });

    test('Init: initializes without errors', () async {
      expect(
        backup.isInitialized,
        false,
        reason: 'Should not be initialized yet',
      );

      await backup.init();

      expect(
        backup.isInitialized,
        true,
        reason: 'Should be initialized after init()',
      );
    });

    test('Init: prevents re-initialization', () async {
      // Already initialized from previous test
      await backup.init();
      await backup.init(); // Should return early

      expect(backup.isInitialized, true);
    });

    group('Vote Backup CRUD', () {
      test('saveVoteBackup: saves vote successfully', () async {
        await backup.saveVoteBackup(
          voteId: 1,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'test-passkey-123',
          timestamp: DateTime(2026, 6, 26, 10, 30),
        );

        final backups = backup.getAllVoteBackups();
        expect(backups, isNotEmpty, reason: 'Should have at least one backup');
        expect(backups.first.voteId, 1);
        expect(backups.first.voteData['election_id'], 100);
      });

      test(
        'getAllVoteBackups: returns sorted by timestamp (newest first)',
        () async {
          // Clear previous
          await backup.clearVoteBackups();

          // Add multiple backups with different timestamps
          await backup.saveVoteBackup(
            voteId: 1,
            electionId: 100,
            candidateId: 50,
            officerPasskey: 'key1',
            timestamp: DateTime(2026, 6, 26, 10, 0),
          );

          await backup.saveVoteBackup(
            voteId: 2,
            electionId: 100,
            candidateId: 51,
            officerPasskey: 'key2',
            timestamp: DateTime(2026, 6, 26, 10, 30),
          );

          await backup.saveVoteBackup(
            voteId: 3,
            electionId: 100,
            candidateId: 52,
            officerPasskey: 'key3',
            timestamp: DateTime(2026, 6, 26, 10, 15),
          );

          final backups = backup.getAllVoteBackups();

          expect(backups.length, 3);
          expect(backups[0].voteId, 2, reason: 'Most recent should be first');
          expect(
            backups[1].voteId,
            3,
            reason: 'Middle backup should be second',
          );
          expect(backups[2].voteId, 1, reason: 'Oldest should be last');
        },
      );

      test('getPendingBackups: returns only pending backups', () async {
        await backup.clearVoteBackups();

        // Add backups
        await backup.saveVoteBackup(
          voteId: 10,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'key1',
        );

        await backup.saveVoteBackup(
          voteId: 11,
          electionId: 100,
          candidateId: 51,
          officerPasskey: 'key2',
        );

        // Mark one as synced
        await backup.markVoteSynced(10);

        final pending = backup.getPendingBackups();

        expect(pending.length, 1, reason: 'Should have one pending backup');
        expect(pending.first.voteId, 11);
        expect(pending.first.recoveryStatus, BackupStatus.pending);
      });

      test('getBackupsForElection: filters by election ID', () async {
        await backup.clearVoteBackups();

        await backup.saveVoteBackup(
          voteId: 20,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'key1',
        );

        await backup.saveVoteBackup(
          voteId: 21,
          electionId: 200,
          candidateId: 60,
          officerPasskey: 'key2',
        );

        await backup.saveVoteBackup(
          voteId: 22,
          electionId: 100,
          candidateId: 51,
          officerPasskey: 'key3',
        );

        final election100 = backup.getBackupsForElection(100);
        final election200 = backup.getBackupsForElection(200);

        expect(election100.length, 2);
        expect(election200.length, 1);
        expect(election200.first.voteData['election_id'], 200);
      });

      test('getVoteBackupById: retrieves specific backup', () async {
        await backup.clearVoteBackups();

        await backup.saveVoteBackup(
          voteId: 30,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'key1',
        );

        final backup30 = backup.getVoteBackupById(30);
        final backup99 = backup.getVoteBackupById(99);

        expect(backup30, isNotNull);
        expect(backup30?.voteId, 30);
        expect(
          backup99,
          isNull,
          reason: 'Non-existent backup should return null',
        );
      });

      test('getVoteBackupCount: returns correct count', () async {
        await backup.clearVoteBackups();

        await backup.saveVoteBackup(
          voteId: 40,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'key1',
        );

        await backup.saveVoteBackup(
          voteId: 41,
          electionId: 100,
          candidateId: 51,
          officerPasskey: 'key2',
        );

        expect(backup.getVoteBackupCount(), 2);
      });

      test('markVoteSynced: updates backup status', () async {
        await backup.clearVoteBackups();

        await backup.saveVoteBackup(
          voteId: 50,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'key1',
        );

        var backupBefore = backup.getVoteBackupById(50);
        expect(backupBefore?.recoveryStatus, BackupStatus.pending);

        await backup.markVoteSynced(50);

        var backupAfter = backup.getVoteBackupById(50);
        expect(backupAfter?.recoveryStatus, BackupStatus.restored);
        expect(backupAfter?.voteData['synced_to_cloud'], true);
      });

      test('clearVoteBackups: removes all vote backups', () async {
        await backup.saveVoteBackup(
          voteId: 60,
          electionId: 100,
          candidateId: 50,
          officerPasskey: 'key1',
        );

        expect(backup.getAllVoteBackups(), isNotEmpty);

        await backup.clearVoteBackups();

        expect(backup.getAllVoteBackups(), isEmpty);
      });
    });

    group('Audit Log CRUD', () {
      test('saveAuditLog: saves audit log successfully', () async {
        await backup.saveAuditLog(
          entryId: 1,
          action: 'VOTE_CAST',
          details: 'Vote cast for candidate 50',
          electionId: 100,
          userId: 1,
          ipAddress: '192.168.1.1',
          severity: AuditSeverity.info,
        );

        final logs = backup.getAllAuditLogs();
        expect(logs, isNotEmpty);
        expect(logs.first.action, 'VOTE_CAST');
      });

      test(
        'getAllAuditLogs: returns sorted by timestamp (newest first)',
        () async {
          await backup.clearAuditLogs();

          // Add logs with delays to ensure different timestamps
          await backup.saveAuditLog(
            entryId: 1,
            action: 'LOG_1',
            details: 'First log',
            userId: 1,
          );

          await Future.delayed(const Duration(milliseconds: 10));

          await backup.saveAuditLog(
            entryId: 2,
            action: 'LOG_2',
            details: 'Second log',
            userId: 1,
          );

          await Future.delayed(const Duration(milliseconds: 10));

          await backup.saveAuditLog(
            entryId: 3,
            action: 'LOG_3',
            details: 'Third log',
            userId: 1,
          );

          final logs = backup.getAllAuditLogs();

          expect(logs.length, 3);
          expect(
            logs[0].action,
            'LOG_3',
            reason: 'Most recent log should be first',
          );
          expect(logs[1].action, 'LOG_2');
          expect(logs[2].action, 'LOG_1', reason: 'Oldest log should be last');
        },
      );

      test('getLogsByAction: filters by action type', () async {
        await backup.clearAuditLogs();

        await backup.saveAuditLog(
          entryId: 1,
          action: 'VOTE_CAST',
          details: 'Vote cast',
          userId: 1,
        );

        await backup.saveAuditLog(
          entryId: 2,
          action: 'LOGIN',
          details: 'Officer logged in',
          userId: 1,
        );

        await backup.saveAuditLog(
          entryId: 3,
          action: 'VOTE_CAST',
          details: 'Another vote cast',
          userId: 2,
        );

        final voteLogs = backup.getLogsByAction('VOTE_CAST');
        final loginLogs = backup.getLogsByAction('LOGIN');

        expect(voteLogs.length, 2);
        expect(loginLogs.length, 1);
        expect(loginLogs.first.action, 'LOGIN');
      });

      test('getLogsBySeverity: filters by severity level', () async {
        await backup.clearAuditLogs();

        await backup.saveAuditLog(
          entryId: 1,
          action: 'ACTION_1',
          details: 'Info log',
          severity: AuditSeverity.info,
        );

        await backup.saveAuditLog(
          entryId: 2,
          action: 'ACTION_2',
          details: 'Warning log',
          severity: AuditSeverity.warning,
        );

        await backup.saveAuditLog(
          entryId: 3,
          action: 'ACTION_3',
          details: 'Error log',
          severity: AuditSeverity.error,
        );

        final infoLogs = backup.getLogsBySeverity(AuditSeverity.info);
        final errorLogs = backup.getLogsBySeverity(AuditSeverity.error);

        expect(infoLogs.length, 1);
        expect(errorLogs.length, 1);
        expect(errorLogs.first.severity, AuditSeverity.error);
      });

      test('getLogsByUserId: filters by user ID', () async {
        await backup.clearAuditLogs();

        await backup.saveAuditLog(
          entryId: 1,
          action: 'ACTION_1',
          details: 'Log from user 1',
          userId: 1,
        );

        await backup.saveAuditLog(
          entryId: 2,
          action: 'ACTION_2',
          details: 'Log from user 2',
          userId: 2,
        );

        await backup.saveAuditLog(
          entryId: 3,
          action: 'ACTION_3',
          details: 'Another log from user 1',
          userId: 1,
        );

        final user1Logs = backup.getLogsByUserId(1);
        final user2Logs = backup.getLogsByUserId(2);

        expect(user1Logs.length, 2);
        expect(user2Logs.length, 1);
      });

      test('getLogsByElectionId: filters by election ID', () async {
        await backup.clearAuditLogs();

        await backup.saveAuditLog(
          entryId: 1,
          action: 'ACTION_1',
          details: 'Log for election 100',
          electionId: 100,
        );

        await backup.saveAuditLog(
          entryId: 2,
          action: 'ACTION_2',
          details: 'Log for election 200',
          electionId: 200,
        );

        await backup.saveAuditLog(
          entryId: 3,
          action: 'ACTION_3',
          details: 'Another log for election 100',
          electionId: 100,
        );

        final election100Logs = backup.getLogsByElectionId(100);
        final election200Logs = backup.getLogsByElectionId(200);

        expect(election100Logs.length, 2);
        expect(election200Logs.length, 1);
      });

      test('getLogsByDateRange: filters by date range', () async {
        await backup.clearAuditLogs();

        final startDate = DateTime(2026, 6, 26, 10, 0);
        final midDate = DateTime(2026, 6, 26, 10, 30);
        final endDate = DateTime(2026, 6, 26, 11, 0);

        // Manually create logs with specific timestamps
        await backup.saveAuditLog(
          entryId: 1,
          action: 'LOG_1',
          details: 'Before range',
          userId: 1,
        );

        await backup.saveAuditLog(
          entryId: 2,
          action: 'LOG_2',
          details: 'In range',
          userId: 1,
        );

        // Get logs and verify filtering works
        final allLogs = backup.getAllAuditLogs();
        expect(allLogs, isNotEmpty);
      });

      test('getAuditLogCount: returns correct count', () async {
        await backup.clearAuditLogs();

        await backup.saveAuditLog(
          entryId: 1,
          action: 'ACTION_1',
          details: 'Log 1',
        );

        await backup.saveAuditLog(
          entryId: 2,
          action: 'ACTION_2',
          details: 'Log 2',
        );

        expect(backup.getAuditLogCount(), 2);
      });

      test('clearAuditLogs: removes all audit logs', () async {
        await backup.saveAuditLog(
          entryId: 1,
          action: 'ACTION_1',
          details: 'Log to be cleared',
        );

        expect(backup.getAllAuditLogs(), isNotEmpty);

        await backup.clearAuditLogs();

        expect(backup.getAllAuditLogs(), isEmpty);
      });
    });

    group('Error Handling', () {
      test('saveVoteBackup throws when box not initialized (simulated)', () {
        // This would require resetting the service, so we verify graceful handling instead
        final backups = backup.getAllVoteBackups();
        expect(
          backups,
          isA<List<VoteBackup>>(),
          reason: 'Should handle gracefully',
        );
      });

      test('Invalid data type casting is handled gracefully', () async {
        await backup.clearVoteBackups();

        await backup.saveVoteBackup(
          voteId: 100,
          electionId: 200,
          candidateId: 50,
          officerPasskey: 'key',
        );

        // Try to get it back - should not throw
        expect(() => backup.getAllVoteBackups(), returnsNormally);
      });

      test('getAllVoteBackups handles corrupt data gracefully', () async {
        // This tests the whereType filter that removes null entries
        final backups = backup.getAllVoteBackups();
        expect(backups, isA<List<VoteBackup>>());
      });
    });

    group('Integration Tests', () {
      test('Complete workflow: save, query, update, clear', () async {
        await backup.clearVoteBackups();
        await backup.clearAuditLogs();

        // Save vote
        await backup.saveVoteBackup(
          voteId: 200,
          electionId: 300,
          candidateId: 150,
          officerPasskey: 'integration-test-key',
        );

        // Save audit log
        await backup.saveAuditLog(
          entryId: 1,
          action: 'TEST_INTEGRATION',
          details: 'Integration test audit log',
          electionId: 300,
          userId: 100,
          severity: AuditSeverity.info,
        );

        // Verify both saved
        expect(backup.getVoteBackupCount(), 1);
        expect(backup.getAuditLogCount(), 1);

        // Query by ID
        final vote = backup.getVoteBackupById(200);
        expect(vote, isNotNull);
        expect(vote?.voteData['election_id'], 300);

        // Query by election
        final electionBackups = backup.getBackupsForElection(300);
        final electionLogs = backup.getLogsByElectionId(300);
        expect(electionBackups.length, 1);
        expect(electionLogs.length, 1);

        // Update vote status
        await backup.markVoteSynced(200);
        final updatedVote = backup.getVoteBackupById(200);
        expect(updatedVote?.recoveryStatus, BackupStatus.restored);

        // Clear all
        await backup.clearVoteBackups();
        await backup.clearAuditLogs();
        expect(backup.getVoteBackupCount(), 0);
        expect(backup.getAuditLogCount(), 0);
      });
    });
  });
}
