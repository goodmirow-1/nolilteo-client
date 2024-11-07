// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAunyKFa8HGvavIiHGCMmmXfzO8VD-k57U',
    appId: '1:1027174806025:web:b3f6c0fa26950bfc86fed8',
    messagingSenderId: '1027174806025',
    projectId: 'nolilteo',
    authDomain: 'nolilteo.firebaseapp.com',
    storageBucket: 'nolilteo.appspot.com',
    measurementId: 'G-52VZ8NF5KS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDyRgFiUGxzt3dplihzNvVTadUOFs60Nks',
    appId: '1:1027174806025:android:a0ac50ea3a77845e86fed8',
    messagingSenderId: '1027174806025',
    projectId: 'nolilteo',
    storageBucket: 'nolilteo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLavmyZFtnvbnQOPf1T-kip6hAG7rpOKk',
    appId: '1:1027174806025:ios:ffb2ecc8cd9957f286fed8',
    messagingSenderId: '1027174806025',
    projectId: 'nolilteo',
    storageBucket: 'nolilteo.appspot.com',
    androidClientId: '1027174806025-71j515o1f2l3n3ibr6ko1bk180rkq8gk.apps.googleusercontent.com',
    iosClientId: '1027174806025-dn5261skcutiu576eir2ipiku9j5o3qf.apps.googleusercontent.com',
    iosBundleId: 'kr.sheeps.nolilteo',
  );
}