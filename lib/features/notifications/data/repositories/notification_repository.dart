import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/notifications/data/models/app_notification.dart';
import 'package:mae_assignment/features/notifications/data/services/inbox_service.dart';
import 'package:mae_assignment/features/notifications/data/services/push_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    ref.watch(inboxServiceProvider),
    ref.watch(pushServiceProvider),
  );
});

/// Error with a message that is safe to show on screen.
class NotificationException extends AppException {
  const NotificationException(super.message);
}

/// Push notifications and the in-app inbox.
///
/// Push is best effort: a phone without Google Play services, a refused
/// permission or a missing network must never stop someone signing in or out,
/// so registering and unregistering swallow their errors (and log them).
class NotificationRepository {
  NotificationRepository(this._inbox, this._push);

  final InboxService _inbox;
  final PushService _push;

  // ---------------------------------------------------------------------
  // Push
  // ---------------------------------------------------------------------

  /// Asks permission and registers this phone for [uid]'s pushes. Returns
  /// whether the phone is registered.
  Future<bool> registerDevice(String uid) async {
    try {
      if (!await _push.requestPermission()) return false;
      final token = await _push.token();
      if (token == null) return false;
      await _push.saveDevice(uid, token);
      return true;
    } on Object catch (error) {
      debugPrint('Could not register for push notifications: $error');
      return false;
    }
  }

  /// Re-registers when FCM replaces the phone's token.
  Stream<String> get tokenRefreshes => _push.tokenRefreshes;

  Future<void> saveToken(String uid, String token) async {
    try {
      await _push.saveDevice(uid, token);
    } on Object catch (error) {
      debugPrint('Could not save the new push token: $error');
    }
  }

  /// Stops pushes to this phone. Call it before signing out.
  Future<void> unregisterDevice() async {
    try {
      await _push.removeThisDevice().timeout(const Duration(seconds: 5));
    } on Object catch (error) {
      debugPrint('Could not unregister this phone from push: $error');
    }
  }

  /// Order ids of notifications the user tapped.
  Stream<String> openedOrderIds() => _push.openedOrderIds();

  // ---------------------------------------------------------------------
  // Inbox
  // ---------------------------------------------------------------------

  Stream<List<AppNotification>> watchInbox(String uid) => _inbox.watch(uid);

  Future<void> markRead(String uid, Iterable<String> ids) {
    return guard(
      () => _inbox.markRead(uid, ids),
      label: 'mark notifications read',
      onError: () => const NotificationException(
        'Could not update your notifications. Please try again.',
      ),
    );
  }

  Future<void> delete(String uid, String id) {
    return guard(
      () => _inbox.delete(uid, id),
      label: 'delete notification',
      onError: () => const NotificationException(
        'Could not remove the notification. Please try again.',
      ),
    );
  }
}
