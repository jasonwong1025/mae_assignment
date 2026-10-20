import 'package:mae_assignment/shared/models/order.dart';

/// When an order is promised to the customer, for "Pickup by" and
/// "Deliver by" on the Store Worker screens, sorting by urgency, and the
/// bag label.
extension OrderDueTime on Order {
  /// How long after the order is placed a self-pickup should be ready.
  /// Matches the cart's "Ready in ~25 min".
  static const pickupWindow = Duration(minutes: 25);

  /// How long after the order is placed a delivery should arrive.
  static const deliveryWindow = Duration(minutes: 60);

  /// The due time HQ saved on the order ([Order.dueAt]) if there is one;
  /// otherwise worked out from when it was placed. Null only if neither is
  /// known.
  ///
  /// Nothing sets dueAt yet, so this keeps the screens working until Store
  /// Admin saves real due times; once it does, those win automatically.
  DateTime? get promisedAt {
    final saved = dueAt;
    if (saved != null) return saved;
    final placed = placedAt;
    if (placed == null) return null;
    return placed.add(isDelivery ? deliveryWindow : pickupWindow);
  }
}
