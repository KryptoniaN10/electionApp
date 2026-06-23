import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../machine_models/election/candidate_model.dart';
import '../../machine_provider/ballot_provider.dart';
import '../../machine_provider/election_init_provider.dart';
import '../../machine_provider/machine_settings_provider.dart';
import '../../utils/fullscreen_helper.dart';
import '../widgets/machine_ui.dart';

class BallotScreen extends StatefulWidget {
  const BallotScreen({super.key});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> with WidgetsBindingObserver {
  bool _showingLockdownDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The entire ballot screen is always locked down — no sidebar, no exit without passkey
    FullscreenHelper.enter();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FullscreenHelper.exit();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.resumed:
        // Always re-enter fullscreen when returning to ballot screen
        _showLockdownDialog(context.read<BallotProvider>());
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _showLockdownDialog(BallotProvider provider) async {
    if (_showingLockdownDialog) return;
    _showingLockdownDialog = true;
    await FullscreenHelper.enter();
    if (!mounted) {
      _showingLockdownDialog = false;
      return;
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MachineTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: <Widget>[
            Icon(Icons.security_rounded, color: MachineTheme.warning, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kiosk Lockdown Active',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'You exited the secure voting area. Full-screen mode is required to continue voting. The ballot session is still active.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <Widget>[
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MachineTheme.primaryDeep,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () async {
              await FullscreenHelper.enter();
              Navigator.pop(dialogContext);
            },
            child: const Text('Re-Enter Full Screen'),
          ),
        ],
      ),
    );
    _showingLockdownDialog = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BallotProvider>(
      builder: (context, provider, _) {
        final settings = context.read<MachineSettingsProvider>().settings;
        if (settings?.officerPasskey != null && provider.officerPasskey == null) {
          provider.setOfficerPasskey(settings!.officerPasskey);
        }

        if (!provider.hasOfficerGrant) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              await _showPasskeyDialog(context, provider);
            },
            child: MachineScaffold(
              title: 'Secure Ballot Terminal',
              subtitle: 'This screen stays locked until the officer grants the next voter session.',
              showSidebar: false,
              darkModeProgress: 1,
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  tooltip: 'Return to Dashboard',
                  onPressed: () => _showPasskeyDialog(context, provider),
                ),
              ],
              child: _WaitingForGrantView(message: provider.statusMessage),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _showPasskeyDialog(context, provider);
          },
          child: Stack(
            children: <Widget>[
              MachineScaffold(
                title: 'Private Voting Mode',
                subtitle: 'Secure session active. Review candidates carefully before confirming each position.',
                showSidebar: false,
                useSafeArea: false,
                darkModeProgress: provider.privacyOverlay,
                child: _StepWizardView(provider: provider),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    color: Colors.black.withAlpha(
                      ((1 - provider.brightnessLevel) * 200).round(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPasskeyDialog(
    BuildContext context,
    BallotProvider provider,
  ) async {
    final controller = TextEditingController();

    final entered = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: MachineTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text(
            'Officer Authorization',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Enter the officer passkey to leave the ballot terminal.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Passkey',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MachineTheme.primaryDeep,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );

    if (entered == null || !context.mounted) return;

    if (provider.verifyOfficerPasskey(entered)) {
      await FullscreenHelper.exit();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: MachineTheme.darkSurface,
          content: Text('Invalid officer passkey. Access denied.'),
        ),
      );
    }
  }
}

class _WaitingForGrantView extends StatelessWidget {
  final String message;

  const _WaitingForGrantView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MachineTheme.primary.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(
                  color: MachineTheme.primary.withAlpha(60),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 36,
                color: MachineTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Waiting For Officer Grant',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step-by-Step Wizard View
// Shows ONE position at a time with a stepper at the top.
// ---------------------------------------------------------------------------
class _StepWizardView extends StatelessWidget {
  final BallotProvider provider;

  const _StepWizardView({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final electionProvider = context.read<ElectionInitProvider>();
    final currentElectionId = provider.currentElectionId;
    if (currentElectionId == null) {
      return const Center(child: Text('No positions available.'));
    }

    final election = electionProvider.elections.firstWhere(
      (e) => e.electionId == currentElectionId,
      orElse: () => electionProvider.elections.first,
    );
    final candidates = provider.candidatesFor(currentElectionId);
    final selectedId = provider.selectedCandidateFor(currentElectionId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 980
            ? 4
            : constraints.maxWidth > 700
                ? 3
                : 2;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            // Stepper bar at top
            _StepperBar(provider: provider, electionProvider: electionProvider),
            const SizedBox(height: 24),
            // Current position title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: MachineTheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          election.office,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          election.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: MachineTheme.warning.withAlpha(28),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MachineTheme.warning.withAlpha(40),
                      ),
                    ),
                    child: Text(
                      'Screen ${(provider.brightnessLevel * 100).round()}%',
                      style: TextStyle(
                        color: MachineTheme.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Candidates grid for this position only
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final isSelected = selectedId == candidate.candidateId;

                return _SecureCandidateCard(
                  candidate: candidate,
                  isSelected: isSelected,
                  progress: provider.privacyOverlay,
                  onTap: () => provider.selectCandidate(currentElectionId, candidate.candidateId),
                );
              },
            ),
            const SizedBox(height: 24),
            // Confirm & Continue / Cast Final Vote button
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          selectedId == null
                              ? 'Select one candidate for ${election.office}'
                              : provider.isLastStep
                                  ? 'Final position selected. Ready to cast all votes.'
                                  : 'Selection confirmed for ${election.office}.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          selectedId == null
                              ? 'Tap a candidate card to make your selection.'
                              : provider.isLastStep
                                  ? 'All positions reviewed. Press the button to cast your votes.'
                                  : 'Tap the button to confirm and proceed to the next position.',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MachineTheme.primaryDeep,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    onPressed: selectedId == null || provider.isSubmitting
                        ? null
                        : () => _confirmStep(context, provider, electionProvider),
                    icon: provider.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            provider.isLastStep
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                    label: Text(
                      provider.isLastStep ? 'Cast Final Vote' : 'Confirm & Continue',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmStep(
    BuildContext context,
    BallotProvider provider,
    ElectionInitProvider electionProvider,
  ) async {
    if (provider.isLastStep) {
      // Show final confirmation dialog with all selections
      final summaries = <String>[];
      for (final entry in provider.selectedCandidates.entries) {
        final electionId = entry.key;
        final candidateId = entry.value;
        final election = electionProvider.elections.firstWhere(
          (e) => e.electionId == electionId,
        );
        final candidate = provider.candidatesFor(electionId).firstWhere(
          (c) => c.candidateId == candidateId,
        );
        summaries.add('• ${election.office}: ${candidate.fullName}');
      }

      final confirmed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Confirm All Votes',
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, _, _) => const SizedBox.shrink(),
        transitionBuilder: (context, animation, _, _) {
          return Transform.scale(
            scale: Tween<double>(begin: 0.92, end: 1).animate(animation).value,
            child: Opacity(
              opacity: animation.value,
              child: AlertDialog(
                backgroundColor: MachineTheme.darkSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                title: const Text(
                  'Confirm All Your Votes',
                  style: TextStyle(color: Colors.white),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'You selected the following candidates. This action cannot be changed after submission.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ...summaries.map((summary) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        summary,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Review Again'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MachineTheme.primaryDeep,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm All Votes'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (confirmed != true || !context.mounted) return;
    }

    await provider.confirmCurrentStep();
    if (!context.mounted) return;

    if (!provider.hasOfficerGrant) {
      // All votes cast, show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: MachineTheme.darkSurface,
          content: Text('All votes recorded successfully.'),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Stepper Bar
// ---------------------------------------------------------------------------
class _StepperBar extends StatelessWidget {
  final BallotProvider provider;
  final ElectionInitProvider electionProvider;

  const _StepperBar({
    required this.provider,
    required this.electionProvider,
  });

  @override
  Widget build(BuildContext context) {
    final totalSteps = provider.totalSteps;
    final currentStep = provider.currentStepIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final election = electionProvider.elections.firstWhere(
            (e) => e.electionId == provider.activeElectionIds[index],
            orElse: () => electionProvider.elections.first,
          );

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? MachineTheme.success
                              : isCurrent
                                  ? MachineTheme.primary
                                  : Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent
                                ? MachineTheme.primary
                                : Colors.white.withAlpha(30),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : Colors.white60,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        election.office,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : isCompleted
                                  ? MachineTheme.success
                                  : Colors.white60,
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: index < currentStep
                          ? MachineTheme.success.withAlpha(80)
                          : Colors.white.withAlpha(20),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Candidate Card
// ---------------------------------------------------------------------------
class _SecureCandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool isSelected;
  final double progress;
  final VoidCallback onTap;

  const _SecureCandidateCard({
    required this.candidate,
    required this.isSelected,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.lerp(const Color(0xFFEDE9FF), const Color(0xFF3B3F6B), progress)
              : Color.lerp(const Color(0xFFF8F9FC), const Color(0xFF252B45), progress),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Color.lerp(MachineTheme.primary, Colors.white.withAlpha(80), progress)!
                : Color.lerp(MachineTheme.border, Colors.white.withAlpha(20), progress)!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: MachineTheme.primary.withAlpha(40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CandidateAvatar(
                  title: candidate.fullName,
                  imageUrl: candidate.photoUrl,
                  size: 56,
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? MachineTheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? MachineTheme.primary : Colors.white.withAlpha(40),
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              candidate.fullName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.lerp(MachineTheme.text, Colors.white, progress),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              candidate.className ?? candidate.position ?? '',
              style: TextStyle(
                color: Color.lerp(MachineTheme.muted, Colors.white70, progress),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(0xFFEDE9FF),
                  Colors.white.withAlpha(15),
                  progress,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                candidate.bio ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color.lerp(MachineTheme.muted, Colors.white60, progress),
                  height: 1.35,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
