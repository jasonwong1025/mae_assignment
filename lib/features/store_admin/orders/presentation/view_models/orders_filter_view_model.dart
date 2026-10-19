import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/shared/models/order.dart';

part 'orders_filter_view_model.freezed.dart';

final NotifierProvider<OrdersFilterViewModel, OrdersFilter>
ordersFilterViewModelProvider =
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
@freezed
abstract class OrdersFilter with _$OrdersFilter {
  const factory OrdersFilter({
    @Default('') String searchText,
    @Default(FulfilmentFilter.all) FulfilmentFilter fulfilment,
  }) = _OrdersFilter;

  const OrdersFilter._();

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
    state = state.copyWith(searchText: text);
  }

  void setFulfilment(FulfilmentFilter fulfilment) {
    state = state.copyWith(fulfilment: fulfilment);
  }
}
