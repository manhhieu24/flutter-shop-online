import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBEYrJTZl8XrKqhbW21-CBW-qyZTT1wC4s',
    appId: '1:244680804313:web:6e7e2f9abe841ad206fbc8',
    messagingSenderId: '244680804313',
    projectId: 'shop-online-bd413',
    authDomain: 'shop-online-bd413.firebaseapp.com',
    storageBucket: 'shop-online-bd413.appspot.com',
    measurementId: 'G-P8LSGYY3WH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuSiBF7mkkFy94xIjqP5TA3_odG7oybPQ',
    appId: '1:244680804313:android:a1771885a28ae0a406fbc8',
    messagingSenderId: '244680804313',
    projectId: 'shop-online-bd413',
    storageBucket: 'shop-online-bd413.appspot.com',
  );

}