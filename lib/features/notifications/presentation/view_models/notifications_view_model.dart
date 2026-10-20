import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/notifications/data/models/app_notification.dart';
import 'package:mae_assignment/features/notifications/data/repositories/notification_repository.dart';

/// The signed-in user's notification inbox, newest first, live.
final notificationInboxProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) async* {
      final uid = await ref.watch(authUidProvider.future);
      if (uid == null) {
        yield const [];
        return;
      }
      yield* ref.watch(notificationRepositoryProvider).watchInbox(uid);
    });

/// How many notifications have not been opened, for the badge on the
/// Account screen. 0 while loading or when the inbox cannot be read.
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final inbox = ref.watch(notificationInboxProvider).value ?? const [];
  return inbox.where((notification) => !notification.isRead).length;
});

/// Actions on the inbox. Each returns an error message to show, or null if it
/// worked.
final notificationActionsProvider = Provider.autoDispose<NotificationActions>((
  ref,
) {
  return NotificationActions(ref);
});

class NotificationActions {
  NotificationActions(this._ref);

  final Ref _ref;

  Future<String?> markRead(Iterable<String> ids) {
    return _run((repository, uid) => repository.markRead(uid, ids));
  }

  Future<String?> delete(String id) {
    return _run((repository, uid) => repository.delete(uid, id));
  }

  Future<String?> _run(
    Future<void> Function(NotificationRepository repository, String uid) action,
  ) async {
    final uid = _ref.read(authUidProvider).value;
    if (uid == null) return 'Please sign in.';
    try {
      await action(_ref.read(notificationRepositoryProvider), uid);
      return null;
    } on AppException catch (error) {
      return error.message;
    }
  }
}
