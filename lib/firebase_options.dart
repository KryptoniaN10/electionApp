import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase configuration for the platforms supported by this application.
///
/// Android also reads these values from `android/app/google-services.json`.
/// Web has no equivalent native file, so its options must be supplied when
/// Firebase is initialized.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase has not been configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDRf2-vMGwV35ygVjBcRKw57p12UpRkzNs',
    appId: '1:89003103603:android:d2fe9b6f39212a9cea2106',
    messagingSenderId: '89003103603',
    projectId: 'eduvote-2d1a6',
    authDomain: 'eduvote-2d1a6.firebaseapp.com',
    storageBucket: 'eduvote-2d1a6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRf2-vMGwV35ygVjBcRKw57p12UpRkzNs',
    appId: '1:89003103603:android:d2fe9b6f39212a9cea2106',
    messagingSenderId: '89003103603',
    projectId: 'eduvote-2d1a6',
    storageBucket: 'eduvote-2d1a6.firebasestorage.app',
  );
}
