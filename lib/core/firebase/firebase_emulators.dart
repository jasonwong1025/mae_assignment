import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
class FirebaseEmulators {
  FirebaseEmulators._();

  /// Set with `--dart-define=USE_FIREBASE_EMULATOR=true`.
  static const bool enabled = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

  static const int _authPort = 9099;
  static const int _firestorePort = 8085;

  /// The emulators always run on the developer's own machine. The Android
  /// emulator reaches that machine on 10.0.2.2; everything else (web,
  /// desktop, iOS simulator, tests) uses localhost. An override lets a real
  /// device on the same network point at the host's LAN address.
  static String get host {
    const override = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
    if (override.isNotEmpty) return override;
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    // Platform.isAndroid guards against desktop/test runs where the method
    // channel is unavailable; the kIsWeb check keeps web off this path.
    if (isAndroid && !kIsWeb && Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  /// Connects the Firebase SDKs to the emulators. Call once, right after
  /// `Firebase.initializeApp`, before any Auth or Firestore use. Safe to
  /// call when [enabled] is false; it simply does nothing.
  static void connect() {
    if (!enabled) return;

    final emulatorHost = host;
    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorHost,
      _firestorePort,
    );
    // useAuthEmulator returns a Future we intentionally do not await here;
    // connect() is a one-shot setup call made before any auth use.
    unawaited(FirebaseAuth.instance.useAuthEmulator(emulatorHost, _authPort));

    debugPrint(
      'Firebase emulators: Auth $emulatorHost:$_authPort, '
      'Firestore $emulatorHost:$_firestorePort',
    );
  }
}
