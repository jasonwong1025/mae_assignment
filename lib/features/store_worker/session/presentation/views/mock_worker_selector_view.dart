import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/ui/bottom_action_bar.dart';
import '../../../../../shared/ui/worker_badges.dart';
import '../../../orders/data/repositories/worker_orders_repository.dart';
import '../../../shell/worker_routes.dart';
import '../../data/mock_workers.dart';
import '../../data/models/worker_profile.dart';
import '../view_models/worker_session_view_model.dart';

/// Development-only page for previewing the Store Worker app without a
/// Firebase account: pick a mock worker and the app opens as them.
/// Only reachable in builds where the preview is allowed (see
/// worker_preview.dart).
class MockWorkerSelectorView extends ConsumerWidget {
  const MockWorkerSelectorView({super.key});

  void _onWorkerTap(BuildContext context, WidgetRef ref, WorkerProfile worker) {
    final error = ref.read(workerSessionProvider.notifier).select(worker);
    if (error != null) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cannot start preview'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // go() instead of push() so "back" does not return to this list.
    context.go(workerHomeFor(worker));
  }

  /// Puts every mock order back to the sample data, for whoever is chosen.
  void _resetDemoData(BuildContext context, WidgetRef ref) {
    ref.read(workerOrdersRepositoryProvider).resetDemoData();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Demo orders are back to the start.')),
      );
  }

  void _exitPreview(BuildContext context, WidgetRef ref) {
    context.go(AppRoutes.login);
    ref.read(workerSessionProvider.notifier).exit();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final workers = ref.watch(mockWorkerProfilesProvider);
    final current = ref.watch(workerSessionProvider);

    // Group by branch, keeping the order the branches first appear in.
    final byBranch = <String, List<WorkerProfile>>{};
    for (final worker in workers) {
      byBranch.putIfAbsent(worker.branchName, () => []).add(worker);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Store Worker preview')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _resetDemoData(context, ref),
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset demo data'),
                        ),
                      ),
                      for (final entry in byBranch.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xl,
                            bottom: AppSpacing.s,
                          ),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        for (final worker in entry.value)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.s,
                            ),
                            child: _WorkerTile(
                              worker: worker,
                              isCurrent: worker.id == current?.id,
                              onTap: () => _onWorkerTap(context, ref, worker),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                if (current != null)
                  BottomActionBar(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _exitPreview(context, ref),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Exit preview'),
                      ),
                    ],
                  )
                else if (!context.canPop())
                  BottomActionBar(
                    children: [
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Back to sign in'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One mock worker: avatar, name, role and branch, and status.
/// Inactive workers are greyed out but still tappable, so the app can
/// explain why they cannot start.
class _WorkerTile extends StatelessWidget {
  const _WorkerTile({
    required this.worker,
    required this.isCurrent,
    required this.onTap,
  });

  final WorkerProfile worker;

  /// True for the worker the preview is currently running as.
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final roleIcon = worker.isDeliveryDriver
        ? Icons.local_shipping_outlined
        : Icons.inventory_2_outlined;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent ? AppColors.darkGreen : AppColors.border,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: worker.isActive ? 1 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                WorkerAvatar(name: worker.name, radius: 22),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name, style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            roleIcon,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              '${worker.role.label} · ${worker.branchName}',
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Under the name, not beside it, so the name keeps
                      // its width on narrow screens and with large text.
                      const SizedBox(height: AppSpacing.xs),
                      WorkerStatusChip(isActive: worker.isActive),
                    ],
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: AppSpacing.s),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.darkGreen,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
