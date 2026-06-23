import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../machine_models/audit/audit_log_model.dart';
import '../../machine_provider/audit_logs_provider.dart';
import '../widgets/machine_ui.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditLogsProvider>(
      builder: (context, provider, _) {
        return MachineScaffold(
          title: 'Audit Compliance',
          subtitle: 'Immutable local activity tracking and anonymized vote integrity counters.',
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: MachineCard(
                      child: InfoTile(
                        label: 'Total Vote Counter',
                        value: provider.totalVotesCast.toString(),
                        icon: Icons.how_to_vote_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MachineCard(
                      child: InfoTile(
                        label: 'Recovered Backups',
                        value: provider.restoredBackups.toString(),
                        icon: Icons.restore_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              MachineCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SectionTitle(
                      title: 'Chronological Activity Feed',
                      subtitle: 'Timestamped terminal operations, security state changes, and sync events.',
                    ),
                    const SizedBox(height: 16),
                    ...provider.logs.map(
                      (log) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FC),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              StatusPill(
                                label: log.severity.name.toUpperCase(),
                                color: _severityColor(log.severity),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      log.action,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: MachineTheme.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log.details,
                                      style: const TextStyle(color: MachineTheme.muted),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formatDateTime(log.timestamp),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: MachineTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Color _severityColor(AuditSeverity severity) {
    switch (severity) {
      case AuditSeverity.info:
        return MachineTheme.primary;
      case AuditSeverity.warning:
        return MachineTheme.warning;
      case AuditSeverity.error:
        return MachineTheme.danger;
      case AuditSeverity.critical:
        return Colors.black;
    }
  }
}
