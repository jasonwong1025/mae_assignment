import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/delivery_order_card.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/delivery_tasks_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_scaffold.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Delivery Driver "My Deliveries" tab: assigned deliveries from any
/// branch, grouped by stage. Orders still being packed are listed so the
/// driver can plan, but cannot be collected until they are ready.
class DeliveryTasksView extends ConsumerWidget {
  const DeliveryTasksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(deliveryTasksViewModelProvider);

    void openOrder(Order order) {
      unawaited(context.push(AppRoutes.workerDeliveryOrder(order.id)));
    }

    return WorkerScaffold(
      currentTab: WorkerTab.myDeliveries,
      child: deliveries.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          message: 'Your deliveries could not be loaded.',
          onRetry: () => ref.invalidate(deliveryTasksViewModelProvider),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const EmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'No deliveries assigned',
              message:
                  'Deliveries HQ assigns to you will appear here, including '
                  'orders that are still being packed.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              // The driver's current job first, then what they can collect
              // now, then what is coming. Finished ones are in My history.
              ..._section(
                context,
                'Out for delivery',
                groups.outForDelivery,
                openOrder,
              ),
              ..._section(
                context,
                'Ready to collect',
                groups.readyToCollect,
                openOrder,
              ),
              ..._section(
                context,
                'Being packed',
                groups.beingPacked,
                openOrder,
              ),
            ],
          );
        },
      ),
    );
  }

  /// A heading with a count, then one card per order. Nothing if empty.
  List<Widget> _section(
    BuildContext context,
    String title,
    List<Order> orders,
    void Function(Order order) onTap,
  ) {
    if (orders.isEmpty) return const [];
    final textTheme = Theme.of(context).textTheme;

    return [
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.s),
        // Same heading style as Ready for Pickup, e.g.
        // "Waiting for pickup (2)".
        child: Text('$title (${orders.length})', style: textTheme.titleMedium),
      ),
      for (final order in orders)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: DeliveryOrderCard(order: order, onTap: () => onTap(order)),
        ),
      const SizedBox(height: AppSpacing.m),
    ];
  }
}
