// Kiosk lockdown helper for mobile and web.
// On mobile: SystemChrome.immersiveSticky (hides status bar + nav bar, auto-rehides on swipe).
// On web:    dart:html fullscreen API (via conditional stub).

// import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FullscreenHelper {
  /// Enter kiosk lockdown. Hides all system UI and locks orientation.
  static Future<void> enter() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Exit kiosk lockdown. Restores system UI and unlocks orientation.
  static Future<void> exit() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
