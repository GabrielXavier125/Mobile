import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Use `--dart-define=USAR_EMULADOR=true` para apontar para o emulador local
/// do Firestore (firebase emulators:start) durante o desenvolvimento.
const usarEmulador = bool.fromEnvironment('USAR_EMULADOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (usarEmulador) {
    // 10.0.2.2 é o endereço do computador visto de dentro do emulador Android.
    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  }

  runApp(const MinhaAplicacao());
}
