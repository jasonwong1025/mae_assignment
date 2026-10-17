import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';

/// Mobile page frame for the customer tabs: the page body plus the shared
/// Home / Cart / Orders / Account bottom navigation. Each tab supplies its
/// own header, so there is no shared app bar.
///
/// Built for phones held upright; on wider screens the page keeps a
/// phone-friendly width in the middle instead of stretching.
class CustomerScaffold extends StatelessWidget {
  const CustomerScaffold({
    required this.currentTab,
    required this.child,
    super.key,
    this.cartCount = 0,
  });

  /// Pages never get wider than this, even on tablets and web.
  static const double maxContentWidth = 600;

  /// The tab being shown, highlighted in the navigation bar.
  final CustomerTab currentTab;
  final Widget child;

  /// Items in the cart; shown as a badge on the Cart tab. 0 hides it.
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    const tabs = CustomerTab.values;

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab.index,
        onDestinationSelected: (index) {
          final tab = tabs[index];
          if (tab != currentTab) context.go(tab.route);
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: _TabIcon(
                icon: tab.icon,
                badgeCount: tab == CustomerTab.cart ? cartCount : 0,
              ),
              selectedIcon: _TabIcon(
                icon: tab.selectedIcon,
                badgeCount: tab == CustomerTab.cart ? cartCount : 0,
              ),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

/// A tab icon with an optional count badge (used for the cart).
class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.icon, required this.badgeCount});

  final IconData icon;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    if (badgeCount <= 0) return Icon(icon);
    return Badge(label: Text('$badgeCount'), child: Icon(icon));
  }
}
