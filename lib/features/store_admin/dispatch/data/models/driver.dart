import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver.freezed.dart';

/// A delivery driver as Dispatch sees them.
@freezed
abstract class Driver with _$Driver {
  const factory Driver({
    required String id,
    required String name,
    required bool isOnDuty,

    /// Order being delivered now. Null if free.
    int? currentOrderNumber,
  }) = _Driver;

  const Driver._();

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
