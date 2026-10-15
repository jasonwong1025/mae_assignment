/// A Store Worker is exactly one of these two roles.
/// Shared by the store admin's Staff tab and the Store Worker app.
enum WorkerRole {
  packingStaff('Packing Staff'),
  deliveryDriver('Delivery Driver');

  const WorkerRole(this.label);

  /// Name shown on screen.
  final String label;
}
