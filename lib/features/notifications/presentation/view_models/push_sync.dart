import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/core/firebase/firebase_emulators.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/notifications/data/repositories/notification_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// Keeps this phone registered for push notifications while someone is signed
/// in, and opens the order when they tap a notification. Watched once from the
/// app root, like the cart sync.
///
/// - Sign-in (or app start with a live session): asks for the notification
///   permission and registers the phone's token for that account.
/// - A replaced token is registered again.
/// - Sign-out removes the registration (see `AuthRepository.signOut`).
/// - Tapping a notification opens that order: a customer's tracking page,
///   or a worker's delivery or packing screen.
///
/// Off when running against the Firebase emulators: they cannot send pushes,
/// and the system permission dialog would get in the way of automated tests.
final Provider<void> pushSyncProvider = Provider<void>((ref) {
  if (FirebaseEmulators.enabled) return;

  String? uid;
  StreamSubscription<String>? tokens;
  StreamSubscription<String>? opens;

  Future<void> start(String forUid) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final registered = await repository.registerDevice(forUid);
      if (!registered || uid != forUid) return;
      await tokens?.cancel();
      tokens = repository.tokenRefreshes.listen(
        (token) => unawaited(repository.saveToken(forUid, token)),
      );
    } on Object catch (error) {
      // Push is best effort; the app works without it.
      debugPrint('Push notifications are unavailable: $error');
    }
  }

  Future<void> openOrder(String orderId) async {
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      final router = ref.read(appRouterProvider);
      switch (user?.role) {
        case UserRole.customer:
          router.go(AppRoutes.customerOrder(orderId));
        case UserRole.storeWorker:
          // Workers are told about new assignments: a driver opens the
          // delivery, a packer the order to pack.
          final worker = ref.read(workerSessionProvider);
          if (worker == null) return;
          unawaited(
            router.push(
              worker.isDeliveryDriver
                  ? AppRoutes.workerDeliveryOrder(orderId)
                  : AppRoutes.workerPackingOrder(orderId),
            ),
          );
        case UserRole.storeAdmin:
        case null:
          return;
      }
    } on Object catch (error) {
      debugPrint('Could not open the order from a notification: $error');
    }
  }

  ref.listen<AsyncValue<String?>>(authUidProvider, (previous, next) {
    if (!next.hasValue) return;
    final nextUid = next.value;
    if (nextUid == uid) return;
    uid = nextUid;
    unawaited(tokens?.cancel());
    tokens = null;
    if (nextUid == null) return;
    unawaited(start(nextUid));
    try {
      opens ??= ref
          .read(notificationRepositoryProvider)
          .openedOrderIds()
          .listen(
            (id) => unawaited(openOrder(id)),
            onError: (Object error) => debugPrint('Notification tap: $error'),
          );
    } on Object catch (error) {
      debugPrint('Notification taps are unavailable: $error');
    }
  }, fireImmediately: true);

  ref.onDispose(() {
    unawaited(tokens?.cancel());
    unawaited(opens?.cancel());
  });
});
