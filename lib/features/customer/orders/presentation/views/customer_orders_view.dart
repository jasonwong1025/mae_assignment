import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Orders tab. Order history and live tracking land here in a
/// later slice; for now it is an empty state so the tab is navigable.
class CustomerOrdersView extends ConsumerWidget {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomerScaffold(
      currentTab: CustomerTab.orders,
      cartCount: ref.watch(cartCountProvider),
      child: const SafeArea(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No orders yet',
          message: 'Orders you place will show up here with live tracking.',
        ),
      ),
    );
  }
}
