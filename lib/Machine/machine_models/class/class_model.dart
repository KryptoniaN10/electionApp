class VoterClass {
  final int classId;
  final String name;
  final String section;
  final String tierLabel;
  final bool isAuthorized;
  final int eligibleVoters;

  VoterClass({
    required this.classId,
    required this.name,
    required this.section,
    required this.tierLabel,
    required this.isAuthorized,
    required this.eligibleVoters,
  });

  factory VoterClass.fromJson(Map<String, dynamic> json) {
    return VoterClass(
      classId: json['class_id'],
      name: json['name'],
      section: json['section'],
      tierLabel: json['tier_label'],
      isAuthorized: json['is_authorized'],
      eligibleVoters: json['eligible_voters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'name': name,
      'section': section,
      'tier_label': tierLabel,
      'is_authorized': isAuthorized,
      'eligible_voters': eligibleVoters,
    };
  }
}
