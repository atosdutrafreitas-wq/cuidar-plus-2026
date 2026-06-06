// Configurado automaticamente para o projeto cuidar-plus-2026
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBelmzymw5VPi2GWYZXw1KIBSOLqpKYFE',
    appId: '1:331101525752:web:d2e870a36915dd2a984d0d',
    messagingSenderId: '331101525752',
    projectId: 'cuidar-plus-2026',
    authDomain: 'cuidar-plus-2026.firebaseapp.com',
    storageBucket: 'cuidar-plus-2026.firebasestorage.app',
  );

  // Android e iOS: configurar após gerar google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBelmzymw5VPi2GWYZXw1KIBSOLqpKYFE',
    appId: '1:331101525752:android:000000000000000000',
    messagingSenderId: '331101525752',
    projectId: 'cuidar-plus-2026',
    storageBucket: 'cuidar-plus-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBelmzymw5VPi2GWYZXw1KIBSOLqpKYFE',
    appId: '1:331101525752:ios:000000000000000000',
    messagingSenderId: '331101525752',
    projectId: 'cuidar-plus-2026',
    storageBucket: 'cuidar-plus-2026.firebasestorage.app',
    iosBundleId: 'com.cuidarplus.app',
  );
}
