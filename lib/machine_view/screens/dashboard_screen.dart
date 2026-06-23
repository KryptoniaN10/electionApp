import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../machine_models/election/election_model.dart';
import '../../machine_models/state/machine_state_model.dart';
import '../../machine_provider/auth_provider.dart';
import '../../machine_provider/ballot_provider.dart';
import '../../machine_provider/dashboard_provider.dart';
import '../../machine_provider/election_init_provider.dart';
import '../widgets/machine_ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, AuthProvider>(
      builder: (context, dashboard, auth, _) {
        final machineState = dashboard.machineState;
        final session = dashboard.officerSession;

        return MachineScaffold(
          title: 'Officer Dashboard',
          subtitle: 'Remote command center for ballot control, grants, and machine oversight.',
          actions: <Widget>[
            IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              color: Colors.white,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          child: dashboard.isLoading || machineState == null || session == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    MachineCard(
                      tinted: true,
                      child: Wrap(
                        runSpacing: 12,
                        spacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SectionTitle(
                                title: 'Machine Status',
                                subtitle:
                                    'Hardware health and cloud connectivity summary.',
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <Widget>[
                                  StatusPill(
                                    label: machineState.health.name.toUpperCase(),
                                    color: _healthColor(machineState.health),
                                  ),
                                  StatusPill(
                                    label: machineState.firebaseConnected
                                        ? 'FIREBASE CONNECTED'
                                        : 'FIREBASE OFFLINE',
                                    color: machineState.firebaseConnected
                                        ? MachineTheme.success
                                        : MachineTheme.warning,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 320,
                            child: Column(
                              children: <Widget>[
                                InfoTile(
                                  label: 'Machine Code',
                                  value: machineState.machineCode,
                                  icon: Icons.memory_rounded,
                                ),
                                const SizedBox(height: 10),
                                InfoTile(
                                  label: 'Last Heartbeat',
                                  value: formatDateTime(machineState.lastHeartbeat),
                                  icon: Icons.sync_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 900;
                        final cardWidth =
                            wide ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth;

                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: <Widget>[
                            SizedBox(
                              width: cardWidth,
                              child: MachineCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SectionTitle(
                                      title: 'Session Management',
                                      subtitle:
                                          'Current state of the polling booth for this terminal.',
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: <Widget>[
                                        StatusPill(
                                          label: dashboard.boothStatusLabel.toUpperCase(),
                                          color: dashboard.isPaused
                                              ? MachineTheme.warning
                                              : MachineTheme.success,
                                        ),
                                        StatusPill(
                                          label: dashboard.hasOfficerGrant
                                              ? 'VOTER GRANT LIVE'
                                              : 'WAITING FOR GRANT',
                                          color: dashboard.hasOfficerGrant
                                              ? MachineTheme.primary
                                              : MachineTheme.muted,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Session token: ${dashboard.pollSession!.sessionToken}',
                                      style: const TextStyle(color: MachineTheme.text),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Started: ${formatDateTime(dashboard.pollSession!.startTime)}',
                                      style: const TextStyle(color: MachineTheme.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: MachineCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SectionTitle(
                                      title: 'Officer Identity',
                                      subtitle:
                                          'Authenticated console session details from local session state.',
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      auth.officerName ?? 'Presiding Officer',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: MachineTheme.text,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'User ID: ${session.userId}  |  Machine ID: ${session.machineId}',
                                      style: const TextStyle(color: MachineTheme.muted),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Valid until ${formatDateTime(session.expiresAt)}',
                                      style: const TextStyle(color: MachineTheme.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    MachineCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionTitle(
                            title: 'Active Elections',
                            subtitle: 'Select all positions the voter will vote for in this session.',
                          ),
                          const SizedBox(height: 16),
                          Consumer<ElectionInitProvider>(
                            builder: (context, electionProvider, _) {
                              if (electionProvider.isLoading) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final openElections = electionProvider.openElections;
                              if (openElections.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FC),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    'No active elections available.',
                                    style: TextStyle(color: MachineTheme.muted),
                                  ),
                                );
                              }

                              final selectedCount = electionProvider.selectedElectionIds.length;

                              return Column(
                                children: [
                                  ...openElections.map((election) {
                                    final isSelected = electionProvider.isElectionSelected(election.electionId);
                                    return InkWell(
                                      onTap: () => electionProvider.toggleElectionSelection(election.electionId),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? MachineTheme.primary.withAlpha(20)
                                              : const Color(0xFFF8F9FC),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? MachineTheme.primary.withAlpha(60)
                                                : const Color(0xFFE2DFFF),
                                          ),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (_) => electionProvider.toggleElectionSelection(election.electionId),
                                              activeColor: MachineTheme.primaryDeep,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    election.title,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: MachineTheme.text,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${election.office} • ${election.votesCast}/${election.totalVoters} votes',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: MachineTheme.muted,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  StatusPill(
                                                    label: election.status.name.toUpperCase(),
                                                    color: election.status == ElectionStatus.open
                                                        ? MachineTheme.success
                                                        : MachineTheme.warning,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: selectedCount > 0
                                        ? () async {
                                            final selectedIds = electionProvider.selectedElectionIds.toList();
                                            context.read<BallotProvider>().loadBallot(electionIds: selectedIds);
                                            dashboard.initializeBallot();
                                            dashboard.setOfficerGrant(true);
                                            await context.read<BallotProvider>().setOfficerGrant(true);
                                            if (context.mounted) {
                                              Navigator.pushNamed(context, '/ballot');
                                            }
                                          }
                                        : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: MachineTheme.primaryDeep,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 16,
                                      ),
                                    ),
                                    icon: const Icon(Icons.lock_open_rounded, size: 22),
                                    label: Text(
                                      selectedCount > 0
                                          ? 'Unlock Booth for $selectedCount Position${selectedCount > 1 ? 's' : ''}'
                                          : 'Select at least 1 election',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    MachineCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionTitle(
                            title: 'Control Actions',
                            subtitle: 'Primary terminal actions for the officer.',
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              OutlinedButton.icon(
                                onPressed: dashboard.togglePauseElection,
                                icon: Icon(
                                  dashboard.isPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_circle_outline_rounded,
                                ),
                                label: Text(
                                  dashboard.isPaused ? 'Resume Election' : 'Pause Election',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  dashboard.exportAuditLogs();
                                  Navigator.pushNamed(context, '/audit-logs');
                                },
                                icon: const Icon(Icons.inventory_2_outlined),
                                label: const Text('Print/Export Audit Logs'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final next = !dashboard.hasOfficerGrant;
                                  dashboard.setOfficerGrant(next);
                                  final selectedIds = context.read<ElectionInitProvider>().selectedElectionIds.toList();
                                  await context.read<BallotProvider>().setOfficerGrant(next);
                                  if (next && context.mounted) {
                                    if (selectedIds.isNotEmpty) {
                                      context.read<BallotProvider>().loadBallot(electionIds: selectedIds);
                                    }
                                    Navigator.pushNamed(context, '/ballot');
                                  }
                                },
                                icon: const Icon(Icons.verified_user_outlined),
                                label: Text(
                                  dashboard.hasOfficerGrant
                                      ? 'Revoke Test Grant'
                                      : 'Simulate Test Grant',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              dashboard.lastActionMessage,
                              style: const TextStyle(color: MachineTheme.text),
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

  static Color _healthColor(MachineHealth health) {
    switch (health) {
      case MachineHealth.ready:
        return MachineTheme.success;
      case MachineHealth.syncing:
        return MachineTheme.primary;
      case MachineHealth.warning:
        return MachineTheme.warning;
      case MachineHealth.offline:
        return MachineTheme.danger;
    }
  }
}
