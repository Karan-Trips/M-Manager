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
        return macos;
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
    apiKey: 'AIzaSyB2XFe_g8OTABNcyI4bH5Jiun4FdlGRsm4',
    appId: '1:379977880468:web:01e7cab075381ae567b581',
    messagingSenderId: '379977880468',
    projectId: 'money-manager-d20bf',
    authDomain: 'money-manager-d20bf.firebaseapp.com',
    storageBucket: 'money-manager-d20bf.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwkAJhllxJDtDUkvawzBYlo5deeLWVS4I',
    appId: '1:379977880468:android:34b9d02a2657da1a67b581',
    messagingSenderId: '379977880468',
    projectId: 'money-manager-d20bf',
    storageBucket: 'money-manager-d20bf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhhwjQ8GZWPskEKNZR7__Exbu95fmlD_8',
    appId: '1:379977880468:ios:8532bbf7943137de67b581',
    messagingSenderId: '379977880468',
    projectId: 'money-manager-d20bf',
    storageBucket: 'money-manager-d20bf.appspot.com',
    iosBundleId: 'com.example.try1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBhhwjQ8GZWPskEKNZR7__Exbu95fmlD_8',
    appId: '1:379977880468:ios:82e2c03b00d9b70667b581',
    messagingSenderId: '379977880468',
    projectId: 'money-manager-d20bf',
    storageBucket: 'money-manager-d20bf.appspot.com',
    iosBundleId: 'com.example.try1.RunnerTests',
  );
}
