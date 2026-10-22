import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/notifications/presentation/view_models/notifications_view_model.dart';
import 'package:mae_assignment/features/notifications/presentation/views/notifications_view.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

/// Bell in the Store Worker header with the number of unread notifications.
/// Opens the shared inbox, where HQ's assignments arrive ("New delivery
/// #2308"); tapping one opens the order in the worker's own screens.
class WorkerNotificationsBell extends ConsumerWidget {
  const WorkerNotificationsBell({super.key});

  void _openInbox(BuildContext context, WidgetRef ref) {
    final isDriver = ref.read(workerSessionProvider)?.isDeliveryDriver ?? false;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => NotificationsView(
          emptyMessage: isDriver
              ? 'We will tell you when HQ gives you a delivery.'
              : 'We will tell you when HQ gives you an order to pack.',
          openOrder: (inboxContext, orderId) {
            // Close the inbox, then open the order over the tabs, so Back
            // returns to where the worker was.
            final router = GoRouter.of(inboxContext);
            Navigator.of(inboxContext).pop();
            unawaited(
              router.push(
                isDriver
                    ? AppRoutes.workerDeliveryOrder(orderId)
                    : AppRoutes.workerPackingOrder(orderId),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      tooltip: unread == 0 ? 'Notifications' : '$unread unread notifications',
      onPressed: () => _openInbox(context, ref),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 9 ? '9+' : '$unread'),
        child: Icon(
          unread > 0
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
        ),
      ),
    );
  }
}
