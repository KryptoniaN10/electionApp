import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../machine_data/machine_fake_data.dart';
import '../machine_models/machine/machine_settings_model.dart';

class MachineSettingsProvider extends ChangeNotifier {
  MachineSettingsProvider() {
    loadSettings();
  }

  MachineSettings? _settings;
  bool _printerDiagnostics = true;
  bool _clearDebugData = false;
  bool _clockSyncEnabled = true;
  String _lastSyncMessage = 'Automatic sync standby mode active.';

  MachineSettings? get settings => _settings;
  bool get printerDiagnostics => _printerDiagnostics;
  bool get clearDebugData => _clearDebugData;
  bool get clockSyncEnabled => _clockSyncEnabled;
  String get lastSyncMessage => _lastSyncMessage;

  Future<void> loadSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // TODO(firebase): load machine settings document from Firestore.
    _settings = MachineFakeData.settings();
    notifyListeners();
  }

  void setPrinterDiagnostics(bool value) {
    _printerDiagnostics = value;
    notifyListeners();
  }

  void setClearDebugData(bool value) {
    _clearDebugData = value;
    notifyListeners();
  }

  void setClockSyncEnabled(bool value) {
    _clockSyncEnabled = value;
    notifyListeners();
  }

  /// Sets brightness in the model AND applies it to the actual screen.
  Future<void> setBrightness(double value) async {
    final settings = _settings;
    if (settings == null) return;

    _settings = MachineSettings(
      settingId: settings.settingId,
      machineId: settings.machineId,
      screenBrightness: value,
      timeoutMinutes: settings.timeoutMinutes,
      allowDashboard: settings.allowDashboard,
      theme: settings.theme,
      audioEnabled: settings.audioEnabled,
      officerPasskey: settings.officerPasskey,
    );

    // Apply to actual screen brightness
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } catch (e) {
      if (kDebugMode) debugPrint('Screen brightness set failed: $e');
    }

    notifyListeners();
  }

  void triggerManualSync() {
    _lastSyncMessage =
        'Manual cache sync prepared locally. Firebase push remains commented until backend setup is enabled.';
    notifyListeners();
  }
}
