// Configuração Web fornecida por --dart-define-from-file.
// Os valores locais do projeto original não são publicados.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError('Este exemplo está configurado para Flutter Web.');
    }
    if (web.apiKey.isEmpty ||
        web.appId.isEmpty ||
        web.messagingSenderId.isEmpty ||
        web.projectId.isEmpty) {
      throw StateError(
        'Configure firebase.local.json e execute com '
        '--dart-define-from-file=../firebase.local.json. Consulte o README.',
      );
    }
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );
}
