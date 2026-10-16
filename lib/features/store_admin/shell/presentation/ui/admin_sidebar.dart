import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/branch_switcher.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// The pages in the store admin sidebar, in the order they are listed.
enum AdminPage {
  dashboard('Dashboard', Icons.dashboard_outlined, AppRoutes.adminDashboard),
  orders('Orders', Icons.receipt_long_outlined, AppRoutes.adminOrders),
  inventory('Inventory', Icons.inventory_2_outlined, AppRoutes.adminInventory),
  staff('Staff', Icons.badge_outlined, AppRoutes.adminStaff),
  dispatch('Dispatch', Icons.local_shipping_outlined, AppRoutes.adminDispatch),
  reviews('Reviews', Icons.star_outline_rounded, AppRoutes.adminReviews),
  salesAndRevenue(
    'Sales & revenue',
    Icons.bar_chart_rounded,
    AppRoutes.adminSales,
  );

  const AdminPage(this.label, this.icon, this.route);

  final String label;
  final IconData icon;

  /// Where the menu item goes.
  final String route;
}

/// Sidebar for store admin pages: branch switcher on top, the menu in the
/// middle, and the signed-in admin with a sign out button at the bottom.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({required this.currentPage, super.key});

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
                  _MenuItem(page: page, isSelected: page == currentPage),
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
  const _MenuItem({required this.page, required this.isSelected});

  final AdminPage page;
  final bool isSelected;

  void _onTap(BuildContext context) {
    // On phones the menu is in a drawer, so close it first.
    Scaffold.of(context).closeDrawer();
    if (!isSelected) context.go(page.route);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(page.icon),
      title: Text(page.label),
      selected: isSelected,
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
      onTap: () => _onTap(context),
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
