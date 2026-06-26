class Vote {
  final int voteId;
  final int electionId;
  final int voterId;
  final int candidateId;
  final String voteHash;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceFingerprint;
  final String? ballotEncrypted;

  Vote({
    required this.voteId,
    required this.electionId,
    required this.voterId,
    required this.candidateId,
    required this.voteHash,
    required this.timestamp,
    this.ipAddress,
    this.deviceFingerprint,
    this.ballotEncrypted,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      voteId: json['vote_id'],
      electionId: json['election_id'],
      voterId: json['voter_id'],
      candidateId: json['candidate_id'],
      voteHash: json['vote_hash'],
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ip_address'],
      deviceFingerprint: json['device_fingerprint'],
      ballotEncrypted: json['ballot_encrypted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vote_id': voteId,
      'election_id': electionId,
      'voter_id': voterId,
      'candidate_id': candidateId,
      'vote_hash': voteHash,
      'timestamp': timestamp.toIso8601String(),
      'ip_address': ipAddress,
      'device_fingerprint': deviceFingerprint,
      'ballot_encrypted': ballotEncrypted,
    };
  }
}

class VoteSubmission {
  final int electionId;
  final int voterId;
  final int candidateId;
  final int machineId;
  final int sessionId;
  final String voteHash;
  final String ipAddress;
  final String deviceFingerprint;

  VoteSubmission({
    required this.electionId,
    required this.voterId,
    required this.candidateId,
    required this.machineId,
    required this.sessionId,
    required this.voteHash,
    required this.ipAddress,
    required this.deviceFingerprint,
  });

  Map<String, dynamic> toJson() {
    return {
      'election_id': electionId,
      'voter_id': voterId,
      'candidate_id': candidateId,
      'machine_id': machineId,
      'session_id': sessionId,
      'vote_hash': voteHash,
      'ip_address': ipAddress,
      'device_fingerprint': deviceFingerprint,
    };
  }
}

class VoteResponse {
  final bool success;
  final String message;
  final int? voteId;
  final String? receipt;

  VoteResponse({
    required this.success,
    required this.message,
    this.voteId,
    this.receipt,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      success: json['success'],
      message: json['message'],
      voteId: json['vote_id'],
      receipt: json['receipt'],
    );
  }
}