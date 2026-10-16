import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/core/firebase/firebase_emulators.dart';
import 'package:mae_assignment/firebase_options.dart';

Future<void> main() async {
  // Needed before calling Firebase, which uses platform code.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Points Auth and Firestore at the local Emulator Suite when started with
  // --dart-define=USE_FIREBASE_EMULATOR=true. Does nothing otherwise.
  FirebaseEmulators.connect();

  // ProviderScope holds all Riverpod providers (ViewModels, repositories).
  runApp(const ProviderScope(child: GrocerlyApp()));
}
