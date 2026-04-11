import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
    apiKey: 'AIzaSyDrIadwf9VCvfnbnZeaa75aqO8wY4oGFG4',
    appId: '1:267634249559:web:d662411a44aa9755023812',
    messagingSenderId: '267634249559',
    projectId: 'krishilink-e7c6a',
    authDomain: 'krishilink-e7c6a.firebaseapp.com',
    storageBucket: 'krishilink-e7c6a.firebasestorage.app',
    measurementId: 'G-GV3221WZXC',
  );

  // IMPORTANT: Replace appId below with your Android App ID from Firebase Console
  // → Project Settings → Your Apps → Android app → App ID
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrIadwf9VCvfnbnZeaa75aqO8wY4oGFG4',
    appId: '1:267634249559:android:REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: '267634249559',
    projectId: 'krishilink-e7c6a',
    storageBucket: 'krishilink-e7c6a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrIadwf9VCvfnbnZeaa75aqO8wY4oGFG4',
    appId: '1:267634249559:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '267634249559',
    projectId: 'krishilink-e7c6a',
    storageBucket: 'krishilink-e7c6a.firebasestorage.app',
    iosBundleId: 'com.example.krishilink',
  );
}
