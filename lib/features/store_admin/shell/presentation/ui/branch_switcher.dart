import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';

/// Logo and app name with the current branch underneath.
/// Tapping it opens a menu to switch to another branch.
class BranchSwitcher extends ConsumerWidget {
  const BranchSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final branchState = ref.watch(branchViewModelProvider).value;
    final branches = branchState?.branches ?? const <Branch>[];
    final selected = branchState?.selected;

    return PopupMenuButton<Branch>(
      tooltip: 'Switch branch',
      // Open the menu below the header instead of on top of it.
      position: PopupMenuPosition.under,
      enabled: branches.isNotEmpty,
      onSelected: (branch) {
        ref.read(branchViewModelProvider.notifier).selectBranch(branch);
      },
      itemBuilder: (context) => [
        for (final branch in branches)
          PopupMenuItem(
            value: branch,
            child: Row(
              children: [
                // Hidden (not removed) for other branches, so every
                // name starts at the same place.
                Opacity(
                  opacity: branch.id == selected?.id ? 1 : 0,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(branch.name),
                if (branch.isTemporarilyClosed) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Closed',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          children: [
            Image.asset('assets/logo/logo.png', height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grocerly', style: textTheme.titleLarge),
                  Text(
                    selected?.name ?? 'Loading branches',
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.unfold_more_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
