import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Needed before calling Firebase, which uses platform code.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ProviderScope holds all Riverpod providers (ViewModels, repositories).
  runApp(const ProviderScope(child: GrocerlyApp()));
}
