// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for your project
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web configuration
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Android Firebase options
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBiGBo1RM80NSXLg0o1HSdinuVWaTHygbQ',
    appId: '1:649810225974:android:54f0315631c2e096d72197',
    messagingSenderId: '649810225974',
    projectId: 'project-76d44',
    storageBucket: 'project-76d44.firebasestorage.app',
  );

  /// iOS Firebase options
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '<YOUR_IOS_API_KEY>',
    appId: '<YOUR_IOS_APP_ID>',
    messagingSenderId: '<YOUR_IOS_MESSAGING_SENDER_ID>',
    projectId: 'project-76d44',
    storageBucket: 'project-76d44.firebasestorage.app',
  );

  /// Web Firebase options
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBiGBo1RM80NSXLg0o1HSdinuVWaTHygbQ',
    appId: '1:649810225974:web:<YOUR_WEB_APP_ID>',
    messagingSenderId: '649810225974',
    projectId: 'project-76d44',
    storageBucket: 'project-76d44.firebasestorage.app',
  );
}
