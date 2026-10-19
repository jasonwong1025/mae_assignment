import 'package:flutter/material.dart';
import 'package:mae_assignment/app/router/app_router.dart';

/// The four tabs in the customer bottom navigation, in display order.
enum CustomerTab {
  home(
    'Home',
    Icons.home_outlined,
    Icons.home_rounded,
    AppRoutes.customerCatalogue,
  ),
  grocery(
    'Grocery',
    Icons.checklist_rtl_outlined,
    Icons.checklist_rtl_rounded,
    AppRoutes.customerGrocery,
  ),
  orders(
    'Orders',
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
    AppRoutes.customerOrders,
  ),
  account(
    'Account',
    Icons.person_outline_rounded,
    Icons.person_rounded,
    AppRoutes.customerAccount,
  );

  const CustomerTab(this.label, this.icon, this.selectedIcon, this.route);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}
