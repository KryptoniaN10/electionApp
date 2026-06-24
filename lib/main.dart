import 'package:electionapp/firebasetest.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'election_officer/views/screens/officer_login_screen.dart';

import 'machine_provider/audit_logs_provider.dart';
import 'machine_provider/auth_provider.dart';
import 'machine_provider/ballot_provider.dart';
import 'machine_provider/dashboard_provider.dart';
import 'machine_provider/election_init_provider.dart';
import 'machine_provider/machine_settings_provider.dart';

import 'machine_view/screens/audit_logs_screen.dart';
import 'machine_view/screens/ballot_screen.dart';
import 'machine_view/screens/dashboard_screen.dart';
import 'machine_view/screens/election_init_screen.dart';
import 'machine_view/screens/machine_settings_screen.dart';
import 'machine_view/widgets/machine_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ElectionInitProvider()),
        ChangeNotifierProvider(create: (_) => BallotProvider()),
        ChangeNotifierProvider(create: (_) => MachineSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuditLogsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MachineTheme.materialTheme(),
        routes: {
          '/dashboard': (context) {
            final auth = Provider.of<AuthProvider>(context, listen: false);

            if (!auth.isAuthenticated) {
              return const OfficerLoginScreen();
            }

            return const DashboardScreen();
          },
          '/election-init': (context) => const ElectionInitScreen(),
          '/ballot': (context) => const BallotScreen(),
          '/settings': (context) => const MachineSettingsScreen(),
          '/audit-logs': (context) => const AuditLogsScreen(),
          '/officer-login': (context) => const OfficerLoginScreen(),
        },
        home: const OfficerLoginScreen(),
      ),
    );
  }
}
