import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

part 'order.freezed.dart';

/// One line of an order: the product snapshot taken at checkout.
///
/// The price and name are captured here so the order total never drifts if
/// the catalogue changes afterwards, and so the Store Worker can pack from
/// the order alone without re-reading the catalogue.
@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    /// Unique within the order and never reused, so the same product can
    /// appear on two lines and the worker's packing checklist keys on it.
    required String lineId,
    required String productId,
    required String name,
    required String brand,
    required String packSize,
    required int quantity,

    /// Price of one at the order's branch, in ringgit, at checkout.
    required double unitPrice,

    /// Cover image URL, or null if the product has none.
    String? imageUrl,
  }) = _OrderItem;

  const OrderItem._();

  /// Reads one entry of orders/{id}.items.
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      lineId: map.string(OrderItemFields.lineId),
      productId: map.string(OrderItemFields.productId),
      name: map.string(OrderItemFields.name),
      brand: map.string(OrderItemFields.brand),
      packSize: map.string(OrderItemFields.packSize),
      quantity: map.integer(OrderItemFields.quantity),
      unitPrice: map.decimal(OrderItemFields.unitPrice),
      imageUrl: map.stringOrNull(OrderItemFields.imageUrl),
    );
  }

  /// Price for this line: unit price times quantity.
  double get lineTotal => unitPrice * quantity;

  /// Fields for the orders/{orderId}.items array. A missing image is left
  /// out.
  Map<String, dynamic> toMap() {
    return {
      OrderItemFields.lineId: lineId,
      OrderItemFields.productId: productId,
      OrderItemFields.name: name,
      OrderItemFields.brand: brand,
      OrderItemFields.packSize: packSize,
      OrderItemFields.quantity: quantity,
      OrderItemFields.unitPrice: unitPrice,
      if (imageUrl != null && imageUrl!.isNotEmpty)
        OrderItemFields.imageUrl: imageUrl,
    };
  }
}

/// A placed customer order, stored at orders/{orderId}.
///
/// The customer app writes this shared order contract at checkout and reads
/// it for tracking. The Store Worker and Store Admin apps are intended to
/// read and update it once their sample-backed order flows are connected to
/// Firestore. It carries both a string [id] (the document id, used in routes)
/// and an int [number] (shown to people and available for future joins).
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required int number,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String branchId,
    required String branchName,
    required bool isDelivery,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
    required OrderStatus status,

    /// Delivery address as readable text. Null/empty for pickup.
    String? address,

    /// Delivery location pin, so the driver can navigate and the fee can be
    /// worked out by distance. Null for pickup.
    LatLng? addressLocation,

    /// Message the customer left with the order.
    String? customerNote,

    /// Applied promo code, uppercased, or null.
    String? promoCode,

    /// Null until Firestore has saved the server time.
    DateTime? placedAt,
    DateTime? statusSince,
  }) = _Order;

  const Order._();

  /// Reads orders/{id}. A document without a number or customer is
  /// malformed and throws, so it is skipped when reading a list.
  factory Order.fromFirestore(String id, Map<String, dynamic> data) {
    return Order(
      id: id,
      number: data.requiredInteger(OrderFields.number),
      customerId: data.requiredString(OrderFields.customerId),
      customerName: data.string(OrderFields.customerName),
      customerPhone: data.string(OrderFields.customerPhone),
      branchId: data.string(OrderFields.branchId),
      branchName: data.string(OrderFields.branchName),
      isDelivery: data.boolean(OrderFields.isDelivery, fallback: true),
      items: [
        for (final item in data.maps(OrderFields.items))
          OrderItem.fromMap(item),
      ],
      subtotal: data.decimal(OrderFields.subtotal),
      deliveryFee: data.decimal(OrderFields.deliveryFee),
      discount: data.decimal(OrderFields.discount),
      total: data.decimal(OrderFields.total),
      status: data.enumValue(
        OrderFields.status,
        OrderStatus.values,
        fallback: OrderStatus.pending,
      ),
      address: data.stringOrNull(OrderFields.address),
      addressLocation: data.latLng(OrderFields.addressLocation),
      customerNote: data.stringOrNull(OrderFields.customerNote),
      promoCode: data.stringOrNull(OrderFields.promoCode),
      placedAt: data.dateTime(OrderFields.placedAt),
      statusSince: data.dateTime(OrderFields.statusSince),
    );
  }

  /// Number of products, counting quantities.
  int get itemCount {
    var count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  bool get isPickup => !isDelivery;

  /// Fields for a new orders/{id} document. The id is the document id, so it
  /// is not saved as a field. `placedAt` and `statusSince` are added by the
  /// service with the server time, never the client clock.
  Map<String, dynamic> toFirestore() {
    return {
      OrderFields.number: number,
      OrderFields.customerId: customerId,
      OrderFields.customerName: customerName,
      OrderFields.customerPhone: customerPhone,
      OrderFields.branchId: branchId,
      OrderFields.branchName: branchName,
      OrderFields.isDelivery: isDelivery,
      OrderFields.items: [for (final item in items) item.toMap()],
      OrderFields.subtotal: subtotal,
      OrderFields.deliveryFee: deliveryFee,
      OrderFields.discount: discount,
      OrderFields.total: total,
      OrderFields.status: status.name,
      if (address != null && address!.isNotEmpty) OrderFields.address: address,
      if (addressLocation case final location?)
        OrderFields.addressLocation: toGeoPoint(location),
      if (customerNote != null && customerNote!.isNotEmpty)
        OrderFields.customerNote: customerNote,
      if (promoCode != null && promoCode!.isNotEmpty)
        OrderFields.promoCode: promoCode,
    };
  }
}
