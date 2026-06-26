import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../machine_data/machine_fake_data.dart';
// import '../../machine_provider/ballot_provider.dart';
import '../../machine_provider/election_init_provider.dart';
import '../widgets/machine_ui.dart';

class ElectionInitScreen extends StatelessWidget {
  const ElectionInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ElectionInitProvider>(
      builder: (context, provider, _) {
        final elections = provider.elections;

        return MachineScaffold(
          title: 'Election Initialization',
          subtitle: 'Verify all election metadata and candidate registries before opening the booth.',
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    // Elections list
                    ...elections.map((election) {
                      final isOpen = election.status.name == 'open';
                      final candidates = MachineFakeData.candidatesForElection(election.electionId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: MachineCard(
                          tinted: isOpen,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          election.title,
                                          style: const TextStyle(
                                            fontSize: 18,
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
                                      ],
                                    ),
                                  ),
                                  StatusPill(
                                    label: election.status.name.toUpperCase(),
                                    color: isOpen ? MachineTheme.success : MachineTheme.warning,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Candidates',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: MachineTheme.text,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: candidates.map((candidate) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: MachineTheme.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CandidateAvatar(
                                          title: candidate.fullName,
                                          imageUrl: candidate.photoUrl,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              candidate.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: MachineTheme.text,
                                              ),
                                            ),
                                            Text(
                                              candidate.className ?? candidate.position ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: MachineTheme.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        StatusPill(
                                          label: candidate.isVerified ? 'Verified' : 'Pending',
                                          color: candidate.isVerified
                                              ? MachineTheme.success
                                              : MachineTheme.warning,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoTile(
                                      label: 'Election ID',
                                      value: '${election.electionId}',
                                      icon: Icons.tag_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InfoTile(
                                      label: 'Start',
                                      value: formatDateTime(election.startTime),
                                      icon: Icons.schedule_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InfoTile(
                                      label: 'End',
                                      value: formatDateTime(election.endTime),
                                      icon: Icons.timer_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 14),
                    MachineCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionTitle(
                            title: 'Voter Class Filters',
                            subtitle: 'Visibility of voter groups authorized on this booth tier.',
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: provider.classes
                                .map(
                                  (voterClass) => Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: voterClass.isAuthorized
                                          ? MachineTheme.success.withAlpha(22)
                                          : MachineTheme.warning.withAlpha(22),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: voterClass.isAuthorized
                                            ? MachineTheme.success.withAlpha(40)
                                            : MachineTheme.warning.withAlpha(40),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          '${voterClass.name} ${voterClass.section}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: MachineTheme.text,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${voterClass.tierLabel} • ${voterClass.eligibleVoters} eligible',
                                          style: const TextStyle(color: MachineTheme.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
        );
      },
    );
  }
}
