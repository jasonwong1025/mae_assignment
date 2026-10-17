/// A delivery driver as Dispatch sees them.
class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.isOnDuty,
    this.currentOrderNumber,
  });

  final String id;
  final String name;
  final bool isOnDuty;

  /// Order being delivered now. Null if free.
  final int? currentOrderNumber;

  /// Copy working on [orderNumber]. Null makes the driver free.
  Driver withCurrentOrder(int? orderNumber) {
    return Driver(
      id: id,
      name: name,
      isOnDuty: isOnDuty,
      currentOrderNumber: orderNumber,
    );
  }
}
