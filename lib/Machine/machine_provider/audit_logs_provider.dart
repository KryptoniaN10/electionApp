import 'package:flutter/foundation.dart';

import '../machine_data/machine_fake_data.dart';
import '../machine_models/audit/audit_log_model.dart';
import '../machine_models/audit/vote_backup_model.dart';
import '../services/local_backup_service.dart';

class AuditLogsProvider extends ChangeNotifier {
  AuditLogsProvider() {
    loadLogs();
  }

  final LocalBackupService _backup = LocalBackupService.getInstance();

  List<AuditLog> _logs = <AuditLog>[];
  List<VoteBackup> _backups = <VoteBackup>[];

  List<AuditLog> get logs => _logs;
  List<VoteBackup> get backups => _backups;

  int get totalVotesCast => _backups.length;
  int get restoredBackups => _backups
      .where((backup) => backup.recoveryStatus == BackupStatus.restored)
      .length;

  Future<void> loadLogs() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    // Read from local Hive storage
    _logs = _backup.getAllAuditLogs();
    _backups = _backup.getAllVoteBackups();

    // If empty (first run), fall back to fake data so the UI isn't empty
    if (_logs.isEmpty && _backups.isEmpty) {
      _logs = MachineFakeData.logs();
      _backups = MachineFakeData.backups();
    }

    notifyListeners();
  }

  /// Force refresh from Hive (call after new votes are cast).
  Future<void> refresh() async {
    _logs = _backup.getAllAuditLogs();
    _backups = _backup.getAllVoteBackups();
    notifyListeners();
  }

  /// Clear all local backups (officer action).
  Future<void> clearAll() async {
    await _backup.clearVoteBackups();
    await _backup.clearAuditLogs();
    _logs = <AuditLog>[];
    _backups = <VoteBackup>[];
    notifyListeners();
  }
}
