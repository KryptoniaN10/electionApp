class MachineSettings {
  final int settingId;
  final int machineId;
  final double screenBrightness;
  final int timeoutMinutes;
  final bool allowDashboard;
  final String theme;
  final bool audioEnabled;
  final String? officerPasskey; // TODO(firebase): fetch from Firestore officer config

  MachineSettings({
    required this.settingId,
    required this.machineId,
    required this.screenBrightness,
    required this.timeoutMinutes,
    required this.allowDashboard,
    required this.theme,
    required this.audioEnabled,
    this.officerPasskey,
  });

  factory MachineSettings.fromJson(Map<String, dynamic> json) {
    return MachineSettings(
      settingId: json['setting_id'],
      machineId: json['machine_id'],
      screenBrightness: json['screen_brightness'],
      timeoutMinutes: json['timeout_minutes'],
      allowDashboard: json['allow_dashboard'],
      theme: json['theme'],
      audioEnabled: json['audio_enabled'],
      officerPasskey: json['officer_passkey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setting_id': settingId,
      'machine_id': machineId,
      'screen_brightness': screenBrightness,
      'timeout_minutes': timeoutMinutes,
      'allow_dashboard': allowDashboard,
      'theme': theme,
      'audio_enabled': audioEnabled,
      'officer_passkey': officerPasskey,
    };
  }
}