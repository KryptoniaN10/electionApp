import '../machine_models/audit/audit_log_model.dart';
import '../machine_models/audit/vote_backup_model.dart';
import '../machine_models/auth/session_model.dart';
import '../machine_models/class/class_model.dart';
import '../machine_models/election/candidate_model.dart';
import '../machine_models/election/election_model.dart';
import '../machine_models/machine/machine_settings_model.dart';
import '../machine_models/session/poll_session_model.dart';
import '../machine_models/state/machine_state_model.dart';

class MachineFakeData {
  static MachineState machineState() {
    return MachineState(
      machineId: 1,
      machineCode: 'VM-CH-01',
      health: MachineHealth.ready,
      firebaseConnected: false,
      printerConnected: true,
      biometricReady: true,
      batteryPercent: 92,
      lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 18)),
      firmwareVersion: 'v1.4.2',
    );
  }

  static PollSession pollSession() {
    return PollSession(
      sessionId: 401,
      electionId: 77,
      machineId: 1,
      grantedBy: 18,
      voterId: null,
      sessionToken: 'poll-77-session-401',
      startTime: DateTime.now().subtract(const Duration(minutes: 16)),
      endTime: null,
      sessionStatus: SessionStatus.active,
      durationSeconds: 960,
      qrCodeHash: 'QR-77-AX11',
    );
  }

  static Session officerSession() {
    return Session(
      sessionToken: 'secure-session-18',
      userId: 18,
      machineId: 1,
      createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      isValid: true,
    );
  }

  static List<Election> elections() {
    return <Election>[
      Election(
        electionId: 77,
        title: 'Student Council General Election',
        description: 'Central booth for chairperson voting.',
        office: 'Chairperson',
        classId: 12,
        officerId: 18,
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 7)),
        status: ElectionStatus.open,
        totalVoters: 480,
        votesCast: 143,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isVerified: true,
      ),
      Election(
        electionId: 78,
        title: 'School Councillor Election',
        description: 'Class representative and student welfare roles.',
        office: 'School Councillor',
        classId: 12,
        officerId: 18,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 6)),
        status: ElectionStatus.open,
        totalVoters: 480,
        votesCast: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        isVerified: true,
      ),
      Election(
        electionId: 79,
        title: 'Sports Manager Election',
        description: 'Sports council leadership and event coordination.',
        office: 'Sports Manager',
        classId: 12,
        officerId: 18,
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        status: ElectionStatus.open,
        totalVoters: 480,
        votesCast: 56,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isVerified: true,
      ),
      Election(
        electionId: 80,
        title: 'Cultural Secretary Election',
        description: 'Arts and cultural event management.',
        office: 'Cultural Secretary',
        classId: 12,
        officerId: 18,
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        status: ElectionStatus.pending,
        totalVoters: 480,
        votesCast: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        isVerified: false,
      ),
    ];
  }

  static List<Candidate> candidatesForElection(int electionId) {
    final allCandidates = <Candidate>[
      // Election 77: Chairperson candidates
      Candidate(
        candidateId: 1,
        electionId: 77,
        userId: 901,
        position: 'Chairperson',
        bio: 'Student welfare and budget transparency.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
        firstName: 'Aarav',
        lastName: 'Menon',
        photoUrl: 'https://example.com/candidate-aarav.jpg',
        className: 'Final Year',
      ),
      Candidate(
        candidateId: 2,
        electionId: 77,
        userId: 902,
        position: 'Chairperson',
        bio: 'Accessibility, clubs, and campus safety.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
        firstName: 'Diya',
        lastName: 'Varma',
        photoUrl: 'https://example.com/candidate-diya.jpg',
        className: 'Final Year',
      ),
      Candidate(
        candidateId: 3,
        electionId: 77,
        userId: 903,
        position: 'Chairperson',
        bio: 'Stronger communication between students and faculty.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
        firstName: 'Noel',
        lastName: 'Joseph',
        photoUrl: 'https://example.com/candidate-noel.jpg',
        className: 'Final Year',
      ),
      Candidate(
        candidateId: 4,
        electionId: 77,
        userId: 904,
        position: 'Chairperson',
        bio: 'Academic support, grievance response, and event funding.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
        firstName: 'Sara',
        lastName: 'James',
        photoUrl: 'https://example.com/candidate-sara.jpg',
        className: 'Final Year',
      ),
      // Election 78: School Councillor candidates
      Candidate(
        candidateId: 5,
        electionId: 78,
        userId: 905,
        position: 'School Councillor',
        bio: 'Bridging the gap between students and administration.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        isVerified: true,
        firstName: 'Rahul',
        lastName: 'Nair',
        photoUrl: 'https://example.com/candidate-rahul.jpg',
        className: 'Third Year',
      ),
      Candidate(
        candidateId: 6,
        electionId: 78,
        userId: 906,
        position: 'School Councillor',
        bio: 'Mental health awareness and student support programs.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        isVerified: true,
        firstName: 'Priya',
        lastName: 'Sharma',
        photoUrl: 'https://example.com/candidate-priya.jpg',
        className: 'Third Year',
      ),
      Candidate(
        candidateId: 7,
        electionId: 78,
        userId: 907,
        position: 'School Councillor',
        bio: 'Infrastructure improvement and hostel welfare.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        isVerified: true,
        firstName: 'Kiran',
        lastName: 'Das',
        photoUrl: 'https://example.com/candidate-kiran.jpg',
        className: 'Third Year',
      ),
      // Election 79: Sports Manager candidates
      Candidate(
        candidateId: 8,
        electionId: 79,
        userId: 908,
        position: 'Sports Manager',
        bio: 'Inter-college sports tournament coordination.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isVerified: true,
        firstName: 'Vikram',
        lastName: 'Singh',
        photoUrl: 'https://example.com/candidate-vikram.jpg',
        className: 'Second Year',
      ),
      Candidate(
        candidateId: 9,
        electionId: 79,
        userId: 909,
        position: 'Sports Manager',
        bio: 'Fitness programs and sports equipment funding.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isVerified: true,
        firstName: 'Ananya',
        lastName: 'Patel',
        photoUrl: 'https://example.com/candidate-ananya.jpg',
        className: 'Second Year',
      ),
      Candidate(
        candidateId: 10,
        electionId: 79,
        userId: 910,
        position: 'Sports Manager',
        bio: 'Athlete development and coach liaison.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isVerified: true,
        firstName: 'Arjun',
        lastName: 'Rao',
        photoUrl: 'https://example.com/candidate-arjun.jpg',
        className: 'Second Year',
      ),
      // Election 80: Cultural Secretary candidates
      Candidate(
        candidateId: 11,
        electionId: 80,
        userId: 911,
        position: 'Cultural Secretary',
        bio: 'Annual day planning and cultural fest organization.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
        firstName: 'Meera',
        lastName: 'Iyer',
        photoUrl: 'https://example.com/candidate-meera.jpg',
        className: 'Final Year',
      ),
      Candidate(
        candidateId: 12,
        electionId: 80,
        userId: 912,
        position: 'Cultural Secretary',
        bio: 'Music club and drama society support.',
        voteCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
        firstName: 'Karthik',
        lastName: 'Venkat',
        photoUrl: 'https://example.com/candidate-karthik.jpg',
        className: 'Final Year',
      ),
    ];
    return allCandidates.where((c) => c.electionId == electionId).toList();
  }

  // Legacy: kept for backward compatibility
  static Election election() => elections().first;
  static List<Candidate> candidates() => candidatesForElection(77);

  static List<VoterClass> voterClasses() {
    return <VoterClass>[
      VoterClass(
        classId: 12,
        name: 'BSc Computer Science',
        section: 'A',
        tierLabel: 'Tier 1',
        isAuthorized: true,
        eligibleVoters: 160,
      ),
      VoterClass(
        classId: 13,
        name: 'BSc Computer Science',
        section: 'B',
        tierLabel: 'Tier 1',
        isAuthorized: true,
        eligibleVoters: 155,
      ),
      VoterClass(
        classId: 14,
        name: 'BCA',
        section: 'A',
        tierLabel: 'Tier 2',
        isAuthorized: false,
        eligibleVoters: 165,
      ),
    ];
  }

  static MachineSettings settings() {
    return MachineSettings(
      settingId: 22,
      machineId: 1,
      screenBrightness: 0.82,
      timeoutMinutes: 5,
      allowDashboard: true,
      theme: 'secure-indigo',
      audioEnabled: true,
      officerPasskey: 'VM-2024-OFFICER',
    );
  }

  static List<AuditLog> logs() {
    return <AuditLog>[
      AuditLog(
        entryId: 1,
        userId: 18,
        action: 'OFFICER_AUTH_SUCCESS',
        electionId: 77,
        details: 'Officer PIN validated on terminal VM-CH-01.',
        ipAddress: '127.0.0.1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        logHash: 'hash-001',
        severity: AuditSeverity.info,
      ),
      AuditLog(
        entryId: 2,
        userId: 18,
        action: 'BALLOT_CONFIG_REVIEW',
        electionId: 77,
        details: 'Candidate roster reviewed before booth unlock.',
        ipAddress: '127.0.0.1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        logHash: 'hash-002',
        severity: AuditSeverity.info,
      ),
      AuditLog(
        entryId: 3,
        userId: 18,
        action: 'SYNC_PENDING',
        electionId: 77,
        details: 'Cloud transport unavailable. Local queue retained.',
        ipAddress: '127.0.0.1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        logHash: 'hash-003',
        severity: AuditSeverity.warning,
      ),
    ];
  }

  static List<VoteBackup> backups() {
    return <VoteBackup>[
      VoteBackup(
        backupId: 1,
        voteId: 7001,
        voteData: <String, dynamic>{'encrypted': true},
        backupTimestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        backupSource: 'local_cache',
        recoveryStatus: BackupStatus.pending,
      ),
      VoteBackup(
        backupId: 2,
        voteId: 7002,
        voteData: <String, dynamic>{'encrypted': true},
        backupTimestamp: DateTime.now().subtract(const Duration(minutes: 11)),
        backupSource: 'local_cache',
        recoveryStatus: BackupStatus.restored,
      ),
      VoteBackup(
        backupId: 3,
        voteId: 7003,
        voteData: <String, dynamic>{'encrypted': true},
        backupTimestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        backupSource: 'local_cache',
        recoveryStatus: BackupStatus.pending,
      ),
    ];
  }
}
