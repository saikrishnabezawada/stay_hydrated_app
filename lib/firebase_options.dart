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
    apiKey: 'AIzaSyBDORbr_kZ6Rt6m-tuDJzmIaPhWKO2LoBI',
    appId: '1:186611607660:web:32e3263b2cfba0e01f1049',
    messagingSenderId: '186611607660',
    projectId: 'dehydration-monitoring-app',
    authDomain: 'dehydration-monitoring-app.firebaseapp.com',
    databaseURL: 'https://dehydration-monitoring-app-default-rtdb.firebaseio.com',
    storageBucket: 'dehydration-monitoring-app.appspot.com',
    measurementId: 'G-X5J6LCZNT2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUz033cLZBl1a3qgbesG-KMhppBVFdMXE',
    appId: '1:186611607660:android:35e025120aa68a6c1f1049',
    messagingSenderId: '186611607660',
    projectId: 'dehydration-monitoring-app',
    databaseURL: 'https://dehydration-monitoring-app-default-rtdb.firebaseio.com',
    storageBucket: 'dehydration-monitoring-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnxGmXgHOENbzWl6VGS24KVQO2ftrsMrU',
    appId: '1:186611607660:ios:e5f598ee73c7e3751f1049',
    messagingSenderId: '186611607660',
    projectId: 'dehydration-monitoring-app',
    databaseURL: 'https://dehydration-monitoring-app-default-rtdb.firebaseio.com',
    storageBucket: 'dehydration-monitoring-app.appspot.com',
    androidClientId: '186611607660-gg73qqa7gku6ju2j5pqlhqleaudqc9l2.apps.googleusercontent.com',
    iosClientId: '186611607660-5lj4pkua1u1568f9jec4ve70k8sqijm0.apps.googleusercontent.com',
    iosBundleId: 'com.example.stayHydratedApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnxGmXgHOENbzWl6VGS24KVQO2ftrsMrU',
    appId: '1:186611607660:ios:717f82d5d2cbab461f1049',
    messagingSenderId: '186611607660',
    projectId: 'dehydration-monitoring-app',
    databaseURL: 'https://dehydration-monitoring-app-default-rtdb.firebaseio.com',
    storageBucket: 'dehydration-monitoring-app.appspot.com',
    androidClientId: '186611607660-gg73qqa7gku6ju2j5pqlhqleaudqc9l2.apps.googleusercontent.com',
    iosClientId: '186611607660-hr5c8hdr7bb9bu4v2estrg1a2ho1jl6h.apps.googleusercontent.com',
    iosBundleId: 'com.example.stayHydratedApp.RunnerTests',
  );
}