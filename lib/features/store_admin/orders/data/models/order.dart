/// The columns of the orders board, in the order they are shown.
enum OrderStatus {
  pending('Pending'),
  packing('Packing'),
  ready('Ready'),
  outForDelivery('Out for delivery'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  /// Name shown to the admin, e.g. "Out for delivery".
  final String label;

  /// Completed and cancelled orders will not change any more.
  bool get isFinished => this == completed || this == cancelled;
}

enum PaymentMethod {
  cash('Cash'),
  online('Online');

  const PaymentMethod(this.label);

  final String label;
}

/// One customer order, as the store admin sees it.
class Order {
  const Order({
    required this.number,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.statusSince,
    required this.isDelivery,
    required this.items,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.isPaid,
    required this.timeline,
    this.address,
    this.customerNote,
    this.assignedWorker,
    this.attentionReason,
  });

  final int number;
  final String customerName;
  final String customerPhone;

  final OrderStatus status;

  /// When the order entered its current status.
  final DateTime statusSince;

  /// Delivery/Pickup order
  final bool isDelivery;

  /// Address of the customer
  final String? address;

  /// Message the customer left with the order
  final String? customerNote;

  final List<OrderItem> items;

  /// Delivery fee
  final double deliveryFee;

  final PaymentMethod paymentMethod;
  final bool isPaid;

  /// Staff member packing or delivering the order
  final String? assignedWorker;

  /// Why the order needs the admin's attention
  final String? attentionReason;

  /// What has happened to the order so far, oldest first
  final List<OrderEvent> timeline;

  bool get needsAttention => attentionReason != null;

  /// Number of products, counting quantities
  int get itemCount {
    var count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  /// Price of the items
  double get subtotal {
    var sum = 0.0;
    for (final item in items) {
      if (!item.isOutOfStock) sum += item.lineTotal;
    }
    return sum;
  }

  double get total => subtotal + deliveryFee;

  /// How long the order has been in its current status.
  int minutesInStatus(DateTime now) => now.difference(statusSince).inMinutes;
}

/// One product line of an order.
class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.isOutOfStock = false,
    this.replacedWith,
  });

  final String name;
  final int quantity;

  /// Price of one, in ringgit.
  final double unitPrice;

  /// True if the store could not supply it. It is then not charged.
  final bool isOutOfStock;

  /// Name of the product packed instead, if it was replaced.
  final String? replacedWith;

  double get lineTotal => unitPrice * quantity;
}

/// One step in an order's history, e.g. "Packing started" by Daniel.
class OrderEvent {
  const OrderEvent({required this.title, required this.time, this.by});

  final String title;
  final DateTime time;

  /// Staff member who did it. Null for things the customer did.
  final String? by;
}
