import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../shared/models/app_user.dart';
import '../../../../authentication/data/repositories/auth_repository.dart';
import '../view_models/branch_view_model.dart';
import 'branch_switcher.dart';

/// The pages in the store admin sidebar, in the order they are listed.
enum AdminPage {
  dashboard('Dashboard', Icons.dashboard_outlined),
  orders('Orders', Icons.receipt_long_outlined),
  inventory('Inventory', Icons.inventory_2_outlined),
  staff('Staff', Icons.badge_outlined),
  dispatch('Dispatch', Icons.local_shipping_outlined),
  refundsAndAlerts('Refunds & alerts', Icons.report_problem_outlined),
  reviews('Reviews', Icons.star_outline_rounded),
  analytics('Analytics', Icons.bar_chart_rounded);

  const AdminPage(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Sidebar for store admin pages: branch switcher on top, the menu in the
/// middle, and the signed-in admin with a sign out button at the bottom.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.currentPage});

  /// Pages that exist. The rest are shown greyed out and cannot be tapped.
  /// Add a page here once its screen is built.
  static const Set<AdminPage> _builtPages = {AdminPage.dashboard};

  final AdminPage currentPage;

  @override
  Widget build(BuildContext context) {
    // Material (not Container) so the menu items can draw their
    // highlight and tap ripple on it.
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          const BranchSwitcher(),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                for (final page in AdminPage.values)
                  _MenuItem(
                    page: page,
                    isSelected: page == currentPage,
                    isEnabled: _builtPages.contains(page),
                  ),
              ],
            ),
          ),
          const Divider(),
          const _ProfileRow(),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.page,
    required this.isSelected,
    required this.isEnabled,
  });

  final AdminPage page;
  final bool isSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(page.icon),
      title: Text(page.label),
      selected: isSelected,
      enabled: isEnabled,
      selectedColor: AppColors.darkGreen,
      selectedTileColor: AppColors.greenTint,
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textSecondary,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Only the dashboard exists for now, so a tap just closes the
      // drawer on phones. Later this will go to the tapped page.
      onTap: () => Scaffold.of(context).closeDrawer(),
    );
  }
}

/// Avatar, name and role of the signed-in admin, with a sign out button.
class _ProfileRow extends ConsumerWidget {
  const _ProfileRow();

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    // Forget the chosen branch so the next admin starts fresh.
    ref.invalidate(branchViewModelProvider);
    if (context.mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final name = user?.name ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.greenTint,
            foregroundColor: AppColors.darkGreen,
            child: Text(
              name.isEmpty ? '' : name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(UserRole.storeAdmin.label, style: textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.textSecondary,
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
    );
  }
}
