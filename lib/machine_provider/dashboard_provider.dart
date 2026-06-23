import 'package:flutter/foundation.dart';

import '../machine_data/machine_fake_data.dart';
import '../machine_models/auth/session_model.dart';
import '../machine_models/session/poll_session_model.dart';
import '../machine_models/state/machine_state_model.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider() {
    loadDashboard();
  }

  MachineState? _machineState;
  PollSession? _pollSession;
  Session? _officerSession;
  bool _isPaused = false;
  bool _isLoading = false;
  bool _hasOfficerGrant = false;
  bool _ballotInitialized = false;
  String _lastActionMessage = 'System ready for officer review.';

  MachineState? get machineState => _machineState;
  PollSession? get pollSession => _pollSession;
  Session? get officerSession => _officerSession;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get hasOfficerGrant => _hasOfficerGrant;
  bool get ballotInitialized => _ballotInitialized;
  String get lastActionMessage => _lastActionMessage;

  String get boothStatusLabel {
    if (_isPaused) {
      return 'Paused';
    }

    if (_pollSession == null) {
      return 'Closed';
    }

    return _pollSession!.sessionStatus == SessionStatus.active
        ? 'Active'
        : 'Closed';
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 250));

    // TODO(firebase): replace mock state with Firestore reads.
    // final machineDoc = await FirebaseFirestore.instance
    //     .collection('machine_states')
    //     .doc('1')
    //     .get();
    _machineState = MachineFakeData.machineState();
    _pollSession = MachineFakeData.pollSession();
    _officerSession = MachineFakeData.officerSession();

    _isLoading = false;
    notifyListeners();
  }

  void initializeBallot() {
    _ballotInitialized = true;
    _isPaused = false;
    _lastActionMessage =
        'Ballot initialization received from the remote command queue.';
    notifyListeners();
  }

  void togglePauseElection() {
    _isPaused = !_isPaused;
    _lastActionMessage = _isPaused
        ? 'Voting booth paused by officer control.'
        : 'Voting booth resumed for the next voter.';
    notifyListeners();
  }

  void exportAuditLogs() {
    _lastActionMessage =
        'Audit log export queued locally. Cloud sync stays disabled until Firebase is initialized.';
    notifyListeners();
  }

  void setOfficerGrant(bool value) {
    _hasOfficerGrant = value;
    _lastActionMessage = value
        ? 'Officer grant detected. Ballot screen may enter secure privacy mode.'
        : 'Waiting for officer grant before showing the ballot.';
    notifyListeners();
  }
}
