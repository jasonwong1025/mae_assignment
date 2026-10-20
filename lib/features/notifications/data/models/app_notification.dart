import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'app_notification.freezed.dart';

/// One entry of the in-app notification inbox. The Cloud Functions add an
/// entry (and send a push) when an order changes; the inbox keeps it for
/// customers who missed or turned off the push.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String body,

    /// The order it is about, so tapping opens its tracking page.
    String? orderId,
    @Default(false) bool isRead,

    /// Null until Firestore has saved the server time.
    DateTime? createdAt,
  }) = _AppNotification;

  const AppNotification._();

  factory AppNotification.fromFirestore(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data.string(NotificationFields.title),
      body: data.string(NotificationFields.body),
      orderId: data.stringOrNull(NotificationFields.orderId),
      isRead: data.boolean(NotificationFields.read, fallback: false),
      createdAt: data.dateTime(NotificationFields.createdAt),
    );
  }
}
