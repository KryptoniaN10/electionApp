import 'package:flutter/foundation.dart';

import '../machine_data/machine_fake_data.dart';
import '../machine_models/class/class_model.dart';
import '../machine_models/election/candidate_model.dart';
import '../machine_models/election/election_model.dart';

class ElectionInitProvider extends ChangeNotifier {
  ElectionInitProvider() {
    loadElectionConfiguration();
  }

  List<Election> _elections = <Election>[];
  Election? _election;
  List<Candidate> _candidates = <Candidate>[];
  List<VoterClass> _classes = <VoterClass>[];
  bool _isLoading = false;
  bool _isVerified = false;
  // Multi-select: set of election IDs selected by the officer
  Set<int> _selectedElectionIds = <int>{};

  List<Election> get elections => _elections;
  Election? get election => _election;
  List<Candidate> get candidates => _candidates;
  List<VoterClass> get classes => _classes;
  bool get isLoading => _isLoading;
  bool get isVerified => _isVerified;
  Set<int> get selectedElectionIds => _selectedElectionIds;

  Future<void> loadElectionConfiguration() async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 250));

    // TODO(firebase): load elections, classes, and candidates from Firestore.
    _elections = MachineFakeData.elections();
    _classes = MachineFakeData.voterClasses();
    _selectedElectionIds = <int>{}; // Reset selections

    // Auto-select all open elections by default for multi-ballot
    final openElections = _elections.where((e) => e.status == ElectionStatus.open).toList();
    for (final e in openElections) {
      _selectedElectionIds.add(e.electionId);
    }
    // Set the first as the primary (for legacy compatibility)
    if (openElections.isNotEmpty) {
      _election = openElections.first;
      _candidates = MachineFakeData.candidatesForElection(_election!.electionId);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle selection of an election (checkbox style).
  void toggleElectionSelection(int electionId) {
    if (_selectedElectionIds.contains(electionId)) {
      _selectedElectionIds.remove(electionId);
    } else {
      _selectedElectionIds.add(electionId);
    }
    _isVerified = false;
    notifyListeners();
  }

  /// Check if an election is currently selected.
  bool isElectionSelected(int electionId) => _selectedElectionIds.contains(electionId);

  /// Get the full Election objects for selected IDs.
  List<Election> get selectedElections {
    return _elections.where((e) => _selectedElectionIds.contains(e.electionId)).toList();
  }

  void verifyConfiguration() {
    _isVerified = true;
    notifyListeners();
  }

  /// Returns all open elections that the voter can participate in.
  List<Election> get openElections {
    return _elections.where((e) => e.status == ElectionStatus.open).toList();
  }

  /// Returns pending elections (not yet open for voting).
  List<Election> get pendingElections {
    return _elections.where((e) => e.status == ElectionStatus.pending).toList();
  }
}
