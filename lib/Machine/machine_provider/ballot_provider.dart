import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../machine_data/machine_fake_data.dart';
import '../machine_models/audit/audit_log_model.dart';
import '../machine_models/election/candidate_model.dart';
import '../machine_models/election/vote_model.dart';
import '../services/local_backup_service.dart';
import '../utils/fullscreen_helper.dart';

class BallotProvider extends ChangeNotifier {
  BallotProvider() {
    loadBallot();
  }

  final LocalBackupService _backup = LocalBackupService.getInstance();

  // Candidates grouped by election ID
  Map<int, List<Candidate>> _electionCandidates = <int, List<Candidate>>{};
  // Selected candidate per election: electionId -> candidateId
  Map<int, int> _selectedCandidates = <int, int>{};
  // Active election IDs for current ballot session (ordered)
  List<int> _activeElectionIds = <int>[];

  // Step-by-step wizard: which position the voter is currently on
  int _currentStepIndex = 0;
  // Track which steps have been confirmed
  Set<int> _confirmedSteps = <int>{};

  bool _isBoothReady = true;
  bool _isSubmitting = false;
  bool _hasOfficerGrant = false;
  double _privacyOverlay = 0.0;
  double _brightnessLevel = 1.0;
  String _statusMessage = 'Booth sanitized and ready for the next voter.';

  // Timer for gradual dimming while voting
  Timer? _dimTimer;
  static const int _dimDurationSeconds = 30; // Dims over 60 seconds
  static const double _minBrightness = 0.30;

  Map<int, List<Candidate>> get electionCandidates => _electionCandidates;
  Map<int, int> get selectedCandidates => _selectedCandidates;
  List<int> get activeElectionIds => _activeElectionIds;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _activeElectionIds.length;
  bool get isBoothReady => _isBoothReady;
  bool get isSubmitting => _isSubmitting;
  bool get hasOfficerGrant => _hasOfficerGrant;
  double get privacyOverlay => _privacyOverlay;
  double get brightnessLevel => _brightnessLevel;
  String get statusMessage => _statusMessage;

  /// Current election being voted on
  int? get currentElectionId {
    if (_currentStepIndex < _activeElectionIds.length) {
      return _activeElectionIds[_currentStepIndex];
    }
    return null;
  }

  /// True if on the last step
  bool get isLastStep => _currentStepIndex >= _activeElectionIds.length - 1;

  /// True if current step is confirmed
  bool get isCurrentStepConfirmed =>
      _confirmedSteps.contains(_currentStepIndex);

  String? _officerPasskey;
  String? get officerPasskey => _officerPasskey;

  void setOfficerPasskey(String? passkey) {
    _officerPasskey = passkey;
  }

  bool verifyOfficerPasskey(String input) {
    if (_officerPasskey == null || _officerPasskey!.isEmpty) return false;
    return _officerPasskey == input.trim();
  }

  Future<void> loadBallot({List<int>? electionIds}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (electionIds != null && electionIds.isNotEmpty) {
      _activeElectionIds = electionIds;
      _electionCandidates = <int, List<Candidate>>{};
      for (final id in electionIds) {
        _electionCandidates[id] = MachineFakeData.candidatesForElection(id);
      }
    } else {
      _activeElectionIds = [77];
      _electionCandidates[77] = MachineFakeData.candidatesForElection(77);
    }

    _selectedCandidates = <int, int>{};
    _currentStepIndex = 0;
    _confirmedSteps = <int>{};
    notifyListeners();
  }

  void authorizeNextVoter() {
    _isBoothReady = true;
    _selectedCandidates = <int, int>{};
    _currentStepIndex = 0;
    _confirmedSteps = <int>{};
    _statusMessage = 'Authorization cleared. Voter may proceed.';
    notifyListeners();
  }

  Future<void> setOfficerGrant(bool value) async {
    _hasOfficerGrant = value;
    _isBoothReady = value;
    _privacyOverlay = 0.0;
    _brightnessLevel = 1.0;
    _statusMessage = value
        ? 'Secure voting mode active. This screen is locked for the voter session.'
        : 'Waiting for officer grant';

    notifyListeners();

    if (value) {
      await FullscreenHelper.enter();
      // Start with full brightness, then gradually dim over time
      _startDimmingTimer();
    } else {
      _stopDimmingTimer();
      await FullscreenHelper.exit();
      _privacyOverlay = 0.0;
      _brightnessLevel = 1.0;
      await _restoreBrightness();
      notifyListeners();
    }
  }

  /// Starts a timer that gradually dims brightness over 60 seconds.
  void _startDimmingTimer() {
    _stopDimmingTimer(); // Safety
    final tickMs =
        (_dimDurationSeconds * 1000) ~/ 30; // 30 ticks over the duration
    var tick = 0;

    _dimTimer = Timer.periodic(Duration(milliseconds: tickMs), (timer) async {
      tick++;
      final progress = tick / 30;
      _privacyOverlay = progress;
      _brightnessLevel = 1.0 - (progress * (1.0 - _minBrightness));

      try {
        await ScreenBrightness.instance.setApplicationScreenBrightness(
          _brightnessLevel,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Brightness dim failed: $e');
      }

      notifyListeners();

      if (tick >= 30) {
        timer.cancel();
      }
    });
  }

  void _stopDimmingTimer() {
    _dimTimer?.cancel();
    _dimTimer = null;
  }

  /// Select a candidate for the current election.
  void selectCandidate(int electionId, int candidateId) {
    // Only allow selection if this is the current step's election
    final currentId = currentElectionId;
    if (currentId != electionId) return;
    _selectedCandidates[electionId] = candidateId;
    notifyListeners();
  }

  /// Confirm the current step and advance to the next position.
  Future<void> confirmCurrentStep() async {
    final currentId = currentElectionId;
    if (currentId == null || !_selectedCandidates.containsKey(currentId)) {
      return;
    }

    _confirmedSteps.add(_currentStepIndex);

    if (isLastStep) {
      // All positions confirmed, cast all votes
      await _castAllVotes();
    } else {
      // Advance to next position
      _currentStepIndex++;
      notifyListeners();
    }
  }

  Future<void> _castAllVotes() async {
    _isSubmitting = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1000));

    // Save each vote to local Hive backup
    var voteId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final entry in _selectedCandidates.entries) {
      final electionId = entry.key;
      final candidateId = entry.value;
      await _backup.saveVoteBackup(
        voteId: voteId++,
        electionId: electionId,
        candidateId: candidateId,
        officerPasskey: _officerPasskey ?? 'unknown',
      );
    }

    // Log audit event
    await _backup.saveAuditLog(
      entryId: DateTime.now().millisecondsSinceEpoch,
      action: 'VOTE_CAST',
      details:
          'Voter cast ${_selectedCandidates.length} vote(s) via secure terminal.',
      electionId: _activeElectionIds.firstOrNull,
      severity: AuditSeverity.info,
    );

    // TODO(firebase): submit all encrypted ballots and write receipts to Firestore.
    final response = VoteResponse(
      success: true,
      message:
          'All votes recorded successfully for ${_selectedCandidates.length} position(s).',
      voteId: 8001,
      receipt: 'RCPT-8001',
    );

    _isSubmitting = false;
    _isBoothReady = false;
    _hasOfficerGrant = false;
    _privacyOverlay = 0.0;
    _brightnessLevel = 1.0;
    _statusMessage = 'Ballot secured. Officer must authorize the next voter.';
    _selectedCandidates = <int, int>{};
    _currentStepIndex = 0;
    _confirmedSteps = <int>{};
    _stopDimmingTimer();
    await FullscreenHelper.exit();
    await _restoreBrightness();
    notifyListeners();
  }

  /// Returns the selected candidate ID for a specific election, or null.
  int? selectedCandidateFor(int electionId) => _selectedCandidates[electionId];

  /// Returns the list of candidates for a specific election.
  List<Candidate> candidatesFor(int electionId) =>
      _electionCandidates[electionId] ?? <Candidate>[];

  /// Restores screen brightness to maximum (1.0) when session ends.
  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (e) {
      if (kDebugMode) debugPrint('Brightness restore failed: $e');
    }
  }
}
