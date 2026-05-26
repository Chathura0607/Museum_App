import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3xUzikMvN066uHxBoUGenRhwMt5_Lnvc',
    appId: '1:1092050575632:web:df4997e8169dad07720595',
    messagingSenderId: '1092050575632',
    projectId: 'smart-museum-app-c5d4c',
    authDomain: 'smart-museum-app-c5d4c.firebaseapp.com',
    storageBucket: 'smart-museum-app-c5d4c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3xUzikMvN066uHxBoUGenRhwMt5_Lnvc',
    appId: '1:1092050575632:ios:cc4a977b262cc3ad720595',
    messagingSenderId: '1092050575632',
    projectId: 'smart-museum-app-c5d4c',
    authDomain: 'smart-museum-app-c5d4c.firebaseapp.com',
    storageBucket: 'smart-museum-app-c5d4c.firebasestorage.app',
    iosBundleId: 'com.example.museumApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3xUzikMvN066uHxBoUGenRhwMt5_Lnvc',
    appId: '1:1092050575632:android:0ac71abb9f5a863f720595',
    messagingSenderId: '1092050575632',
    projectId: 'smart-museum-app-c5d4c',
    authDomain: 'smart-museum-app-c5d4c.firebaseapp.com',
    storageBucket: 'smart-museum-app-c5d4c.firebasestorage.app',
  );
}
