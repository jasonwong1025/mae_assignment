/// The one place that names Firestore collections and the document fields
/// the app reads and writes. Services and model converters reference these
/// instead of string literals, so a typo is a compile error rather than a
/// silent runtime (or security) bug, and the shape stays in sync with
/// `firestore.rules`.
///
/// Keep this in step with `firestore.rules`: both describe the same schema.
library;

/// Firestore collection and subcollection names.
class FirestoreCollections {
  FirestoreCollections._();

  /// users/{uid} — one profile per Firebase Authentication account.
  static const String users = 'users';

  /// products/{productId} — the shared catalogue, same across branches.
  static const String products = 'products';

  /// categories/{categoryId} — catalogue categories.
  static const String categories = 'categories';

  /// branches/{branchId} — store locations.
  static const String branches = 'branches';

  /// branches/{branchId}/inventory/{productId} — per-branch price and stock.
  static const String inventory = 'inventory';

  /// orders/{orderId} — one document per placed order. Written by the
  /// trusted checkout Function; read by the customer (tracking) and by the
  /// Store Worker / Store Admin apps.
  static const String orders = 'orders';

  /// users/{uid}/addresses/{addressId} — a customer's saved delivery
  /// addresses, each with a map location. Owner-only.
  static const String addresses = 'addresses';

  /// users/{uid}/cart/current — the customer's saved cart, one document so
  /// every change is atomic. Owner-only.
  static const String cart = 'cart';

  /// users/{uid}/groceryList/current — the customer's grocery list (things
  /// they plan to buy, typed or scanned from a written list), one document
  /// so every change is atomic. Owner-only.
  static const String groceryList = 'groceryList';

  /// users/{uid}/wallet/current — the customer's simulated wallet balance.
  /// Read-only for the owner; only the Cloud Functions change it.
  static const String wallet = 'wallet';

  /// users/{uid}/walletTransactions/{id} — the wallet's history (top ups,
  /// payments, refunds). Read-only for the owner.
  static const String walletTransactions = 'walletTransactions';

  /// users/{uid}/notifications/{id} — the in-app notification inbox, filled
  /// by the Cloud Functions when an order changes.
  static const String notifications = 'notifications';

  /// users/{uid}/devices/{fcmToken} — phones registered for push
  /// notifications. The document id is the Firebase Cloud Messaging token.
  static const String devices = 'devices';

  /// reviews/{orderId} — a customer's rating of one completed order. The
  /// document id is the order id, so an order can be rated only once.
  static const String reviews = 'reviews';

  /// driverLocations/{driverId} — where a delivery driver is now. Written by
  /// the driver's own app, read by Store Admin's Dispatch map. The document
  /// id is the driver's uid.
  static const String driverLocations = 'driverLocations';

  /// counters/{name} — monotonic counters (e.g. the order number sequence)
  /// incremented by the checkout Function transaction. Not per-user: a
  /// customer cannot read other customers' orders, so the next number comes
  /// from here
  /// rather than from scanning the orders collection.
  static const String counters = 'counters';
}

/// Document ids in users/{uid}/cart.
class CartDocs {
  CartDocs._();

  /// The one cart a customer has.
  static const String current = 'current';
}

/// Field keys in users/{uid}/cart/current.
///
/// Only ids and quantities are stored. Names, prices and stock come from the
/// catalogue when the cart is loaded, so a saved cart never shows stale
/// prices.
class CartFields {
  CartFields._();

  /// Array of maps; see [CartLineFields].
  static const String lines = 'lines';

  /// A `FulfilmentMethod` name: "delivery" or "pickup".
  static const String fulfilment = 'fulfilment';

  /// Promo code applied, uppercased. Absent if none.
  static const String promoCode = 'promoCode';

  /// Server time of the last change.
  static const String updatedAt = 'updatedAt';
}

/// Field keys for one entry in the cart's `lines` array.
class CartLineFields {
  CartLineFields._();

  static const String productId = 'productId';
  static const String quantity = 'quantity';
}

/// Document ids in users/{uid}/wallet.
class WalletDocs {
  WalletDocs._();

  /// The one wallet a customer has.
  static const String current = 'current';
}

/// Field keys in users/{uid}/wallet/current.
class WalletFields {
  WalletFields._();

  /// Money available, in ringgit. Can dip below zero after a replacement that
  /// costs more than the item it replaced; checkout then asks for a top up.
  static const String balance = 'balance';
  static const String updatedAt = 'updatedAt';
}

/// Field keys in users/{uid}/walletTransactions/{id}.
class WalletEntryFields {
  WalletEntryFields._();

  /// `topUp`, `payment`, `refund` or `adjustment`.
  static const String type = 'type';

  /// Signed: positive adds money, negative takes it.
  static const String amount = 'amount';
  static const String balanceAfter = 'balanceAfter';
  static const String description = 'description';

  /// The order a payment, refund or adjustment belongs to. Absent for top ups.
  static const String orderId = 'orderId';
  static const String createdAt = 'createdAt';
}

/// Field keys in users/{uid}/notifications/{id}.
class NotificationFields {
  NotificationFields._();

  static const String title = 'title';
  static const String body = 'body';

  /// The order the notification is about. Absent if none.
  static const String orderId = 'orderId';
  static const String read = 'read';
  static const String createdAt = 'createdAt';
}

/// Field keys in users/{uid}/devices/{token}.
class DeviceFields {
  DeviceFields._();

  /// `android`, `ios` or `web`.
  static const String platform = 'platform';
  static const String updatedAt = 'updatedAt';
}

/// Document ids in users/{uid}/groceryList.
class GroceryListDocs {
  GroceryListDocs._();

  /// The one list a customer has.
  static const String current = 'current';
}

/// Field keys in users/{uid}/groceryList/current.
class GroceryListFields {
  GroceryListFields._();

  /// Array of maps; see [GroceryItemFields].
  static const String items = 'items';

  /// Server time of the last change.
  static const String updatedAt = 'updatedAt';
}

/// Field keys for one entry in the grocery list's `items` array.
class GroceryItemFields {
  GroceryItemFields._();

  /// Unique within the list.
  static const String id = 'id';

  /// What the customer wrote, e.g. "fresh milk".
  static const String name = 'name';
  static const String quantity = 'quantity';

  /// The product the customer picked for this item. Absent when the app
  /// should find the best match itself.
  static const String productId = 'productId';
}

/// Document ids and field keys for counters/{name}.
class CounterDocs {
  CounterDocs._();

  /// counters/orders holds the last order number issued.
  static const String orders = 'orders';
}

/// Field keys in counters/{name}.
class CounterFields {
  CounterFields._();

  /// The last value handed out. The next id is this plus one.
  static const String value = 'value';
}

/// Field keys in users/{uid}.
class UserFields {
  UserFields._();

  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String role = 'role';
  static const String createdAt = 'createdAt';

  /// Store Workers only. False if HQ deactivated them.
  static const String isActive = 'isActive';

  /// Store Workers only: "packingStaff" or "deliveryDriver".
  static const String workerRole = 'workerRole';

  /// Store Workers only: the packer's branch (absent/null for drivers).
  static const String branchId = 'branchId';

  /// Store Workers only: server time HQ created the account.
  static const String joinedAt = 'joinedAt';
}

/// Field keys in branches/{branchId}.
class BranchFields {
  BranchFields._();

  static const String name = 'name';
  static const String address = 'address';
  static const String phone = 'phone';
  static const String location = 'location';
  static const String weeklyHours = 'weeklyHours';
  static const String maxDeliveryKm = 'maxDeliveryKm';
  static const String baseDeliveryFee = 'baseDeliveryFee';
  static const String feePerKm = 'feePerKm';
  static const String isTemporarilyClosed = 'isTemporarilyClosed';

  /// Server time the branch was created; branches are listed oldest first.
  static const String createdAt = 'createdAt';
}

/// Field keys for one entry in branches/{branchId}.weeklyHours.
class DayHoursFields {
  DayHoursFields._();

  /// Minutes after midnight.
  static const String opensAt = 'opensAt';
  static const String closesAt = 'closesAt';
  static const String isClosed = 'isClosed';
}

/// Field keys in products/{productId}.
class ProductFields {
  ProductFields._();

  static const String name = 'name';
  static const String brand = 'brand';
  static const String categoryId = 'categoryId';
  static const String packSize = 'packSize';
  static const String description = 'description';
  static const String imageUrls = 'imageUrls';

  /// Stock at or below this counts as low in the Inventory tab. Written by
  /// the Store Admin app; the customer app ignores it.
  static const String lowStockLevel = 'lowStockLevel';
}

/// Field keys in categories/{categoryId}.
class CategoryFields {
  CategoryFields._();

  static const String name = 'name';
  static const String sortOrder = 'sortOrder';
}

/// Field keys in branches/{branchId}/inventory/{productId}.
class InventoryFields {
  InventoryFields._();

  static const String price = 'price';
  static const String stock = 'stock';
  static const String isHidden = 'isHidden';
}

/// Field keys in driverLocations/{driverId}.
class DriverLocationFields {
  DriverLocationFields._();

  /// GeoPoint of the driver's last known position.
  static const String position = 'position';

  /// Server time the position was recorded. Old positions are stale.
  static const String updatedAt = 'updatedAt';
}

/// Field keys in orders/{orderId}.
///
/// This is the shared order contract. The customer app writes it at
/// checkout; the Store Worker and Store Admin apps read it. The field
/// names match the convention already used by the Store Worker's in-memory
/// `WorkerOrder`, so the worker side can read these documents later with
/// minimal change.
class OrderFields {
  OrderFields._();

  /// Human-facing number, e.g. 2301 for "#2301". Admin/sales/reviews join
  /// on this; the worker and customer apps route by the document id.
  static const String number = 'number';

  /// Firebase Authentication uid of the customer who placed the order.
  static const String customerId = 'customerId';
  static const String customerName = 'customerName';
  static const String customerPhone = 'customerPhone';

  static const String branchId = 'branchId';
  static const String branchName = 'branchName';

  /// True for delivery, false for self-pickup.
  static const String isDelivery = 'isDelivery';

  /// Delivery address, as readable text. Absent/empty for pickup.
  static const String address = 'address';

  /// Delivery address location (GeoPoint), so the worker/driver can
  /// navigate and the fee can be worked out by distance. Absent for pickup.
  static const String addressLocation = 'addressLocation';

  /// Optional message the customer left with the order.
  static const String customerNote = 'customerNote';

  /// The order lines; see [OrderItemFields].
  static const String items = 'items';

  /// Promo code applied, uppercased, or absent if none.
  static const String promoCode = 'promoCode';
  static const String collectionCode = 'collectionCode';

  // Money, in ringgit, captured at checkout so totals never drift if a
  // price changes later.
  static const String subtotal = 'subtotal';
  static const String deliveryFee = 'deliveryFee';
  static const String discount = 'discount';
  static const String total = 'total';

  /// Fulfilment stage; stored as an `OrderStatus` name, e.g. "packing".
  static const String status = 'status';

  /// Server time the order was placed.
  static const String placedAt = 'placedAt';

  /// Server time the order last changed status.
  static const String statusSince = 'statusSince';

  /// When the customer was promised the order (pickup or delivery time).
  static const String dueAt = 'dueAt';

  /// Where the bag is collected from: the branch's address.
  static const String branchAddress = 'branchAddress';

  // Assignment, written by Store Admin (HQ).
  static const String packerId = 'packerId';
  static const String packerName = 'packerName';
  static const String packerAssignedAt = 'packerAssignedAt';
  static const String driverId = 'driverId';
  static const String driverName = 'driverName';
  static const String driverAssignedAt = 'driverAssignedAt';

  // Fulfilment, written by the Store Worker app.

  /// Line ids already packed (array of strings).
  static const String packedLineIds = 'packedLineIds';
  static const String packingStartedAt = 'packingStartedAt';
  static const String readyAt = 'readyAt';
  static const String readyBy = 'readyBy';

  /// A `VerificationMethod` name.
  static const String pickupVerification = 'pickupVerification';
  static const String pickupCompletedBy = 'pickupCompletedBy';
  static const String pickupCompletedByName = 'pickupCompletedByName';
  static const String collectionVerification = 'collectionVerification';
  static const String collectionVerifiedBy = 'collectionVerifiedBy';
  static const String collectionVerifiedAt = 'collectionVerifiedAt';
  static const String outForDeliveryAt = 'outForDeliveryAt';
  static const String deliveredBy = 'deliveredBy';
  static const String deliveredByName = 'deliveredByName';

  /// Download URL of the delivery proof photo.
  static const String proofPhotoUrl = 'proofPhotoUrl';
  static const String completedAt = 'completedAt';

  /// Where the driver last was while the order is out for delivery (a
  /// GeoPoint), and the server time of that fix. Written only by the order's
  /// driver, so the customer who owns the order can follow the delivery.
  static const String driverPosition = 'driverPosition';
  static const String driverPositionAt = 'driverPositionAt';

  // Shortages: items a packer found unavailable, and what the customer
  // decided. See [ShortageFields] and `Order.shortages`.

  /// Map of line id to the shortage on that line (one entry per line).
  static const String shortages = 'shortages';

  /// The line id the current write is about. A write changes exactly one
  /// entry of [shortages], and `firestore.rules` reads this field to know
  /// which one to check. Readers ignore it.
  static const String shortageLineId = 'shortageLineId';

  /// Number of shortages waiting for the customer's decision. Kept next to
  /// [shortages] only so `firestore.rules` can see it (rules cannot count
  /// the entries of a map); the app works the count out from [shortages].
  static const String openShortages = 'openShortages';

  /// Times that Store Worker and Store Admin workflow actions record. They
  /// are always saved as the server time (`FieldValue.serverTimestamp()`),
  /// never the phone's clock, and `firestore.rules` requires that.
  static const List<String> serverTimeKeys = [
    statusSince,
    packingStartedAt,
    readyAt,
    collectionVerifiedAt,
    outForDeliveryAt,
    completedAt,
  ];

  /// Fields only the checkout Function writes. Nobody else may
  /// change them afterwards.
  static const List<String> checkoutKeys = [
    number,
    customerId,
    customerName,
    customerPhone,
    branchId,
    branchName,
    branchAddress,
    isDelivery,
    address,
    addressLocation,
    customerNote,
    items,
    promoCode,
    collectionCode,
    subtotal,
    deliveryFee,
    discount,
    total,
    placedAt,
  ];

  /// Fields Store Admin may change.
  static const List<String> assignmentKeys = [
    dueAt,
    packerId,
    packerName,
    packerAssignedAt,
    driverId,
    driverName,
    driverAssignedAt,
  ];

  /// Fields the Store Worker app may change.
  static const List<String> fulfilmentKeys = [
    packedLineIds,
    packingStartedAt,
    readyAt,
    readyBy,
    pickupVerification,
    pickupCompletedBy,
    pickupCompletedByName,
    collectionVerification,
    collectionVerifiedBy,
    collectionVerifiedAt,
    outForDeliveryAt,
    deliveredBy,
    deliveredByName,
    proofPhotoUrl,
    completedAt,
    driverPosition,
    driverPositionAt,
  ];
}

/// Field keys in one entry of orders/{orderId}.shortages.
class ShortageFields {
  ShortageFields._();

  /// `proposed` (waiting for the customer), `accepted` (replacement taken) or
  /// `removed` (no replacement, or the customer declined it).
  static const String status = 'status';

  /// The offered replacement, shaped like an order line (see
  /// [OrderItemFields]) with the same `lineId` as the unavailable one.
  /// Absent when there is no replacement.
  static const String replacement = 'replacement';

  /// Server time the packer flagged the line.
  static const String flaggedAt = 'flaggedAt';

  /// Server time the customer decided. Absent while `proposed`.
  static const String decidedAt = 'decidedAt';
}

/// Field keys for one entry in the orders/{orderId}.items array.
class OrderItemFields {
  OrderItemFields._();

  /// Unique within the order and never reused, so the same product can
  /// appear on two lines and the worker's packing checklist can key on it.
  static const String lineId = 'lineId';
  static const String productId = 'productId';
  static const String name = 'name';
  static const String brand = 'brand';
  static const String packSize = 'packSize';
  static const String quantity = 'quantity';

  /// Price of one at the order's branch, captured at checkout.
  static const String unitPrice = 'unitPrice';

  /// Cover image URL, or absent if the product has none.
  static const String imageUrl = 'imageUrl';

  /// Category id and name at checkout; absent on older orders.
  static const String categoryId = 'categoryId';
  static const String category = 'category';

  /// Product description at checkout; absent if empty.
  static const String description = 'description';
}

/// Field keys in reviews/{orderId}.
class ReviewFields {
  ReviewFields._();

  static const String orderNumber = 'orderNumber';
  static const String branchId = 'branchId';
  static const String customerId = 'customerId';
  static const String customerName = 'customerName';

  /// How the shopping experience went, 1 to 5.
  static const String shoppingScore = 'shoppingScore';

  /// Quality of the products, 1 to 5.
  static const String productScore = 'productScore';

  /// Delivery, 1 to 5. Present only for delivery orders.
  static const String deliveryScore = 'deliveryScore';

  /// Driver who delivered the order (delivery orders only), copied from the
  /// order so the admin can rate drivers without reading every order.
  static const String driverId = 'driverId';
  static const String driverName = 'driverName';

  /// Optional written feedback, at most [maxCommentLength] characters.
  static const String comment = 'comment';
  static const int maxCommentLength = 500;

  /// Server time the review was written.
  static const String createdAt = 'createdAt';
}

/// Field keys in users/{uid}/addresses/{addressId}.
class AddressFields {
  AddressFields._();

  /// Short name the customer gives it, e.g. "Home" or "Office".
  static const String label = 'label';

  /// The full address as readable text (what shows on the order).
  static const String line = 'line';

  /// Map location (GeoPoint): where to deliver.
  static const String location = 'location';

  /// Optional delivery note, e.g. "leave at the guardhouse".
  static const String note = 'note';

  /// True for the one address used by default at checkout.
  static const String isDefault = 'isDefault';

  /// Server time the address was saved, for stable ordering.
  static const String createdAt = 'createdAt';
}
