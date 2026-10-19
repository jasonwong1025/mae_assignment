import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';

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

    /// Category id and name, e.g. "Dairy & Eggs". Empty if unknown.
    @Default('') String categoryId,
    @Default('') String category,

    /// Product description from the catalogue. Can be empty.
    @Default('') String description,

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
      categoryId: map.string(OrderItemFields.categoryId),
      category: map.string(OrderItemFields.category),
      description: map.string(OrderItemFields.description),
      imageUrl: map.stringOrNull(OrderItemFields.imageUrl),
    );
  }

  /// Price for this line: unit price times quantity.
  double get lineTotal => unitPrice * quantity;

  /// Fields for the orders/{orderId}.items array. Empty optional fields are
  /// left out.
  Map<String, dynamic> toMap() {
    return {
      OrderItemFields.lineId: lineId,
      OrderItemFields.productId: productId,
      OrderItemFields.name: name,
      OrderItemFields.brand: brand,
      OrderItemFields.packSize: packSize,
      OrderItemFields.quantity: quantity,
      OrderItemFields.unitPrice: unitPrice,
      if (categoryId.isNotEmpty) OrderItemFields.categoryId: categoryId,
      if (category.isNotEmpty) OrderItemFields.category: category,
      if (description.isNotEmpty) OrderItemFields.description: description,
      if (imageUrl != null && imageUrl!.isNotEmpty)
        OrderItemFields.imageUrl: imageUrl,
    };
  }
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

/// One customer order, stored at orders/{orderId}.
///
/// The single order contract shared by all three apps. The customer app
/// writes the checkout fields and reads the rest for tracking; Store Admin
/// writes the assignment fields; Store Worker writes the fulfilment fields.
/// It carries both a string [id] (the document id, used in routes) and an
/// int [number] (shown to people and used by admin, sales and reviews).
///
/// Immutable: every change makes a new copy with [copyWith].
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

    /// Where the bag is collected from (the branch's address), shown to
    /// drivers, who can be given deliveries from any branch.
    String? branchAddress,

    /// Null until Firestore has saved the server time.
    DateTime? placedAt,

    /// When the order entered its current status.
    DateTime? statusSince,

    /// When the customer was promised the order: pickup time or delivery
    /// time. Packing tasks are sorted by this, soonest first.
    DateTime? dueAt,

    // Assignment, set by HQ (Store Admin).
    String? packerId,
    String? packerName,
    DateTime? packerAssignedAt,

    /// Delivery orders only.
    String? driverId,
    String? driverName,
    DateTime? driverAssignedAt,

    // Fulfilment, written by the Store Worker app.

    /// Line ids already packed.
    @Default(<String>{}) Set<String> packedLineIds,
    DateTime? packingStartedAt,
    DateTime? readyAt,

    /// Worker id of the packer who marked the order ready.
    String? readyBy,

    // Self-pickup handover.
    VerificationMethod? pickupVerification,
    String? pickupCompletedBy,
    String? pickupCompletedByName,

    // Home delivery.
    VerificationMethod? collectionVerification,

    /// Driver who verified the bag. Start delivery needs this to be the
    /// driver assigned now, so a replacement driver must verify again.
    String? collectionVerifiedBy,
    DateTime? collectionVerifiedAt,
    DateTime? outForDeliveryAt,
    String? deliveredBy,
    String? deliveredByName,

    /// Photo the driver took when delivering, as a Storage download URL.
    String? proofPhotoUrl,

    /// When the order was completed, by pickup or by delivery.
    DateTime? completedAt,
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
      branchAddress: data.stringOrNull(OrderFields.branchAddress),
      placedAt: data.dateTime(OrderFields.placedAt),
      statusSince: data.dateTime(OrderFields.statusSince),
      dueAt: data.dateTime(OrderFields.dueAt),
      packerId: data.stringOrNull(OrderFields.packerId),
      packerName: data.stringOrNull(OrderFields.packerName),
      packerAssignedAt: data.dateTime(OrderFields.packerAssignedAt),
      driverId: data.stringOrNull(OrderFields.driverId),
      driverName: data.stringOrNull(OrderFields.driverName),
      driverAssignedAt: data.dateTime(OrderFields.driverAssignedAt),
      packedLineIds: data.strings(OrderFields.packedLineIds).toSet(),
      packingStartedAt: data.dateTime(OrderFields.packingStartedAt),
      readyAt: data.dateTime(OrderFields.readyAt),
      readyBy: data.stringOrNull(OrderFields.readyBy),
      pickupVerification: data.enumOrNull(
        OrderFields.pickupVerification,
        VerificationMethod.values,
      ),
      pickupCompletedBy: data.stringOrNull(OrderFields.pickupCompletedBy),
      pickupCompletedByName: data.stringOrNull(
        OrderFields.pickupCompletedByName,
      ),
      collectionVerification: data.enumOrNull(
        OrderFields.collectionVerification,
        VerificationMethod.values,
      ),
      collectionVerifiedBy: data.stringOrNull(OrderFields.collectionVerifiedBy),
      collectionVerifiedAt: data.dateTime(OrderFields.collectionVerifiedAt),
      outForDeliveryAt: data.dateTime(OrderFields.outForDeliveryAt),
      deliveredBy: data.stringOrNull(OrderFields.deliveredBy),
      deliveredByName: data.stringOrNull(OrderFields.deliveredByName),
      proofPhotoUrl: data.stringOrNull(OrderFields.proofPhotoUrl),
      completedAt: data.dateTime(OrderFields.completedAt),
    );
  }

  bool get isPickup => !isDelivery;

  /// Number of products, counting quantities.
  int get itemCount {
    var count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  /// When the order entered its current status, for sorting. While the
  /// server times are still being saved the order has only just changed, so
  /// it counts as the newest possible.
  DateTime get statusStartedAt {
    return statusSince ??
        placedAt ??
        DateTime.fromMillisecondsSinceEpoch(8640000000000000);
  }

  /// Minutes spent in the current status. Falls back to the time since the
  /// order was placed, then 0, while the server times are still being saved.
  int minutesInStatus(DateTime now) {
    final since = statusSince ?? placedAt;
    return since == null ? 0 : now.difference(since).inMinutes;
  }

  // Packing checklist.

  bool isPacked(String lineId) => packedLineIds.contains(lineId);

  /// Order lines packed so far and in total. Worked out from the checklist.
  int get packedLineCount {
    return items.where((item) => packedLineIds.contains(item.lineId)).length;
  }

  int get lineCount => items.length;

  /// True once every line is ticked.
  bool get isFullyPacked => packedLineCount == lineCount;

  /// From 0 to 1, for progress bars.
  double get packingProgress {
    return lineCount == 0 ? 0 : packedLineCount / lineCount;
  }

  /// True if the order has a line with this id.
  bool hasLine(String lineId) => items.any((item) => item.lineId == lineId);

  // Bag label.

  /// Text inside the order's QR label. Includes the collection code, so
  /// the QR cannot be made up from the order number alone.
  String get qrPayload => 'grocerly:order:$id:$collectionCode';

  /// Short code printed on the bag label and nowhere in the driver's app,
  /// typed by the driver when the QR code cannot be scanned. Proves they
  /// are holding the bag, since the order number is already on their
  /// screen.
  ///
  /// MOCK ONLY, NOT SECURE: it is worked out from the order id, so anyone
  /// who can read the order can compute it. The real fix is a random code
  /// generated server-side per order (for example by a Cloud Function) and
  /// checked there.
  String get collectionCode {
    // No 0/O, 1/I/L, 2/Z, 5/S, 8/B: easy to misread on a label.
    const alphabet = 'ACDEFGHJKMNPQRTUVWXY3479';
    var hash = 0x811c9dc5;
    for (final unit in id.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    final code = StringBuffer();
    for (var i = 0; i < 6; i++) {
      code.write(alphabet[hash % alphabet.length]);
      hash = hash ~/ alphabet.length;
    }
    return code.toString();
  }

  // Admin views.

  /// Name of the staff member currently handling the order: the driver once
  /// one is assigned, otherwise the packer. First name only.
  String? get handledBy {
    final name = driverId != null ? driverName : packerName;
    if (name == null || name.trim().isEmpty) return null;
    return name.trim().split(' ').first;
  }

  /// What has happened to the order so far, oldest first. Worked out from
  /// the timestamps on the order, so it never needs storing.
  List<OrderEvent> get timeline {
    final events = <OrderEvent>[];
    void add(String title, DateTime? time, String? by) {
      if (time == null) return;
      events.add(OrderEvent(title: title, time: time, by: by));
    }

    final packer = packerName;
    add('Order placed', placedAt, null);
    add('Packing started', packingStartedAt, packer);
    add(
      isDelivery ? 'Ready for delivery' : 'Ready for pickup',
      readyAt,
      packer,
    );
    if (driverName != null) {
      add('Driver $driverName assigned', driverAssignedAt, 'Admin');
    }
    add('Out for delivery', outForDeliveryAt, driverName);
    add(
      isDelivery ? 'Delivered' : 'Picked up',
      completedAt,
      isDelivery ? (deliveredByName ?? driverName) : pickupCompletedByName,
    );
    if (status == OrderStatus.cancelled) {
      add('Cancelled', statusSince, null);
    }

    // Stable sort: events at the same instant keep the order added above.
    final indexed = events.indexed.toList()
      ..sort((a, b) {
        final byTime = a.$2.time.compareTo(b.$2.time);
        return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
      });
    return [for (final entry in indexed) entry.$2];
  }

  /// Copy with a new driver, noted in the timeline through
  /// [driverAssignedAt].
  Order withDriver({
    required String driverId,
    required String driverName,
    required DateTime now,
  }) {
    return copyWith(
      driverId: driverId,
      driverName: driverName,
      driverAssignedAt: now,
    );
  }

  /// Fields for a new orders/{id} document. The id is the document id, so it
  /// is not saved as a field. `placedAt` and `statusSince` are added by the
  /// service with the server time, never the client clock. Optional fields
  /// that are unset are left out, so a fresh checkout document holds only
  /// the checkout fields.
  Map<String, dynamic> toFirestore() {
    Object? stamp(DateTime? time) => time == null ? null : toTimestamp(time);

    bool has(String? text) => text != null && text.isNotEmpty;

    final timestamps = <String, Object?>{
      OrderFields.dueAt: stamp(dueAt),
      OrderFields.packerAssignedAt: stamp(packerAssignedAt),
      OrderFields.driverAssignedAt: stamp(driverAssignedAt),
      OrderFields.packingStartedAt: stamp(packingStartedAt),
      OrderFields.readyAt: stamp(readyAt),
      OrderFields.collectionVerifiedAt: stamp(collectionVerifiedAt),
      OrderFields.outForDeliveryAt: stamp(outForDeliveryAt),
      OrderFields.completedAt: stamp(completedAt),
    };
    final texts = <String, String?>{
      OrderFields.address: address,
      OrderFields.customerNote: customerNote,
      OrderFields.promoCode: promoCode,
      OrderFields.branchAddress: branchAddress,
      OrderFields.packerId: packerId,
      OrderFields.packerName: packerName,
      OrderFields.driverId: driverId,
      OrderFields.driverName: driverName,
      OrderFields.readyBy: readyBy,
      OrderFields.pickupVerification: pickupVerification?.name,
      OrderFields.pickupCompletedBy: pickupCompletedBy,
      OrderFields.pickupCompletedByName: pickupCompletedByName,
      OrderFields.collectionVerification: collectionVerification?.name,
      OrderFields.collectionVerifiedBy: collectionVerifiedBy,
      OrderFields.deliveredBy: deliveredBy,
      OrderFields.deliveredByName: deliveredByName,
      OrderFields.proofPhotoUrl: proofPhotoUrl,
    };

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
      if (addressLocation case final location?)
        OrderFields.addressLocation: toGeoPoint(location),
      if (packedLineIds.isNotEmpty)
        OrderFields.packedLineIds: packedLineIds.toList()..sort(),
      for (final entry in texts.entries)
        if (has(entry.value)) entry.key: entry.value,
      for (final entry in timestamps.entries)
        if (entry.value != null) entry.key: entry.value,
    };
  }
}
