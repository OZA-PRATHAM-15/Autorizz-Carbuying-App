// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAeH6BBgZ9nZ5Ty0ifV1sG6__zLNfDdbsg',
    appId: '1:891284376887:web:bc1a34deb104c42dde5eb2',
    messagingSenderId: '891284376887',
    projectId: 'carbuyingapp-4883c',
    authDomain: 'carbuyingapp-4883c.firebaseapp.com',
    storageBucket: 'carbuyingapp-4883c.appspot.com',
    measurementId: 'G-HPYDE0G6CZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_dNU_rLU4d4s-lNoid8MFvMTEhzqF928',
    appId: '1:891284376887:android:b7d3dfc89be1a64fde5eb2',
    messagingSenderId: '891284376887',
    projectId: 'carbuyingapp-4883c',
    storageBucket: 'carbuyingapp-4883c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxFni0-b1RC0UC7_hMZ61rs-k-183KC4o',
    appId: '1:891284376887:ios:229baee3d5c68a10de5eb2',
    messagingSenderId: '891284376887',
    projectId: 'carbuyingapp-4883c',
    storageBucket: 'carbuyingapp-4883c.appspot.com',
    iosBundleId: 'com.example.carBuyingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBxFni0-b1RC0UC7_hMZ61rs-k-183KC4o',
    appId: '1:891284376887:ios:229baee3d5c68a10de5eb2',
    messagingSenderId: '891284376887',
    projectId: 'carbuyingapp-4883c',
    storageBucket: 'carbuyingapp-4883c.appspot.com',
    iosBundleId: 'com.example.carBuyingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAeH6BBgZ9nZ5Ty0ifV1sG6__zLNfDdbsg',
    appId: '1:891284376887:web:5e4fb7faa499e1cede5eb2',
    messagingSenderId: '891284376887',
    projectId: 'carbuyingapp-4883c',
    authDomain: 'carbuyingapp-4883c.firebaseapp.com',
    storageBucket: 'carbuyingapp-4883c.appspot.com',
    measurementId: 'G-XJWL66XG0E',
  );
}
