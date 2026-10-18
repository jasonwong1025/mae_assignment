/// Shared Firestore settings, so every service behaves the same.
class FirestoreConfig {
  FirestoreConfig._();

  /// How long to wait for a read before giving up. Without a limit,
  /// `get()` retries forever when the backend is unreachable and the screen
  /// spins. Apply it with `.timeout(FirestoreConfig.readTimeout)`.
  static const Duration readTimeout = Duration(seconds: 15);
}
