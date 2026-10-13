import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order.dart';

final ordersFilterViewModelProvider =
    NotifierProvider.autoDispose<OrdersFilterViewModel, OrdersFilter>(
      OrdersFilterViewModel.new,
    );

/// Choices in the Filter menu.
enum FulfilmentFilter {
  all('All orders'),
  delivery('Delivery'),
  pickup('Pickup');

  const FulfilmentFilter(this.label);

  final String label;
}

/// What the admin typed in the search box and picked in the Filter menu.
class OrdersFilter {
  const OrdersFilter({
    this.searchText = '',
    this.fulfilment = FulfilmentFilter.all,
  });

  final String searchText;
  final FulfilmentFilter fulfilment;

  /// True if [order] should be shown on the board.
  bool matches(Order order) {
    if (fulfilment == FulfilmentFilter.delivery && !order.isDelivery) {
      return false;
    }
    if (fulfilment == FulfilmentFilter.pickup && order.isDelivery) {
      return false;
    }

    // Search by order number or customer name. Capital letters and a
    // leading "#" are ignored, so "#2288", "2288" and "david" all work.
    final text = searchText.trim().toLowerCase().replaceFirst('#', '');
    if (text.isEmpty) return true;
    return order.number.toString().contains(text) ||
        order.customerName.toLowerCase().contains(text);
  }
}

/// State for the search box and Filter menu of the orders board.
class OrdersFilterViewModel extends Notifier<OrdersFilter> {
  @override
  OrdersFilter build() => const OrdersFilter();

  void setSearchText(String text) {
    state = OrdersFilter(searchText: text, fulfilment: state.fulfilment);
  }

  void setFulfilment(FulfilmentFilter fulfilment) {
    state = OrdersFilter(searchText: state.searchText, fulfilment: fulfilment);
  }
}
