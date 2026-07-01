import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Firebase configuration options for the legal-59a45 project.
/// Generated manually from Firebase Console config.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCc4UOhXCzjaIgbXVl090rO37YvpXeQLXc',
    authDomain: 'legal-59a45.firebaseapp.com',
    projectId: 'legal-59a45',
    storageBucket: 'legal-59a45.firebasestorage.app',
    messagingSenderId: '147070559691',
    appId: '1:147070559691:web:d0099901b8983a2d22424e',
  );

  // Android — register in Firebase Console and replace this placeholder
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCc4UOhXCzjaIgbXVl090rO37YvpXeQLXc',
    appId: '1:147070559691:web:d0099901b8983a2d22424e',
    messagingSenderId: '147070559691',
    projectId: 'legal-59a45',
    storageBucket: 'legal-59a45.firebasestorage.app',
  );

  // iOS — register in Firebase Console and replace this placeholder
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCc4UOhXCzjaIgbXVl090rO37YvpXeQLXc',
    appId: '1:147070559691:web:d0099901b8983a2d22424e',
    messagingSenderId: '147070559691',
    projectId: 'legal-59a45',
    storageBucket: 'legal-59a45.firebasestorage.app',
    iosBundleId: 'com.legalassistant.delhi',
  );
}
