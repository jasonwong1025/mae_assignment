import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
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

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      lineId: map[OrderItemFields.lineId] as String? ?? '',
      productId: map[OrderItemFields.productId] as String? ?? '',
      name: map[OrderItemFields.name] as String? ?? '',
      brand: map[OrderItemFields.brand] as String? ?? '',
      packSize: map[OrderItemFields.packSize] as String? ?? '',
      quantity: (map[OrderItemFields.quantity] as num?)?.toInt() ?? 0,
      unitPrice: (map[OrderItemFields.unitPrice] as num?)?.toDouble() ?? 0,
      imageUrl: map[OrderItemFields.imageUrl] as String?,
    );
  }

  /// Price for this line: unit price times quantity.
  double get lineTotal => unitPrice * quantity;

  /// Fields for the orders/{orderId}.items array.
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
/// This is the shared order contract: the customer app writes it at
/// checkout and reads it for tracking; the Store Worker and Store Admin
/// apps read it (and later update its status). It carries both a string
/// [id] (the document id, used in routes) and an int [number] (shown to
/// people and used by admin/sales/reviews to join), so neither side has to
/// reconcile the two identifiers later.
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

  /// Reads orders/{id}. Returns null if required fields are missing, so a
  /// malformed document is skipped rather than crashing a list.
  static Order? fromFirestore(String id, Map<String, dynamic> map) {
    final number = (map[OrderFields.number] as num?)?.toInt();
    final customerId = map[OrderFields.customerId] as String?;
    if (number == null || customerId == null) return null;

    return Order(
      id: id,
      number: number,
      customerId: customerId,
      customerName: map[OrderFields.customerName] as String? ?? '',
      customerPhone: map[OrderFields.customerPhone] as String? ?? '',
      branchId: map[OrderFields.branchId] as String? ?? '',
      branchName: map[OrderFields.branchName] as String? ?? '',
      isDelivery: map[OrderFields.isDelivery] as bool? ?? true,
      items: _itemsFrom(map[OrderFields.items]),
      subtotal: (map[OrderFields.subtotal] as num?)?.toDouble() ?? 0,
      deliveryFee: (map[OrderFields.deliveryFee] as num?)?.toDouble() ?? 0,
      discount: (map[OrderFields.discount] as num?)?.toDouble() ?? 0,
      total: (map[OrderFields.total] as num?)?.toDouble() ?? 0,
      status: _statusFrom(map[OrderFields.status]),
      address: map[OrderFields.address] as String?,
      addressLocation: _latLngFrom(map[OrderFields.addressLocation]),
      customerNote: map[OrderFields.customerNote] as String?,
      promoCode: map[OrderFields.promoCode] as String?,
      placedAt: _dateFrom(map[OrderFields.placedAt]),
      statusSince: _dateFrom(map[OrderFields.statusSince]),
    );
  }

  static List<OrderItem> _itemsFrom(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) OrderItem.fromMap(item),
    ];
  }

  static OrderStatus _statusFrom(Object? value) {
    for (final status in OrderStatus.values) {
      if (status.name == value) return status;
    }
    return OrderStatus.pending;
  }

  static DateTime? _dateFrom(Object? value) {
    return value is Timestamp ? value.toDate() : null;
  }

  static LatLng? _latLngFrom(Object? value) {
    return value is GeoPoint ? LatLng(value.latitude, value.longitude) : null;
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

  /// Fields for a new orders/{id} document. The id is the document id, so
  /// it is not saved as a field. Server timestamps are set here, not from
  /// the client clock, so [placedAt]/[statusSince] on this instance are
  /// ignored on write.
  Map<String, dynamic> toCreateMap() {
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
        OrderFields.addressLocation: GeoPoint(
          location.latitude,
          location.longitude,
        ),
      if (customerNote != null && customerNote!.isNotEmpty)
        OrderFields.customerNote: customerNote,
      if (promoCode != null && promoCode!.isNotEmpty)
        OrderFields.promoCode: promoCode,
      OrderFields.placedAt: FieldValue.serverTimestamp(),
      OrderFields.statusSince: FieldValue.serverTimestamp(),
    };
  }
}
