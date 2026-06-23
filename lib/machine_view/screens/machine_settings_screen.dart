import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../machine_provider/machine_settings_provider.dart';
import '../widgets/machine_ui.dart';

class MachineSettingsScreen extends StatelessWidget {
  const MachineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MachineSettingsProvider>(
      builder: (context, provider, _) {
        final settings = provider.settings;

        return MachineScaffold(
          title: 'Machine Settings',
          subtitle: 'Restricted controls for diagnostics, local cleanup, and sync recovery.',
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
          child: settings == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    MachineCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionTitle(
                            title: 'System Controls',
                            subtitle: 'Local toggles only for now. Firebase persistence stays commented until setup is complete.',
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            value: provider.printerDiagnostics,
                            onChanged: provider.setPrinterDiagnostics,
                            title: const Text('Hardware Peripheral Diagnostics'),
                            subtitle: const Text('Run live checks for printer and terminal attachments.'),
                          ),
                          SwitchListTile(
                            value: provider.clearDebugData,
                            onChanged: provider.setClearDebugData,
                            title: const Text('Clear Local Debug Structures'),
                            subtitle: const Text('Prepare local cache cleanup on next maintenance cycle.'),
                          ),
                          SwitchListTile(
                            value: provider.clockSyncEnabled,
                            onChanged: provider.setClockSyncEnabled,
                            title: const Text('Manual Clock Sync Adjustments'),
                            subtitle: const Text('Keep timestamp alignment active for secure logs.'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Screen brightness ${(settings.screenBrightness * 100).round()}%',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Slider(
                            value: settings.screenBrightness,
                            onChanged: (v) => provider.setBrightness(v), // Fire-and-forget async
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    MachineCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionTitle(
                            title: 'Emergency Sync Triggers',
                            subtitle: 'Push local cache streams manually when automatic sync lags.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: provider.triggerManualSync,
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Trigger Manual Sync'),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              provider.lastSyncMessage,
                              style: const TextStyle(color: MachineTheme.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
