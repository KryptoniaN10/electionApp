class ElectionModel {
  final int electionId;
  final String title;
  final String? description;
  final String? office;
  final int? classId;
  final int? officerId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status; // upcoming, active, completed, cancelled
  final int totalVoters;
  final int votesCast;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  ElectionModel({
    required this.electionId,
    required this.title,
    this.description,
    this.office,
    this.classId,
    this.officerId,
    this.startTime,
    this.endTime,
    required this.status,
    this.totalVoters = 0,
    this.votesCast = 0,
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  });

  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    return ElectionModel(
      electionId: json['election_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      office: json['office'],
      classId: json['class_id'],
      officerId: json['officer_id'],
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      status: json['status'] ?? 'upcoming',
      totalVoters: json['total_voters'] ?? 0,
      votesCast: json['votes_cast'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
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
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'total_voters': totalVoters,
      'votes_cast': votesCast,
      'is_verified': isVerified,
    };
  }
}