class Candidate {
  final int candidateId;
  final int electionId;
  final int userId;
  final String? position;
  final String? bio;
  final int voteCount;
  final DateTime createdAt;
  final bool isVerified;
  
  // Additional fields (from user)
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final String? className;

  Candidate({
    required this.candidateId,
    required this.electionId,
    required this.userId,
    this.position,
    this.bio,
    required this.voteCount,
    required this.createdAt,
    required this.isVerified,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.className,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      candidateId: json['candidate_id'],
      electionId: json['election_id'],
      userId: json['user_id'],
      position: json['position'],
      bio: json['bio'],
      voteCount: json['vote_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isVerified: json['is_verified'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      photoUrl: json['photo_url'],
      className: json['class_name'],
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
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'class_name': className,
    };
  }

  String get fullName => '$firstName $lastName';
}