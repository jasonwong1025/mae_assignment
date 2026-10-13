import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utilities/formatters.dart';
import '../../../../authentication/data/repositories/auth_repository.dart';
import '../../../shell/data/models/branch.dart';
import '../../../shell/presentation/ui/admin_scaffold.dart';
import '../../../shell/presentation/ui/admin_sidebar.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/dashboard_summary.dart';
import '../ui/activity_card.dart';
import '../ui/live_orders_card.dart';
import '../ui/orders_today_card.dart';
import '../view_models/dashboard_view_model.dart';

/// Store admin home page: today's numbers for the selected branch.
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final dashboard = ref.watch(dashboardViewModelProvider);
    final branch = ref.watch(branchViewModelProvider).value?.selected;
    final adminName = ref.watch(currentUserProvider).value?.name ?? '';

    return AdminScaffold(
      currentPage: AdminPage.dashboard,
      child: dashboard.when(
        // Keep showing the old branch while the new one loads,
        // instead of flashing a spinner.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Could not load the dashboard.',
            style: textTheme.bodyMedium,
          ),
        ),
        data: (summary) {
          if (branch == null) return const SizedBox.shrink();
          return _DashboardContent(
            summary: summary,
            branch: branch,
            adminName: adminName,
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.summary,
    required this.branch,
    required this.adminName,
  });

  final DashboardSummary summary;
  final Branch branch;
  final String adminName;

  void _onAddItem(BuildContext context) {
    // TODO: open the add item page once Inventory is built.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Adding items is not connected yet.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final liveOrders = LiveOrdersCard(orders: summary.liveOrders);
    final activity = ActivityCard(activity: summary.activity);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Based on the space left for the page, not the whole screen,
        // because the sidebar takes some of it.
        final isWide = constraints.maxWidth >= 720;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                adminName: adminName,
                branch: branch,
                onAddItem: () => _onAddItem(context),
              ),
              const SizedBox(height: 24),
              OrdersTodayCard(
                summary: summary,
                openingHour: branch.openingHour,
              ),
              const SizedBox(height: 16),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: liveOrders),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: activity),
                  ],
                )
              else ...[
                liveOrders,
                const SizedBox(height: 16),
                activity,
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Greeting, the time with how long until closing, and "Add item".
class _Header extends StatelessWidget {
  const _Header({
    required this.adminName,
    required this.branch,
    required this.onAddItem,
  });

  final String adminName;
  final Branch branch;
  final VoidCallback onAddItem;

  /// "Good evening, Jason". Uses the first name only.
  String _greeting(DateTime now) {
    final String partOfDay;
    if (now.hour < 12) {
      partOfDay = 'Good morning';
    } else if (now.hour < 18) {
      partOfDay = 'Good afternoon';
    } else {
      partOfDay = 'Good evening';
    }

    final firstName = adminName.trim().split(' ').first;
    return firstName.isEmpty ? partOfDay : '$partOfDay, $firstName';
  }

  /// "closes in 2h 12m", "opens at 8am" or "closed for today".
  String _openingStatus(DateTime now) {
    if (now.hour < branch.openingHour) {
      return 'opens at ${Formatters.hour(branch.openingHour)}';
    }

    final minutesNow = now.hour * 60 + now.minute;
    final minutesLeft = branch.closingHour * 60 - minutesNow;
    if (minutesLeft <= 0) return 'closed for today';
    return 'closes in ${Formatters.minutes(minutesLeft)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(now), style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '${Formatters.time(now)} · ${_openingStatus(now)}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: onAddItem,
          // The theme's buttons stretch to full width; this one should
          // only be as wide as its label.
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add item'),
        ),
      ],
    );
  }
}
