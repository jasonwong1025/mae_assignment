import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/notifications/data/models/app_notification.dart';
import 'package:mae_assignment/features/notifications/presentation/view_models/notifications_view_model.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// The customer's notification inbox: what happened to their orders. Tapping
/// one opens the order. Push notifications arrive when the app is closed;
/// this list keeps them for later.
class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    final orderId = notification.orderId;
    // Read the router and actions before the await: the page may close.
    final router = GoRouter.of(context);
    if (!notification.isRead) {
      await ref.read(notificationActionsProvider).markRead([notification.id]);
    }
    if (orderId != null) router.go(AppRoutes.customerOrder(orderId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationInboxProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              key: const Key('mark_all_read'),
              onPressed: () async {
                final ids = [
                  for (final n in inbox.value ?? const <AppNotification>[])
                    if (!n.isRead) n.id,
                ];
                final error = await ref
                    .read(notificationActionsProvider)
                    .markRead(ids);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: inbox.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorState(
                message: 'Could not load your notifications.',
                onRetry: () => ref.invalidate(notificationInboxProvider),
              ),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications yet',
                      message:
                          'We will tell you when your order is packed, on the '
                          'way, or needs a reply from you.',
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _NotificationTile(
                          notification: item,
                          onTap: () => _open(context, ref, item),
                          onDismissed: () => ref
                              .read(notificationActionsProvider)
                              .delete(item.id),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final created = notification.createdAt;
    final unread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        tileColor: unread ? AppColors.greenTint : null,
        leading: Icon(
          unread
              ? Icons.notifications_active_rounded
              : Icons.notifications_none_rounded,
          color: unread ? AppColors.darkGreen : AppColors.textSecondary,
        ),
        title: Text(
          notification.title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: unread ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          created == null
              ? notification.body
              : '${notification.body}\n'
                    '${Formatters.dayMonth(created)}, '
                    '${Formatters.time(created)}',
        ),
        isThreeLine: created != null,
      ),
    );
  }
}
