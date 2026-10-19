import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/delivery_eta.dart';
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

/// Where a shortage stands.
enum ShortageStatus {
  /// The packer offered a replacement; waiting for the customer.
  proposed,

  /// The customer took the replacement.
  accepted,

  /// The line is gone: no replacement existed, or the customer declined it.
  removed,
}

/// An item a packer found unavailable while packing, and how it was settled.
/// Stored in `Order.shortages` under the line's id.
@freezed
abstract class LineShortage with _$LineShortage {
  const factory LineShortage({
    required ShortageStatus status,

    /// The offered replacement, shaped like an order line with the same
    /// `lineId` as the unavailable one. Null when there is none.
    OrderItem? replacement,

    /// Null until Firestore has saved the server time.
    DateTime? flaggedAt,

    /// When the customer decided. Null while [ShortageStatus.proposed].
    DateTime? decidedAt,
  }) = _LineShortage;

  const LineShortage._();

  /// Reads one entry of orders/{id}.shortages. An unknown status reads as
  /// proposed, not removed: guessing "removed" would change what the
  /// customer pays, while "proposed" changes nothing until someone decides.
  factory LineShortage.fromMap(Map<String, dynamic> map) {
    final replacement = map[ShortageFields.replacement];
    return LineShortage(
      status: map.enumValue(
        ShortageFields.status,
        ShortageStatus.values,
        fallback: ShortageStatus.proposed,
      ),
      replacement: replacement is Map
          ? OrderItem.fromMap(Map<String, dynamic>.from(replacement))
          : null,
      flaggedAt: map.dateTime(ShortageFields.flaggedAt),
      decidedAt: map.dateTime(ShortageFields.decidedAt),
    );
  }

  /// Fields for one entry of orders/{id}.shortages. Unset values are left
  /// out.
  Map<String, dynamic> toMap() {
    return {
      ShortageFields.status: status.name,
      if (replacement case final item?)
        ShortageFields.replacement: item.toMap(),
      if (flaggedAt case final time?)
        ShortageFields.flaggedAt: toTimestamp(time),
      if (decidedAt case final time?)
        ShortageFields.decidedAt: toTimestamp(time),
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

    /// Where the driver last reported being while the order is out for
    /// delivery, and when (server time). Null until the first fix.
    LatLng? driverPosition,
    DateTime? driverPositionAt,

    /// Items a packer found unavailable, by line id. See [LineShortage].
    @Default(<String, LineShortage>{}) Map<String, LineShortage> shortages,
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
      driverPosition: data.latLng(OrderFields.driverPosition),
      driverPositionAt: data.dateTime(OrderFields.driverPositionAt),
      shortages: {
        for (final entry in data.mapOfMaps(OrderFields.shortages).entries)
          entry.key: LineShortage.fromMap(entry.value),
      },
    );
  }

  bool get isPickup => !isDelivery;

  /// Number of products, counting quantities, after any shortages.
  int get itemCount {
    var count = 0;
    for (final item in effectiveItems) {
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

  /// True if [lineId] is ticked. A removed line is never ticked: it is not
  /// packed at all.
  bool isPacked(String lineId) {
    return !isRemoved(lineId) && packedLineIds.contains(lineId);
  }

  /// Order lines packed so far. Worked out from the checklist.
  int get packedLineCount {
    return items.where((item) => isPacked(item.lineId)).length;
  }

  /// Lines that still have to be packed: every line except removed ones.
  int get lineCount => items.length - removedLineIds.length;

  /// True once every remaining line is ticked and no replacement is waiting
  /// for the customer.
  bool get isFullyPacked => packedLineCount == lineCount && !hasOpenShortage;

  /// From 0 to 1, for progress bars.
  double get packingProgress {
    return lineCount == 0 ? 0 : packedLineCount / lineCount;
  }

  // Shortages.

  /// The shortage on [lineId], or null if the line is fine.
  LineShortage? shortageOf(String lineId) => shortages[lineId];

  /// True if the line was taken out of the order.
  bool isRemoved(String lineId) {
    return shortages[lineId]?.status == ShortageStatus.removed;
  }

  /// Ids of the lines taken out of the order, in order-line order.
  Set<String> get removedLineIds {
    return {
      for (final item in items)
        if (isRemoved(item.lineId)) item.lineId,
    };
  }

  /// Shortages waiting for the customer's decision.
  int get openShortageCount {
    return shortages.values
        .where((shortage) => shortage.status == ShortageStatus.proposed)
        .length;
  }

  bool get hasOpenShortage => openShortageCount > 0;

  /// What the order holds now: removed lines are gone and accepted
  /// replacements stand in for the line they replace. A replacement still
  /// waiting for the customer changes nothing yet.
  List<OrderItem> get effectiveItems {
    return [
      for (final item in items)
        if (shortages[item.lineId] case final shortage?)
          if (shortage.status == ShortageStatus.accepted &&
              shortage.replacement != null)
            shortage.replacement!
          else if (shortage.status == ShortageStatus.proposed)
            item
          else
            ...const <OrderItem>[]
        else
          item,
    ];
  }

  /// Price of the lines in [effectiveItems], before the fee and discount.
  double get adjustedSubtotal {
    return effectiveItems.fold(0, (sum, item) => sum + item.lineTotal);
  }

  /// What the customer pays after shortages. Without any it is [total]
  /// exactly. The promo discount never exceeds the new subtotal.
  double get adjustedTotal {
    if (shortages.isEmpty) return total;
    final subtotal = adjustedSubtotal;
    final reduction = discount > subtotal ? subtotal : discount;
    final value = subtotal + deliveryFee - reduction;
    return value < 0 ? 0 : value;
  }

  /// How much [adjustedTotal] differs from what was paid: negative is a
  /// refund, positive is extra to pay for a dearer replacement.
  double get adjustment => adjustedTotal - total;

  // Delivery tracking.

  /// The driver's estimated arrival while the order is out for delivery, or
  /// null when it cannot be worked out (not on the road, no delivery pin, or
  /// the driver has not reported a position yet).
  DeliveryEta? etaAt(DateTime now) {
    final from = driverPosition;
    final to = addressLocation;
    final reportedAt = driverPositionAt;
    if (status != OrderStatus.outForDelivery ||
        !isDelivery ||
        from == null ||
        to == null ||
        reportedAt == null) {
      return null;
    }
    return DeliveryEta.estimate(
      from: from,
      to: to,
      reportedAt: reportedAt,
      now: now,
    );
  }

  /// True if the order has a line with this id.
  bool hasLine(String lineId) => items.any((item) => item.lineId == lineId);

  // Bag label.

  /// Text inside the order's QR label. Includes the collection code, so
  /// the QR cannot be made up from the order number alone.
  String get qrPayload => 'grocerly:order:$id:$collectionCode';

  /// Text inside the QR code the customer shows at the counter to collect a
  /// self-pickup order. It differs from [qrPayload] (the bag label), so
  /// scanning the label by mistake is told apart from the customer's code.
  String get handoverQrPayload => 'grocerly:handover:$id:$collectionCode';

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
    for (final item in items) {
      final shortage = shortages[item.lineId];
      if (shortage == null) continue;
      add('${item.name} unavailable', shortage.flaggedAt, packer);
      final decidedAt = shortage.decidedAt;
      if (decidedAt != null) {
        add(
          shortage.status == ShortageStatus.accepted
              ? 'Replacement for ${item.name} accepted'
              : '${item.name} removed',
          decidedAt,
          null,
        );
      }
    }
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
      OrderFields.driverPositionAt: stamp(driverPositionAt),
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
      if (driverPosition case final position?)
        OrderFields.driverPosition: toGeoPoint(position),
      if (packedLineIds.isNotEmpty)
        OrderFields.packedLineIds: packedLineIds.toList()..sort(),
      if (shortages.isNotEmpty)
        OrderFields.shortages: {
          for (final entry in shortages.entries) entry.key: entry.value.toMap(),
        },
      for (final entry in texts.entries)
        if (has(entry.value)) entry.key: entry.value,
      for (final entry in timestamps.entries)
        if (entry.value != null) entry.key: entry.value,
    };
  }
}
