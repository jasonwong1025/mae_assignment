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
}

/// Field keys in users/{uid}.
class UserFields {
  UserFields._();

  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String role = 'role';
  static const String createdAt = 'createdAt';
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
