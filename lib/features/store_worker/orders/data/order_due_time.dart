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
  /// Nothing in the app or the Functions saves [Order.dueAt]: Store Admin has
  /// no screen for it, so in practice every order uses the calculated
  /// service level above (pickup 25 minutes, delivery 60). The field stays
  /// as an optional override, used by the demo data, so a due time set by
  /// hand (or by a future admin feature) wins.
  DateTime? get promisedAt {
    final saved = dueAt;
    if (saved != null) return saved;
    final placed = placedAt;
    if (placed == null) return null;
    return placed.add(isDelivery ? deliveryWindow : pickupWindow);
  }
}
