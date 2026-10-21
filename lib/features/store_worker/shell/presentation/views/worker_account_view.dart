import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_scaffold.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/view_models/worker_today_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/ui/worker_badges.dart';

/// Account tab for both worker roles: who is signed in, their role and
/// branch, and sign out. Read-only.
class WorkerAccountView extends ConsumerWidget {
  const WorkerAccountView({super.key});

  /// Signs out and returns to onboarding.
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(workerSessionProvider.notifier).exit();
    if (context.mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worker = ref.watch(workerSessionProvider);

    return WorkerScaffold(
      currentTab: WorkerTab.account,
      child: worker == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                _ProfileCard(worker: worker),
                const SizedBox(height: AppSpacing.l),
                _TodayCard(worker: worker),
                const SizedBox(height: AppSpacing.l),
                _DetailsCard(worker: worker),
                const SizedBox(height: AppSpacing.l),
                // Past work, out of the bottom navigation because it is
                // only looked at now and then.
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(
                      Icons.history_rounded,
                      color: AppColors.darkGreen,
                    ),
                    title: const Text('My history'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.workerHistory),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () => _signOut(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
    );
  }
}

/// Avatar, name, and role and status tags.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.worker});

  final WorkerProfile worker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            WorkerAvatar(name: worker.name, radius: 28),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name, style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  // No "Active" badge: inactive workers cannot sign in, so
                  // everyone who sees this is active.
                  _RoleTag(label: worker.role.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green tag with the worker's role.
class _RoleTag extends StatelessWidget {
  const _RoleTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Role, branch and contact details, one per row.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.worker});

  final WorkerProfile worker;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.storefront_outlined,
              // Packers have one branch; drivers cover every branch.
              label: worker.branchName == null ? 'Coverage' : 'Assigned branch',
              value:
                  worker.branchName ?? 'All branches (cross-branch delivery)',
            ),
            _DetailRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: worker.email,
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: worker.phone,
            ),
            _DetailRow(
              icon: Icons.tag_rounded,
              label: 'Worker ID',
              value: worker.id,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                Text(value, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The worker's day so far: what they finished today and what is left.
class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.worker});

  final WorkerProfile worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final summary = ref.watch(workerTodaySummaryProvider);
    final average = summary?.averageMinutes;

    final stats = worker.isPackingStaff
        ? [
            ('Packed', summary == null ? '–' : '${summary.doneToday}'),
            ('Avg time', average == null ? '–' : Formatters.minutes(average)),
            ('To pack', summary == null ? '–' : '${summary.stillToDo}'),
          ]
        : [
            ('Delivered', summary == null ? '–' : '${summary.doneToday}'),
            ('Still to do', summary == null ? '–' : '${summary.stillToDo}'),
          ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                for (final (index, (label, value)) in stats.indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _Stat(label: label, value: value),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One number on the Today card, with its label under it.
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
