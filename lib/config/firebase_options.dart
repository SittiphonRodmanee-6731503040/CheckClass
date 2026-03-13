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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD_8c_oa1Z33_MszkwtWTqtOqKVJhoE7Zo',
    appId: '1:13506351200:web:d67614500d2399256f3305',
    messagingSenderId: '13506351200',
    projectId: 'classcheck-1c46b',
    authDomain: 'classcheck-1c46b.firebaseapp.com',
    storageBucket: 'classcheck-1c46b.firebasestorage.app',
  );

  // Android and iOS will use google-services.json / GoogleService-Info.plist
  // For now, use the same config as web (replace when native apps are configured)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_8c_oa1Z33_MszkwtWTqtOqKVJhoE7Zo',
    appId: '1:13506351200:web:d67614500d2399256f3305',
    messagingSenderId: '13506351200',
    projectId: 'classcheck-1c46b',
    storageBucket: 'classcheck-1c46b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_8c_oa1Z33_MszkwtWTqtOqKVJhoE7Zo',
    appId: '1:13506351200:web:d67614500d2399256f3305',
    messagingSenderId: '13506351200',
    projectId: 'classcheck-1c46b',
    storageBucket: 'classcheck-1c46b.firebasestorage.app',
    iosBundleId: 'com.classcheck.classcheck',
  );
}
