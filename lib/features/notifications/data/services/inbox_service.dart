import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/notifications/data/models/app_notification.dart';

final Provider<InboxService> inboxServiceProvider = Provider<InboxService>(
  (ref) => InboxService(ref.watch(firebaseFirestoreProvider)),
);

/// Reads and updates a user's notification inbox at
/// users/{uid}/notifications. The app can read, mark read and delete; only the
/// Cloud Functions create entries (see `firestore.rules`).
class InboxService {
  InboxService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// The latest notifications, newest first, live.
  Stream<List<AppNotification>> watch(String uid, {int limit = 50}) {
    return _refs
        .notifications(uid)
        .orderBy(NotificationFields.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return [
            for (final doc in snapshot.docs)
              AppNotification.fromFirestore(doc.id, doc.data()),
          ];
        });
  }

  Future<void> markRead(String uid, Iterable<String> ids) {
    final batch = _refs.notifications(uid).firestore.batch();
    for (final id in ids) {
      batch.update(_refs.notifications(uid).doc(id), {
        NotificationFields.read: true,
      });
    }
    return batch.commit();
  }

  Future<void> delete(String uid, String id) {
    return _refs.notifications(uid).doc(id).delete();
  }
}
