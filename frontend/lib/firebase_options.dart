// Isabela
//(Gerado via FlutterFire CLI)
// OBJETIVO: Guardar as chaves de acesso senhas/tokens

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// chama quando o app liga
class DefaultFirebaseOptions {
  //metodo 'currentPlatform' descobre onde o app esta rodando (web, android, iOS)
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; //usa as chaves da web
    }

    // testa qual é o sistema operacional(cll, pc)
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCdRNTr7bDWA8_JMD1j9bEIdIVREwn33kU',
    appId: '1:696645311566:web:262642b6ec4224f562771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    authDomain: 'pi-3--mescla-invest.firebaseapp.com',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    measurementId: 'G-B5W3JSPEYB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOiDdJl8swPGfy8OLQTz2boyZ19fo5I1U',
    appId: '1:696645311566:android:990b5a04d47eacf262771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVY18Woc3V9BPjmo28NvPuq0dFGQRkNZc',
    appId: '1:696645311566:ios:393bb380c9e23bbf62771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVY18Woc3V9BPjmo28NvPuq0dFGQRkNZc',
    appId: '1:696645311566:ios:393bb380c9e23bbf62771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdRNTr7bDWA8_JMD1j9bEIdIVREwn33kU',
    appId: '1:696645311566:web:8ff7261d8c8dd63362771f',
    messagingSenderId: '696645311566',
    projectId: 'pi-3--mescla-invest',
    authDomain: 'pi-3--mescla-invest.firebaseapp.com',
    storageBucket: 'pi-3--mescla-invest.firebasestorage.app',
    measurementId: 'G-F7Y8CK12Z2',
  );

}