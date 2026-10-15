import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/ui/empty_state.dart';
import '../../../orders/data/models/worker_order.dart';
import '../../../session/presentation/view_models/worker_session_view_model.dart';
import '../../../shell/presentation/ui/worker_scaffold.dart';
import '../../../shell/worker_routes.dart';
import '../ui/pickup_order_card.dart';
import '../view_models/pickup_queue_view_model.dart';

/// Packing Staff "Ready for Pickup" tab: every ready self-pickup order at
/// the packer's branch, whoever packed it, with search and the pickups
/// this packer handed over today.
class PickupQueueView extends ConsumerStatefulWidget {
  const PickupQueueView({super.key});

  @override
  ConsumerState<PickupQueueView> createState() => _PickupQueueViewState();
}

class _PickupQueueViewState extends ConsumerState<PickupQueueView> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openOrder(WorkerOrder order) {
    context.push(AppRoutes.workerPickupOrder(order.id));
  }

  /// True if [order] matches the search box: by order number (a leading
  /// "#" is ignored) or by customer name, ignoring capital letters.
  bool _matches(WorkerOrder order) {
    final text = _search.trim().toLowerCase().replaceFirst('#', '');
    if (text.isEmpty) return true;
    return order.number.toString().contains(text) ||
        order.customerName.toLowerCase().contains(text);
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(pickupQueueViewModelProvider);
    final handovers = ref.watch(pickupHandoversViewModelProvider).value ?? [];
    final workerId = ref.watch(workerSessionProvider)?.id ?? '';

    return WorkerScaffold(
      currentTab: WorkerTab.readyForPickup,
      child: queue.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          message: 'The pickup orders could not be loaded.',
          onRetry: () => ref.invalidate(pickupQueueViewModelProvider),
        ),
        data: (orders) {
          final shown = orders.where(_matches).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  0,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (text) => setState(() => _search = text),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search order number or customer',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    if (orders.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: Text(
                          orders.length == 1
                              ? '1 order waiting · oldest first'
                              : '${orders.length} orders waiting · oldest first',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    if (orders.isEmpty)
                      const _InlineEmpty(
                        icon: Icons.storefront_outlined,
                        title: 'No orders waiting for pickup',
                        message:
                            'Self-pickup orders appear here as soon as any '
                            'packer at your branch marks them ready.',
                      )
                    else if (shown.isEmpty)
                      _InlineEmpty(
                        icon: Icons.search_off_rounded,
                        title: 'No matching orders',
                        message: 'Nothing waiting matches "${_search.trim()}".',
                      )
                    else
                      for (final order in shown)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s),
                          child: PickupOrderCard(
                            order: order,
                            workerId: workerId,
                            onTap: () => _openOrder(order),
                          ),
                        ),
                    const SizedBox(height: AppSpacing.l),
                    _HandoversSection(
                      orders: handovers,
                      onTap: _openOrder,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Smaller empty message that sits inside the list, so the handover
/// section below it stays visible.
class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.greenTint,
            foregroundColor: AppColors.darkGreen,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Collapsible list of pickups this packer handed over today.
class _HandoversSection extends StatelessWidget {
  const _HandoversSection({required this.orders, required this.onTap});

  final List<WorkerOrder> orders;
  final void Function(WorkerOrder order) onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.task_alt_rounded, color: AppColors.success),
        title: Text(
          'Handed over by you today (${orders.length})',
          style: textTheme.titleMedium,
        ),
        // The tile draws its own lines when open; the card has a border.
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: Text(
                'Orders you hand over today will be listed here.',
                style: textTheme.bodyMedium,
              ),
            )
          else
            for (final order in orders)
              ListTile(
                onTap: () => onTap(order),
                title: Text('#${order.number} · ${order.customerName}'),
                subtitle: Text(
                  'Handed over at ${Formatters.time(order.completedAt!)}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
        ],
      ),
    );
  }
}
