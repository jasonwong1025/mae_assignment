import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
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

  /// True while the search field is open in the header.
  bool _isSearching = false;

  void _openSearch() => setState(() => _isSearching = true);

  /// Closes the search field and clears the search, so every order shows.
  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _search = '';
    });
  }

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
    final waitingForDrivers =
        ref.watch(pickupWaitingForDriversViewModelProvider).value ?? [];
    final workerId = ref.watch(workerSessionProvider)?.id ?? '';

    return WorkerScaffold(
      currentTab: WorkerTab.readyForPickup,
      // The search icon opens a search field in place of the header title.
      titleOverride: _isSearching
          ? TextField(
              key: const ValueKey('pickup-search'),
              controller: _searchController,
              autofocus: true,
              onChanged: (text) => setState(() => _search = text),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Order number or customer',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                prefixIconConstraints: BoxConstraints(minWidth: 40),
                isDense: true,
                // Slimmer than the app's standard fields, to sit neatly in
                // the header.
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            )
          : null,
      actions: [
        _isSearching
            ? IconButton(
                tooltip: 'Close search',
                icon: const Icon(Icons.close_rounded),
                onPressed: _closeSearch,
              )
            : IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search_rounded),
                onPressed: _openSearch,
              ),
      ],
      child: queue.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          message: 'The pickup orders could not be loaded.',
          onRetry: () => ref.invalidate(pickupQueueViewModelProvider),
        ),
        data: (orders) {
          // The search filters both lists.
          final waiting = orders.where(_matches).toList();
          final drivers = waitingForDrivers.where(_matches).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.l,
            ),
            children: [
              // Customers collecting at the counter.
              _SectionTitle('Waiting for Pickup (${waiting.length})'),
              if (orders.isEmpty)
                const _InlineEmpty(
                  icon: Icons.storefront_outlined,
                  title: 'No orders waiting for pickup',
                  message:
                      'Self-pickup orders appear here as soon as any packer '
                      'at your branch marks them ready.',
                )
              else if (waiting.isEmpty)
                _InlineEmpty(
                  icon: Icons.search_off_rounded,
                  title: 'No matching orders',
                  message: 'Nothing waiting matches "${_search.trim()}".',
                )
              else
                for (final order in waiting)
                  _card(
                    PickupOrderCard(
                      order: order,
                      detail: packedByText(order, workerId),
                      timeLabel: 'Pickup',
                      time: order.dueAt,
                      highlightTime: true,
                      onTap: () => _openOrder(order),
                    ),
                  ),

              // Delivery bags for drivers to collect. Read-only: the
              // driver verifies the bag in their own app.
              if (drivers.isNotEmpty) ...[
                _SectionTitle('Waiting for drivers (${drivers.length})'),
                for (final order in drivers)
                  _card(
                    PickupOrderCard(
                      order: order,
                      detail: 'For ${order.driverName ?? 'driver'}',
                      timeLabel: 'Deliver',
                      time: order.dueAt,
                      highlightTime: true,
                    ),
                  ),
              ],

            ],
          );
        },
      ),
    );
  }

  /// A card with the gap below it.
  Widget _card(Widget card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: card,
    );
  }
}

/// Section heading, e.g. "Waiting for Pickup (2)".
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.s),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Smaller empty message that sits inside the list, so the Waiting for
/// drivers section below it stays visible.
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
