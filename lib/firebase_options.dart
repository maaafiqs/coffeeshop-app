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
    apiKey: 'AIzaSyCdULfh3YzIr3gpTH6lhGE4sn03xhBLLHs',
    appId: '1:896625269653:web:f7d868e7187ab63041b49c',
    messagingSenderId: '896625269653',
    projectId: 'coffeeshop-app-ee1f3',
    authDomain: 'coffeeshop-app-ee1f3.firebaseapp.com',
    storageBucket: 'coffeeshop-app-ee1f3.firebasestorage.app',
    measurementId: 'G-0VYMMCN69N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdULfh3YzIr3gpTH6lhGE4sn03xhBLLHs',
    appId: '1:896625269653:web:f7d868e7187ab63041b49c',
    messagingSenderId: '896625269653',
    projectId: 'coffeeshop-app-ee1f3',
    authDomain: 'coffeeshop-app-ee1f3.firebaseapp.com',
    storageBucket: 'coffeeshop-app-ee1f3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdULfh3YzIr3gpTH6lhGE4sn03xhBLLHs',
    appId: '1:896625269653:web:f7d868e7187ab63041b49c',
    messagingSenderId: '896625269653',
    projectId: 'coffeeshop-app-ee1f3',
    authDomain: 'coffeeshop-app-ee1f3.firebaseapp.com',
    storageBucket: 'coffeeshop-app-ee1f3.firebasestorage.app',
  );
}
