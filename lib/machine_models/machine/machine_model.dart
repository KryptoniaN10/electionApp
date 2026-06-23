class Machine {
  final int machineId;
  final String machineName;
  final String location;
  final String ipAddress;
  final MachineStatus status;
  final String macAddress;
  final DateTime lastHeartbeat;
  final String osVersion;
  final String clientVersion;
  final DateTime createdAt;

  Machine({
    required this.machineId,
    required this.machineName,
    required this.location,
    required this.ipAddress,
    required this.status,
    required this.macAddress,
    required this.lastHeartbeat,
    required this.osVersion,
    required this.clientVersion,
    required this.createdAt,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      machineId: json['machine_id'],
      machineName: json['machine_name'],
      location: json['location'],
      ipAddress: json['ip_address'],
      status: MachineStatus.fromString(json['status']),
      macAddress: json['mac_address'],
      lastHeartbeat: DateTime.parse(json['last_heartbeat']),
      osVersion: json['os_version'],
      clientVersion: json['client_version'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machine_id': machineId,
      'machine_name': machineName,
      'location': location,
      'ip_address': ipAddress,
      'status': status.toString().split('.').last,
      'mac_address': macAddress,
      'last_heartbeat': lastHeartbeat.toIso8601String(),
      'os_version': osVersion,
      'client_version': clientVersion,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum MachineStatus {
  active,
  inactive,
  maintenance,
  voting;

  static MachineStatus fromString(String value) {
    switch (value) {
      case 'active':
        return MachineStatus.active;
      case 'inactive':
        return MachineStatus.inactive;
      case 'maintenance':
        return MachineStatus.maintenance;
      case 'voting':
        return MachineStatus.voting;
      default:
        return MachineStatus.inactive;
    }
  }
}