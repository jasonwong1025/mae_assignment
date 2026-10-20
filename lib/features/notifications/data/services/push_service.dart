import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';

final Provider<PushService> pushServiceProvider = Provider<PushService>(
  (ref) => PushService(ref.watch(firebaseFirestoreProvider)),
);

/// Firebase Cloud Messaging on this phone, and the list of phones kept at
/// users/{uid}/devices so the Cloud Functions know where to send a push.
class PushService {
  PushService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Asks for permission to show notifications (Android 13+ and iOS ask the
  /// user; older Android allows it). True if allowed.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// This phone's FCM token, or null if it has none (for example no Google
  /// Play services).
  Future<String?> token() => _messaging.getToken();

  /// A new token, when FCM replaces the old one.
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  /// Order ids of notifications the user tapped, including the one that
  /// launched the app from a closed state.
  Stream<String> openedOrderIds() async* {
    final initial = await _messaging.getInitialMessage();
    final first = initial?.data['orderId'];
    if (first is String) yield first;
    await for (final message in FirebaseMessaging.onMessageOpenedApp) {
      final id = message.data['orderId'];
      if (id is String) yield id;
    }
  }

  /// Registers [token] for [uid]'s account.
  Future<void> saveDevice(String uid, String token) {
    return _refs.device(uid, token).set({
      DeviceFields.platform: _platform,
      DeviceFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  /// Stops sending pushes for the signed-in account to this phone. Must run
  /// before sign-out, while the rules still know who is asking.
  Future<void> removeThisDevice() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _messaging.getToken();
    if (token != null) await _refs.device(uid, token).delete();
    // A fresh token for the next person who signs in on this phone.
    await _messaging.deleteToken();
  }

  String get _platform {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }
}
