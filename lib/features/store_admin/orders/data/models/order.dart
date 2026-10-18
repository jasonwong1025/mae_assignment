import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

// OrderStatus (the columns of the orders board) now lives in shared/ so the
// Store Worker app uses the same statuses. Re-exported so files that import
// this one keep working.
export '../../../../../shared/models/order_status.dart';

part 'order.freezed.dart';

/// Columns of the admin orders board. Orders are paid at checkout and
/// cannot be cancelled, so there is no Cancelled column.
// TODO(team): OrderStatus.cancelled is still used by the Store Worker app.
const List<OrderStatus> adminBoardStatuses = [
  OrderStatus.pending,
  OrderStatus.packing,
  OrderStatus.ready,
  OrderStatus.outForDelivery,
  OrderStatus.completed,
];

/// One customer order, as the store admin sees it.
@freezed
abstract class Order with _$Order {
  const factory Order({
    required int number,
    required String customerName,
    required String customerPhone,
    required OrderStatus status,

    /// When the order entered its current status.
    required DateTime statusSince,

    /// Delivery/Pickup order
    required bool isDelivery,
    required List<OrderItem> items,

    /// Delivery fee
    required double deliveryFee,

    /// What has happened to the order so far, oldest first
    required List<OrderEvent> timeline,

    /// Address of the customer
    String? address,

    /// Where the address is on the map. Delivery orders only.
    LatLng? location,

    /// Message the customer left with the order
    String? customerNote,

    /// Staff member packing or delivering the order
    String? assignedWorker,

    /// Id of the driver delivering it. Null until a driver is assigned.
    String? driverId,
  }) = _Order;

  const Order._();

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
      sum += item.lineTotal;
    }
    return sum;
  }

  double get total => subtotal + deliveryFee;

  /// How long the order has been in its current status.
  int minutesInStatus(DateTime now) => now.difference(statusSince).inMinutes;

  /// Copy with a new driver, noted in the timeline.
  Order withDriver({
    required String driverId,
    required String driverName,
    required DateTime now,
  }) {
    return Order(
      number: number,
      customerName: customerName,
      customerPhone: customerPhone,
      status: status,
      statusSince: statusSince,
      isDelivery: isDelivery,
      address: address,
      location: location,
      customerNote: customerNote,
      items: items,
      deliveryFee: deliveryFee,
      assignedWorker: driverName,
      driverId: driverId,
      timeline: [
        ...timeline,
        OrderEvent(
          title: 'Driver $driverName assigned',
          time: now,
          by: 'Admin',
        ),
      ],
    );
  }
}

/// One product line of an order.
@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String name,
    required int quantity,

    /// Price of one, in ringgit.
    required double unitPrice,
  }) = _OrderItem;

  const OrderItem._();

  double get lineTotal => unitPrice * quantity;
}

/// One step in an order's history, e.g. "Packing started" by Daniel.
@freezed
abstract class OrderEvent with _$OrderEvent {
  const factory OrderEvent({
    required String title,
    required DateTime time,

    /// Staff member who did it. Null for things the customer did.
    String? by,
  }) = _OrderEvent;

  const OrderEvent._();
}
