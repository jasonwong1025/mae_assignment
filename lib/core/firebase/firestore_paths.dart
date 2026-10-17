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
  /// customer at checkout; read by the customer (tracking) and by the
  /// Store Worker / Store Admin apps.
  static const String orders = 'orders';

  /// users/{uid}/addresses/{addressId} — a customer's saved delivery
  /// addresses, each with a map location. Owner-only.
  static const String addresses = 'addresses';
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
