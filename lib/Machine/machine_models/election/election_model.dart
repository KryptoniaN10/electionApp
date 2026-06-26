class Election {
  final int electionId;
  final String title;
  final String? description;
  final String office;
  final int classId;
  final int officerId;
  final DateTime startTime;
  final DateTime endTime;
  final ElectionStatus status;
  final int totalVoters;
  final int votesCast;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  Election({
    required this.electionId,
    required this.title,
    this.description,
    required this.office,
    required this.classId,
    required this.officerId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalVoters,
    required this.votesCast,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
  });

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      electionId: json['election_id'],
      title: json['title'],
      description: json['description'],
      office: json['office'],
      classId: json['class_id'],
      officerId: json['officer_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: ElectionStatus.fromString(json['status']),
      totalVoters: json['total_voters'],
      votesCast: json['votes_cast'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'election_id': electionId,
      'title': title,
      'description': description,
      'office': office,
      'class_id': classId,
      'officer_id': officerId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'total_voters': totalVoters,
      'votes_cast': votesCast,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
    };
  }
}

enum ElectionStatus {
  pending,
  open,
  closed,
  archived;

  static ElectionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ElectionStatus.pending;
      case 'open':
        return ElectionStatus.open;
      case 'closed':
        return ElectionStatus.closed;
      case 'archived':
        return ElectionStatus.archived;
      default:
        return ElectionStatus.pending;
    }
  }
}