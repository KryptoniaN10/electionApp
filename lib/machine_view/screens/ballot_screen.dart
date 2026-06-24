import 'package:flutter/material.dart';
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
    if (state == AppLifecycleState.resumed) {
      _showLockdownDialog(context.read<BallotProvider>());
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
          children: [
            Icon(Icons.security_rounded, color: MachineTheme.warning, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Kiosk Lockdown Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ],
        ),
        content: const Text('You exited the secure voting area. Full-screen mode is required.', style: TextStyle(color: Colors.white70)),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MachineTheme.primaryDeep),
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
            onPopInvokedWithResult: (didPop, _) async {
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
                  onPressed: () => _showPasskeyDialog(context, provider),
                ),
              ],
              child: _WaitingForGrantView(message: provider.statusMessage),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _showPasskeyDialog(context, provider);
          },
          child: Stack(
            children: [
              MachineScaffold(
                title: 'Private Voting Mode',
                subtitle: 'Secure session active. Review candidates carefully.',
                showSidebar: false,
                useSafeArea: false,
                darkModeProgress: provider.privacyOverlay,
                child: _StepWizardView(provider: provider),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    color: Colors.black.withAlpha(((1 - provider.brightnessLevel) * 200).round()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPasskeyDialog(BuildContext context, BallotProvider provider) async {
    final controller = TextEditingController();
    final entered = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MachineTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text('Officer Authorization', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the officer passkey to leave the ballot terminal.', style: TextStyle(color: Colors.white70)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MachineTheme.primaryDeep),
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (entered == null || !context.mounted) return;

    if (provider.verifyOfficerPasskey(entered)) {
      await FullscreenHelper.exit();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid officer passkey.')));
    }
  }
}

// ---------------------------------------------------------------------------
// Waiting View
// ---------------------------------------------------------------------------
class _WaitingForGrantView extends StatelessWidget {
  final String message;
  const _WaitingForGrantView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: MachineTheme.primary.withAlpha(30), shape: BoxShape.circle, border: Border.all(color: MachineTheme.primary.withAlpha(60), width: 2)),
              child: Icon(Icons.verified_user_outlined, size: 36, color: MachineTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text('Waiting For Officer Grant', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main Voting View
// ---------------------------------------------------------------------------
class _StepWizardView extends StatelessWidget {
  final BallotProvider provider;

  const _StepWizardView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final electionProvider = context.read<ElectionInitProvider>();
    final currentElectionId = provider.currentElectionId;
    if (currentElectionId == null) return const Center(child: Text('No positions available.'));

    final election = electionProvider.elections.firstWhere(
      (e) => e.electionId == currentElectionId,
      orElse: () => electionProvider.elections.first,
    );

    final candidates = provider.candidatesFor(currentElectionId);
    final selectedId = provider.selectedCandidateFor(currentElectionId);

    final columns = screenWidth > 1100 ? 4 : screenWidth > 800 ? 3 : isMobile ? 1 : 2;

    return ListView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      children: [
        _StepperBar(provider: provider, electionProvider: electionProvider, isMobile: isMobile),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(width: 4, height: 28, decoration: BoxDecoration(color: MachineTheme.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(election.office, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                    Text(election.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: isMobile ? 12 : 14,
            mainAxisSpacing: isMobile ? 12 : 14,
            childAspectRatio: isMobile ? 0.75 : 0.82,
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
        _ConfirmBar(provider: provider, election: election),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper
// ---------------------------------------------------------------------------
class _StepperBar extends StatelessWidget {
  final BallotProvider provider;
  final ElectionInitProvider electionProvider;
  final bool isMobile;

  const _StepperBar({required this.provider, required this.electionProvider, required this.isMobile});

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
      child: isMobile
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: List.generate(totalSteps, (i) => _buildStepItem(i, currentStep, electionProvider))),
            )
          : Row(children: List.generate(totalSteps, (i) => Expanded(child: _buildStepItem(i, currentStep, electionProvider)))),
    );
  }

  Widget _buildStepItem(int index, int currentStep, ElectionInitProvider electionProvider) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    final election = electionProvider.elections.firstWhere(
      (e) => e.electionId == provider.activeElectionIds[index],
      orElse: () => electionProvider.elections.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? MachineTheme.success : isCurrent ? MachineTheme.primary : Colors.white.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: isCurrent ? MachineTheme.primary : Colors.white.withAlpha(30), width: 2),
            ),
            child: Center(
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 18) : Text('${index + 1}', style: TextStyle(color: isCurrent ? Colors.white : Colors.white60, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),
          Text(election.office, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isCurrent ? Colors.white : isCompleted ? MachineTheme.success : Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirm Bar with Working Button
// ---------------------------------------------------------------------------
class _ConfirmBar extends StatelessWidget {
  final BallotProvider provider;
  final dynamic election;

  const _ConfirmBar({required this.provider, required this.election});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final selectedId = provider.selectedCandidateFor(provider.currentElectionId!);

    final button = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: MachineTheme.primaryDeep,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24, vertical: isMobile ? 16 : 18),
      ),
      onPressed: selectedId == null || provider.isSubmitting
          ? null
          : () => _confirmStep(context, provider, context.read<ElectionInitProvider>()),
      icon: provider.isSubmitting
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(provider.isLastStep ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded),
      label: Text(provider.isLastStep ? 'Cast Final Vote' : 'Confirm & Continue'),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            selectedId == null ? 'Select one candidate for ${election.office}' : provider.isLastStep ? 'Ready to cast all votes.' : 'Selection confirmed.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          button,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withAlpha(14), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(20))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selectedId == null ? 'Select one candidate for ${election.office}' : provider.isLastStep ? 'Final position selected.' : 'Selection confirmed.', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                Text(selectedId == null ? 'Tap a candidate to select.' : 'Press the button to continue.', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          button,
        ],
      ),
    );
  }

  Future<void> _confirmStep(BuildContext context, BallotProvider provider, ElectionInitProvider electionProvider) async {
    if (provider.isLastStep) {
      final summaries = <String>[];
      for (final entry in provider.selectedCandidates.entries) {
        final electionId = entry.key;
        final candidateId = entry.value;
        final election = electionProvider.elections.firstWhere((e) => e.electionId == electionId);
        final candidate = provider.candidatesFor(electionId).firstWhere((c) => c.candidateId == candidateId);
        summaries.add('• ${election.office}: ${candidate.fullName}');
      }

      final confirmed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionBuilder: (context, animation, _, _) => Transform.scale(
          scale: Tween<double>(begin: 0.92, end: 1).animate(animation).value,
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              backgroundColor: MachineTheme.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              title: const Text('Confirm All Your Votes', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This action cannot be changed after submission.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ...summaries.map((s) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(s, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Review Again')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MachineTheme.primaryDeep),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm All Votes'),
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed != true || !context.mounted) return;
    }

    await provider.confirmCurrentStep();
    if (!context.mounted) return;

    if (!provider.hasOfficerGrant) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All votes recorded successfully.')));
    }
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

  const _SecureCandidateCard({required this.candidate, required this.isSelected, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Color.lerp(const Color(0xFFEDE9FF), const Color(0xFF3B3F6B), progress) : Color.lerp(const Color(0xFFF8F9FC), const Color(0xFF252B45), progress),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color.lerp(MachineTheme.primary, Colors.white.withAlpha(80), progress)! : Color.lerp(MachineTheme.border, Colors.white.withAlpha(20), progress)!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CandidateAvatar(title: candidate.fullName, imageUrl: candidate.photoUrl, size: 56),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: isSelected ? MachineTheme.primary : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: isSelected ? MachineTheme.primary : Colors.white.withAlpha(40))),
                  child: Icon(Icons.check, size: 14, color: isSelected ? Colors.white : Colors.transparent),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(candidate.fullName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color.lerp(MachineTheme.text, Colors.white, progress))),
            const SizedBox(height: 6),
            Text(candidate.className ?? candidate.position ?? '', style: TextStyle(color: Color.lerp(MachineTheme.muted, Colors.white70, progress), fontSize: 13)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Color.lerp(const Color(0xFFEDE9FF), Colors.white.withAlpha(15), progress), borderRadius: BorderRadius.circular(8)),
              child: Text(candidate.bio ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color.lerp(MachineTheme.muted, Colors.white60, progress), fontSize: 11, height: 1.35)),
            ),
          ],
        ),
      ),
    );
  }
}