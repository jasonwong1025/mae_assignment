import 'dart:typed_data';

import 'package:mae_assignment/shared/models/order_status.dart';

/// How a worker confirmed an order at handover or collection.
/// Both only check that the right bag goes to the right order; neither
/// proves who the customer or driver is.
enum VerificationMethod {
  qr('QR scan'),
  manual('Manual check');

  const VerificationMethod(this.label);

  final String label;
}

/// One product line of an order, as a Store Worker sees it.
class WorkerOrderItem {
  const WorkerOrderItem({
    required this.lineId,
    required this.productId,
    required this.name,
    required this.brand,
    required this.packSize,
    required this.quantity,
    this.unitPrice = 0,
    this.category = '',
    this.description = '',
    this.imageUrl,
  });

  /// Unique within its order and never reused. The packing checklist is
  /// keyed by this, not by productId, so the same product can appear on
  /// two lines.
  final String lineId;
  final String productId;
  final String name;
  final String brand;

  /// E.g. "1L" or "500g".
  final String packSize;
  final int quantity;

  /// Price of one at the order's branch, in ringgit.
  final double unitPrice;

  /// Category name, e.g. "Dairy & Eggs". Empty if unknown.
  final String category;

  /// Product description from the catalogue. Can be empty.
  final String description;

  /// Product photo. Null shows a placeholder.
  final String? imageUrl;
}

/// One customer order, as the Store Worker app sees it.
///
/// Field names follow the shared order contract agreed with the admin and
/// customer sides, so connecting the backend later only changes how orders
/// are loaded. Immutable: every change makes a new copy with [copyWith].
class WorkerOrder {
  WorkerOrder({
    required this.id,
    required this.number,
    required this.branchId,
    required this.branchName,
    required this.customerName,
    required this.customerPhone,
    required this.isDelivery,
    required List<WorkerOrderItem> items,
    required this.status,
    required this.placedAt,
    required this.statusSince,
    required this.packerId,
    required this.packerName,
    required this.packerAssignedAt,
    this.branchAddress,
    this.dueAt,
    Set<String> packedLineIds = const {},
    this.address,
    this.customerNote,
    this.driverId,
    this.driverName,
    this.driverAssignedAt,
    this.packingStartedAt,
    this.readyAt,
    this.readyBy,
    this.pickupVerification,
    this.pickupCompletedBy,
    this.pickupCompletedByName,
    this.collectionVerification,
    this.collectionVerifiedBy,
    this.collectionVerifiedAt,
    this.outForDeliveryAt,
    this.deliveredBy,
    this.deliveredByName,
    this.proofPhoto,
    this.completedAt,
    this.cancelledAt,
  }) : items = List.unmodifiable(items),
       packedLineIds = Set.unmodifiable(packedLineIds);

  /// Unique id. Used in routes and the QR label.
  final String id;

  /// Number shown to people, e.g. 2301 for "#2301".
  final int number;

  final String branchId;
  final String branchName;

  /// Where the bag is collected from (the branch's address), shown to
  /// drivers, who can be given deliveries from any branch.
  final String? branchAddress;
  final String customerName;
  final String customerPhone;

  /// False for self-pickup.
  final bool isDelivery;

  /// Delivery address. Null for pickup orders.
  final String? address;

  /// Message the customer left with the order.
  final String? customerNote;

  final List<WorkerOrderItem> items;

  /// Line ids already packed.
  final Set<String> packedLineIds;

  final OrderStatus status;
  final DateTime placedAt;

  /// When the customer was promised the order: pickup time or delivery
  /// time. Packing tasks are sorted by this, soonest first.
  final DateTime? dueAt;

  /// When the order entered its current status.
  final DateTime statusSince;

  // Assignment, set by HQ.
  final String packerId;
  final String packerName;
  final DateTime packerAssignedAt;

  /// Delivery orders only.
  final String? driverId;
  final String? driverName;
  final DateTime? driverAssignedAt;

  // Packing.
  final DateTime? packingStartedAt;
  final DateTime? readyAt;

  /// Worker id of the packer who marked the order ready.
  final String? readyBy;

  // Self-pickup handover.
  final VerificationMethod? pickupVerification;
  final String? pickupCompletedBy;
  final String? pickupCompletedByName;

  // Home delivery.
  final VerificationMethod? collectionVerification;

  /// Driver who verified the bag. Start delivery needs this to be the
  /// driver assigned now, so a replacement driver must verify again.
  final String? collectionVerifiedBy;
  final DateTime? collectionVerifiedAt;
  final DateTime? outForDeliveryAt;
  final String? deliveredBy;
  final String? deliveredByName;

  /// Photo the driver took when delivering. Kept in memory for the mock;
  /// later uploaded to storage with only its URL on the order.
  final Uint8List? proofPhoto;

  /// When the order was completed, by pickup or by delivery.
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  bool get isPickup => !isDelivery;

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

  /// Number of products, counting quantities.
  int get itemCount {
    var count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  /// True if the order has a line with this id.
  bool hasLine(String lineId) => items.any((item) => item.lineId == lineId);

  /// Text inside the order's QR label. Includes the collection code, so
  /// the QR cannot be made up from the order number alone.
  String get qrPayload => 'grocerly:order:$id:$collectionCode';

  /// Short code printed on the bag label and nowhere in the driver's app,
  /// typed by the driver when the QR code cannot be scanned. Proves they
  /// are holding the bag, since the order number is already on their
  /// screen.
  ///
  /// Mock only: worked out from the order id so it stays the same across
  /// restarts. The backend will generate a random one per order.
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

  /// Copy with some values changed. Values left out keep their current
  /// value (nothing in the worker workflows sets a field back to null).
  WorkerOrder copyWith({
    Set<String>? packedLineIds,
    OrderStatus? status,
    DateTime? statusSince,
    DateTime? packingStartedAt,
    DateTime? readyAt,
    String? readyBy,
    VerificationMethod? pickupVerification,
    String? pickupCompletedBy,
    String? pickupCompletedByName,
    VerificationMethod? collectionVerification,
    String? collectionVerifiedBy,
    DateTime? collectionVerifiedAt,
    DateTime? outForDeliveryAt,
    String? deliveredBy,
    String? deliveredByName,
    Uint8List? proofPhoto,
    DateTime? completedAt,
  }) {
    return WorkerOrder(
      id: id,
      number: number,
      branchId: branchId,
      branchName: branchName,
      branchAddress: branchAddress,
      customerName: customerName,
      customerPhone: customerPhone,
      isDelivery: isDelivery,
      address: address,
      customerNote: customerNote,
      items: items,
      packedLineIds: packedLineIds ?? this.packedLineIds,
      status: status ?? this.status,
      placedAt: placedAt,
      dueAt: dueAt,
      statusSince: statusSince ?? this.statusSince,
      packerId: packerId,
      packerName: packerName,
      packerAssignedAt: packerAssignedAt,
      driverId: driverId,
      driverName: driverName,
      driverAssignedAt: driverAssignedAt,
      packingStartedAt: packingStartedAt ?? this.packingStartedAt,
      readyAt: readyAt ?? this.readyAt,
      readyBy: readyBy ?? this.readyBy,
      pickupVerification: pickupVerification ?? this.pickupVerification,
      pickupCompletedBy: pickupCompletedBy ?? this.pickupCompletedBy,
      pickupCompletedByName:
          pickupCompletedByName ?? this.pickupCompletedByName,
      collectionVerification:
          collectionVerification ?? this.collectionVerification,
      collectionVerifiedBy: collectionVerifiedBy ?? this.collectionVerifiedBy,
      collectionVerifiedAt: collectionVerifiedAt ?? this.collectionVerifiedAt,
      outForDeliveryAt: outForDeliveryAt ?? this.outForDeliveryAt,
      deliveredBy: deliveredBy ?? this.deliveredBy,
      deliveredByName: deliveredByName ?? this.deliveredByName,
      proofPhoto: proofPhoto ?? this.proofPhoto,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt,
    );
  }
}
