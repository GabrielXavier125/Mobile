// ARQUIVO PROVISÓRIO — será substituído pelo comando `flutterfire configure`.
// Enquanto isso, o app só funciona com o emulador local do Firestore
// (flutter run --dart-define=USAR_EMULADOR=true). Veja PROXIMOS_PASSOS_FIREBASE.md.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'provisorio',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-mapa-locais',
  );
}
