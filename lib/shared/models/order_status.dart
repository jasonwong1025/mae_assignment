/// Where an order is in fulfilment, in the order the stages happen.
/// Shared by the store admin's orders board and the Store Worker app.
enum OrderStatus {
  pending('Pending'),
  packing('Packing'),
  ready('Ready'),
  outForDelivery('Out for delivery'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  /// Name shown on screen, e.g. "Out for delivery".
  final String label;

  /// Completed and cancelled orders will not change any more.
  bool get isFinished => this == completed || this == cancelled;
}
