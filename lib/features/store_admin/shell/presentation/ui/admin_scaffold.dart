import 'package:flutter/material.dart';

import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_sidebar.dart';

/// Page frame shared by every store admin page: sidebar plus the page.
/// - Tablet and web: the sidebar is always visible on the left.
/// - Phone: the sidebar is hidden in a drawer, opened by the menu button.
class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    required this.currentPage,
    required this.child,
    super.key,
  });

  /// Screens at least this wide show the sidebar all the time.
  static const double wideLayoutWidth = 900;
  static const double _sidebarWidth = 264;

  /// The page being shown, highlighted in the sidebar.
  final AdminPage currentPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= wideLayoutWidth;

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            // Stretch so the page starts at the top instead of being
            // centred when it is shorter than the screen.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _sidebarWidth,
                child: AdminSidebar(currentPage: currentPage),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // The AppBar adds the menu button by itself because there is a drawer.
      appBar: AppBar(title: Text(currentPage.label)),
      drawer: Drawer(
        width: _sidebarWidth,
        child: SafeArea(child: AdminSidebar(currentPage: currentPage)),
      ),
      body: SafeArea(child: child),
    );
  }
}
