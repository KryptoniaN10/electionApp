class CandidateModel {
  final int candidateId;
  final int electionId;
  final int userId;
  final String? position;
  final String? bio;
  final int voteCount;
  final DateTime? createdAt;
  final bool isVerified;

  CandidateModel({
    required this.candidateId,
    required this.electionId,
    required this.userId,
    this.position,
    this.bio,
    this.voteCount = 0,
    this.createdAt,
    this.isVerified = false,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      candidateId: json['candidate_id'] ?? 0,
      electionId: json['election_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      position: json['position'],
      bio: json['bio'],
      voteCount: json['vote_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidate_id': candidateId,
      'election_id': electionId,
      'user_id': userId,
      'position': position,
      'bio': bio,
      'vote_count': voteCount,
      'is_verified': isVerified,
    };
  }
}