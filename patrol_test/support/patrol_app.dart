import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/core/firebase/firebase_emulators.dart';
import 'package:mae_assignment/firebase_options.dart';
import 'package:patrol/patrol.dart';

/// Boots the real app inside a Patrol test.
///
/// This mirrors `lib/main.dart` but follows Patrol's rules: it must not call
/// `WidgetsFlutterBinding.ensureInitialized()` or `runApp()` (Patrol pumps
/// the widget itself), and it must not touch `FlutterError.onError`.
///
/// Firebase is pointed at the local Emulator Suite. Run the test with
/// `--dart-define=USE_FIREBASE_EMULATOR=true` (and, on a physical device,
/// `--dart-define=FIREBASE_EMULATOR_HOST=<host-ip>`), so it never touches
/// the shared project.
Future<void> launchApp(PatrolIntegrationTester $) async {
  // Firebase.initializeApp is safe to call once; a hot-restarted test run
  // may already have an app, so tolerate the duplicate.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  FirebaseEmulators.connect();
  // Every test starts signed out, whatever the test before it left behind.
  await FirebaseAuth.instance.signOut();

  await _pumpApp($);
}

/// Simulates the user closing and reopening the app.
///
/// Patrol cannot kill and relaunch the app process from inside a test, so
/// this does what Patrol's maintainers suggest for resetting Dart-side
/// state: attach a fresh root widget. The new [ProviderScope] has a new key,
/// so every provider (cart, selected branch, router) starts from scratch,
/// exactly as after a cold start. Firebase keeps its saved sign-in, as it
/// does across real restarts.
Future<void> restartApp(PatrolIntegrationTester $) => _pumpApp($);

// pumpWidget (not ...AndSettle): the catalogue's Firestore reads have their
// own timeouts, so settling here could block on pending async work before
// the test even starts. The individual steps wait as needed.
Future<void> _pumpApp(PatrolIntegrationTester $) {
  return $.pumpWidget(
    ProviderScope(key: UniqueKey(), child: const GrocerlyApp()),
  );
}
