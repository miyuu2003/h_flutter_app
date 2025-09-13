// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDCZXjV8NN7r05UTKb_v81I-tG4xmQWZmg',
        appId: '1:421981148735:web:b3ad2370a247dfa3868a8a',
        messagingSenderId: '421981148735',
        projectId: 'flutter-h-4e8cf',
        authDomain: 'flutter-h-4e8cf.firebaseapp.com',
        storageBucket: 'flutter-h-4e8cf.firebasestorage.app',
        measurementId: 'G-70ECWVX02K', // 任意。analytics使わなければ未使用
      );
    }

    // 将来 iOS/Android を追加するならここにそれぞれの FirebaseOptions を書く
    return const FirebaseOptions(
      apiKey: 'AIzaSyDCZXjV8NN7r05UTKb_v81I-tG4xmQWZmg',
      appId: '1:421981148735:web:b3ad2370a247dfa3868a8a',
      messagingSenderId: '421981148735',
      projectId: 'flutter-h-4e8cf',
      storageBucket: 'flutter-h-4e8cf.firebasestorage.app',
    );
  }
}
