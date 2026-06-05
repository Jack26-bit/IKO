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
    apiKey: 'AIzaSyD4frcO5Z6mvCdi6kj1ncTLmyLt20O_ap0',
    appId: '1:95416362981:web:ef1b432a008c6e70eff10c',
    messagingSenderId: '95416362981',
    projectId: 'iko-db-fb7db',
    authDomain: 'iko-db-fb7db.firebaseapp.com',
    databaseURL: 'https://iko-db-fb7db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iko-db-fb7db.firebasestorage.app',
    measurementId: 'G-FMKP8PSZNW',
  );

  // Note: Since only web configuration was provided, using the same for Android/iOS for now.
  // Ideally, you should run `flutterfire configure` to generate the accurate native options.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4frcO5Z6mvCdi6kj1ncTLmyLt20O_ap0',
    appId: '1:95416362981:web:ef1b432a008c6e70eff10c',
    messagingSenderId: '95416362981',
    projectId: 'iko-db-fb7db',
    databaseURL: 'https://iko-db-fb7db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iko-db-fb7db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4frcO5Z6mvCdi6kj1ncTLmyLt20O_ap0',
    appId: '1:95416362981:web:ef1b432a008c6e70eff10c',
    messagingSenderId: '95416362981',
    projectId: 'iko-db-fb7db',
    databaseURL: 'https://iko-db-fb7db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iko-db-fb7db.firebasestorage.app',
  );
}
