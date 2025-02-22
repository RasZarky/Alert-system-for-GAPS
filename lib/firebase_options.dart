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
    apiKey: 'AIzaSyDBoZKCGYoaXrSYpXQ3JbGIXL8xBRyr-eA',
    appId: '1:624565380252:web:79de6817f7e6fb41c4b959',
    messagingSenderId: '624565380252',
    projectId: 'alert-system-for-gaps1',
    authDomain: 'alert-system-for-gaps1.firebaseapp.com',
    storageBucket: 'alert-system-for-gaps1.appspot.com',
    measurementId: 'G-6PM36TM860',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCykk3T888eXQGTlLl2x5PCld1BIlWeqlU',
    appId: '1:624565380252:android:9c2aa1245d3b0282c4b959',
    messagingSenderId: '624565380252',
    projectId: 'alert-system-for-gaps1',
    storageBucket: 'alert-system-for-gaps1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYis7AIBzixOkSHFIw-DziFbZ2Y_sTXBQ',
    appId: '1:624565380252:ios:621ae6449f9c9089c4b959',
    messagingSenderId: '624565380252',
    projectId: 'alert-system-for-gaps1',
    storageBucket: 'alert-system-for-gaps1.appspot.com',
    iosBundleId: 'com.example.alertSystemForGaps',
  );
}
