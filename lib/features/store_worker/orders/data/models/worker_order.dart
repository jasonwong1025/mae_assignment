import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

part 'worker_order.freezed.dart';

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
@freezed
abstract class WorkerOrderItem with _$WorkerOrderItem {
  const factory WorkerOrderItem({
    /// Unique within its order and never reused. The packing checklist is
    /// keyed by this, not by productId, so the same product can appear on
    /// two lines.
    required String lineId,
    required String productId,
    required String name,
    required String brand,

    /// E.g. "1L" or "500g".
    required String packSize,
    required int quantity,

    /// Price of one at the order's branch, in ringgit.
    @Default(0) double unitPrice,

    /// Category name, e.g. "Dairy & Eggs". Empty if unknown.
    @Default('') String category,

    /// Product description from the catalogue. Can be empty.
    @Default('') String description,

    /// Product photo. Null shows a placeholder.
    String? imageUrl,
  }) = _WorkerOrderItem;

  const WorkerOrderItem._();
}

/// One customer order, as the Store Worker app sees it.
///
/// Field names follow the shared order contract agreed with the admin and
/// customer sides, so connecting the backend later only changes how orders
/// are loaded. Immutable: every change makes a new copy with [copyWith].
@freezed
abstract class WorkerOrder with _$WorkerOrder {
  const factory WorkerOrder({
    /// Unique id. Used in routes and the QR label.
    required String id,

    /// Number shown to people, e.g. 2301 for "#2301".
    required int number,
    required String branchId,
    required String branchName,
    required String customerName,
    required String customerPhone,

    /// False for self-pickup.
    required bool isDelivery,
    required List<WorkerOrderItem> items,
    required OrderStatus status,
    required DateTime placedAt,

    /// When the order entered its current status.
    required DateTime statusSince,
    // Assignment, set by HQ.
    required String packerId,
    required String packerName,
    required DateTime packerAssignedAt,

    /// Where the bag is collected from (the branch's address), shown to
    /// drivers, who can be given deliveries from any branch.
    String? branchAddress,

    /// When the customer was promised the order: pickup time or delivery
    /// time. Packing tasks are sorted by this, soonest first.
    DateTime? dueAt,

    /// Line ids already packed.
    @Default(<String>{}) Set<String> packedLineIds,

    /// Delivery address. Null for pickup orders.
    String? address,

    /// Message the customer left with the order.
    String? customerNote,

    /// Delivery orders only.
    String? driverId,
    String? driverName,
    DateTime? driverAssignedAt,
    // Packing.
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

    /// Photo the driver took when delivering. Kept in memory for the mock;
    /// later uploaded to storage with only its URL on the order.
    Uint8List? proofPhoto,

    /// When the order was completed, by pickup or by delivery.
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) = _WorkerOrder;

  const WorkerOrder._();

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
}
