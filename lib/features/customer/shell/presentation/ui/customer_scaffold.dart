import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';

/// Mobile page frame for the customer tabs: the page body plus the shared
/// Home / Grocery / Orders / Account bottom navigation. Each tab supplies its
/// own header, so there is no shared app bar.
///
/// Built for phones held upright; on wider screens the page keeps a
/// phone-friendly width in the middle instead of stretching.
class CustomerScaffold extends StatelessWidget {
  const CustomerScaffold({
    required this.currentTab,
    required this.child,
    super.key,
  });

  /// Pages never get wider than this, even on tablets and web.
  static const double maxContentWidth = 600;

  /// The tab being shown, highlighted in the navigation bar.
  final CustomerTab currentTab;
  final Widget child;

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
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
