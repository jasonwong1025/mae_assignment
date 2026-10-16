import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_scaffold.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/ui/worker_badges.dart';

/// Account tab for both worker roles: who is signed in, their role and
/// branch, and the way out of the preview. Read-only.
class WorkerAccountView extends ConsumerWidget {
  const WorkerAccountView({super.key});

  /// Leaves the preview and returns to sign-in, where the preview started.
  void _exitPreview(BuildContext context, WidgetRef ref) {
    // Navigate first, so this page is not left showing an empty session.
    context.go(AppRoutes.login);
    ref.read(workerSessionProvider.notifier).exit();
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
                _DetailsCard(worker: worker),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.workerDevSelect),
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Switch worker'),
                ),
                const SizedBox(height: AppSpacing.m),
                OutlinedButton.icon(
                  onPressed: () => _exitPreview(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Exit preview'),
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
                  Wrap(
                    spacing: AppSpacing.s,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _RoleTag(label: worker.role.label),
                      WorkerStatusChip(isActive: worker.isActive),
                    ],
                  ),
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
              icon: Icons.badge_outlined,
              label: 'Role',
              value: worker.role.label,
            ),
            _DetailRow(
              icon: Icons.storefront_outlined,
              label: 'Assigned branch',
              value: worker.branchName,
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
