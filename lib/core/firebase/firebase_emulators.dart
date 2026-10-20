import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Points Firebase Auth and Cloud Firestore at the local Emulator Suite
/// instead of the shared `mae-assignment-grocerly` project.
///
/// Turned on with `--dart-define=USE_FIREBASE_EMULATOR=true`, so a normal
/// `fvm flutter run` still uses the real backend and no release build can
/// accidentally talk to a developer machine.
///
/// Ports match the `emulators` block in `firebase.json`:
/// - Auth:      9099
/// - Firestore: 8085
/// - Storage:   9199
class FirebaseEmulators {
  FirebaseEmulators._();

  /// Set with `--dart-define=USE_FIREBASE_EMULATOR=true`.
  static const bool enabled = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

  static const int _authPort = 9099;
  static const int _firestorePort = 8085;
  static const int _storagePort = 9199;
  static const int _functionsPort = 5001;

  /// True inside `flutter test` (the test runner sets FLUTTER_TEST). Used
  /// as a hard safety gate: a test must never reach the real project.
  static bool get _isUnderFlutterTest {
    if (kIsWeb) return false;
    return Platform.environment.containsKey('FLUTTER_TEST');
  }

  /// The emulators always run on the developer's own machine. The Android
  /// emulator reaches that machine on 10.0.2.2; everything else (web,
  /// desktop, iOS simulator, tests) uses localhost. An override lets a real
  /// device on the same network point at the host's LAN address.
  static String get host {
    const override = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
    if (override.isNotEmpty) return override;
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    // isAndroid excludes web before Platform.isAndroid is checked. The
    // Platform.isAndroid guard keeps desktop/test runs off this path.
    if (isAndroid && Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  /// Connects the Firebase SDKs to the emulators. Call once, right after
  /// `Firebase.initializeApp`, before any Auth or Firestore use. Safe to
  /// call when [enabled] is false; it then only runs the safety check.
  ///
  /// The safety check is deliberately a loud warning, not a force-to-
  /// emulator. A debug `fvm flutter run` against the shared project is a
  /// supported workflow (teammates use the shared test data), so we must
  /// not silently redirect it. We only make the choice impossible to miss,
  /// so nobody mutates the shared project by accident.
  static void connect() {
    if (!enabled) {
      // Hard stop: a test run must never touch the real shared project.
      if (_isUnderFlutterTest) {
        throw StateError(
          'Firebase is pointed at the real project during a test run. '
          'Run tests with --dart-define=USE_FIREBASE_EMULATOR=true, or use '
          'the in-memory fakes instead of connecting to Firebase.',
        );
      }
      _warnIfRiskyRealBackend();
      return;
    }

    final emulatorHost = host;

    // The SDK rewrites "localhost"/"127.0.0.1" to 10.0.2.2 on Android,
    // assuming an AVD. On a physical device reached over an `adb reverse`
    // tunnel the emulator really is on the device's localhost, so that
    // rewrite breaks the connection. Disable it when the host was set
    // explicitly (the override); keep the default behaviour otherwise.
    const override = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
    final automaticHostMapping = override.isEmpty;

    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorHost,
      _firestorePort,
      automaticHostMapping: automaticHostMapping,
    );
    // useAuthEmulator returns a Future we intentionally do not await here;
    // connect() is a one-shot setup call made before any auth use.
    unawaited(
      FirebaseAuth.instance.useAuthEmulator(
        emulatorHost,
        _authPort,
        automaticHostMapping: automaticHostMapping,
      ),
    );

    // Needs the Storage emulator running only when product photos are used.
    unawaited(
      FirebaseStorage.instance.useStorageEmulator(emulatorHost, _storagePort),
    );
    FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).useFunctionsEmulator(emulatorHost, _functionsPort);

    debugPrint(
      'Firebase emulators: Auth $emulatorHost:$_authPort, '
      'Firestore $emulatorHost:$_firestorePort, '
      'Storage $emulatorHost:$_storagePort '
      '(host mapping: $automaticHostMapping)',
    );
  }

  /// Prints a prominent warning in debug builds when the app is about to
  /// talk to the real shared project. Harmless in release (where hitting
  /// the real backend is correct and the flag is always off).
  static void _warnIfRiskyRealBackend() {
    if (!kDebugMode) return;
    debugPrint(
      '┌───────────────────────────────────────────────────────────────┐\n'
      '│  Firebase: using the REAL shared project (not the emulator).  │\n'
      '│  Reads and writes affect mae-assignment-grocerly.             │\n'
      '│  For local testing, run with:                                 │\n'
      '│    --dart-define=USE_FIREBASE_EMULATOR=true                    │\n'
      '└───────────────────────────────────────────────────────────────┘',
    );
  }
}
