/// Where files live in Firebase Storage, in one place, like
/// `firestore_paths.dart` does for Firestore. `storage.rules` must agree.
class StoragePaths {
  StoragePaths._();

  /// A product photo: products/{productId}/{fileName}. Only the admin writes
  /// it; any signed-in user reads it.
  static String productPhoto(String productId, String fileName) {
    return 'products/$productId/$fileName';
  }
}
