enum MachineHealth {
  ready,
  syncing,
  warning,
  offline;

  static MachineHealth fromString(String value) {
    switch (value) {
      case 'ready':
        return MachineHealth.ready;
      case 'syncing':
        return MachineHealth.syncing;
      case 'warning':
        return MachineHealth.warning;
      case 'offline':
        return MachineHealth.offline;
      default:
        return MachineHealth.offline;
    }
  }
}

class MachineState {
  final int machineId;
  final String machineCode;
  final MachineHealth health;
  final bool firebaseConnected;
  final bool printerConnected;
  final bool biometricReady;
  final int batteryPercent;
  final DateTime lastHeartbeat;
  final String firmwareVersion;

  MachineState({
    required this.machineId,
    required this.machineCode,
    required this.health,
    required this.firebaseConnected,
    required this.printerConnected,
    required this.biometricReady,
    required this.batteryPercent,
    required this.lastHeartbeat,
    required this.firmwareVersion,
  });

  factory MachineState.fromJson(Map<String, dynamic> json) {
    return MachineState(
      machineId: json['machine_id'],
      machineCode: json['machine_code'],
      health: MachineHealth.fromString(json['health']),
      firebaseConnected: json['firebase_connected'],
      printerConnected: json['printer_connected'],
      biometricReady: json['biometric_ready'],
      batteryPercent: json['battery_percent'],
      lastHeartbeat: DateTime.parse(json['last_heartbeat']),
      firmwareVersion: json['firmware_version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machine_id': machineId,
      'machine_code': machineCode,
      'health': health.name,
      'firebase_connected': firebaseConnected,
      'printer_connected': printerConnected,
      'biometric_ready': biometricReady,
      'battery_percent': batteryPercent,
      'last_heartbeat': lastHeartbeat.toIso8601String(),
      'firmware_version': firmwareVersion,
    };
  }
}
