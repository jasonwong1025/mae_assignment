import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'branch.freezed.dart';

/// Opening hours for one day. Times are minutes after midnight,
/// e.g. 8:30am is 510.
@freezed
abstract class DayHours with _$DayHours {
  const factory DayHours({
    required int opensAt,
    required int closesAt,

    /// True if the branch does not open on this day.
    @Default(false) bool isClosed,
  }) = _DayHours;

  const DayHours._();

  /// Reads one entry of branches/{id}.weeklyHours.
  factory DayHours.fromMap(Map<String, dynamic> map) {
    if (map.boolean(DayHoursFields.isClosed, fallback: false)) return closed;
    return DayHours(
      opensAt: map.integer(DayHoursFields.opensAt),
      closesAt: map.integer(DayHoursFields.closesAt),
    );
  }

  /// A day the branch does not open.
  static const DayHours closed = DayHours(
    opensAt: 0,
    closesAt: 0,
    isClosed: true,
  );

  Map<String, dynamic> toMap() {
    return {
      DayHoursFields.opensAt: opensAt,
      DayHoursFields.closesAt: closesAt,
      DayHoursFields.isClosed: isClosed,
    };
  }
}

/// One store location of the retailer, stored at branches/{branchId}.
@freezed
abstract class Branch with _$Branch {
  const factory Branch({
    required String id,
    required String name,
    required String address,
    required String phone,

    /// Where the store is on the map.
    required LatLng location,

    /// Hours for Monday to Sunday (7 items, Monday first).
    required List<DayHours> weeklyHours,

    /// Furthest road distance the branch delivers to.
    required double maxDeliveryKm,

    /// Delivery fee = base fee + fee per km (road distance), in ringgit.
    required double baseDeliveryFee,
    required double feePerKm,

    /// True if customers cannot place new orders here for now.
    @Default(false) bool isTemporarilyClosed,
  }) = _Branch;

  const Branch._();

  /// Reads branches/{id}.
  factory Branch.fromFirestore(String id, Map<String, dynamic> data) {
    return Branch(
      id: id,
      name: data.string(BranchFields.name),
      address: data.string(BranchFields.address),
      phone: data.string(BranchFields.phone),
      location: data.latLng(BranchFields.location) ?? const LatLng(0, 0),
      weeklyHours: [
        for (final day in data.maps(BranchFields.weeklyHours))
          DayHours.fromMap(day),
      ],
      maxDeliveryKm: data.decimal(BranchFields.maxDeliveryKm),
      baseDeliveryFee: data.decimal(BranchFields.baseDeliveryFee),
      feePerKm: data.decimal(BranchFields.feePerKm),
      isTemporarilyClosed: data.boolean(
        BranchFields.isTemporarilyClosed,
        fallback: false,
      ),
    );
  }

  /// Fields saved in branches/{id}. The id is the document id. `createdAt`
  /// is added by the service with the server time.
  Map<String, dynamic> toFirestore() {
    return {
      BranchFields.name: name,
      BranchFields.address: address,
      BranchFields.phone: phone,
      BranchFields.location: toGeoPoint(location),
      BranchFields.weeklyHours: [for (final day in weeklyHours) day.toMap()],
      BranchFields.maxDeliveryKm: maxDeliveryKm,
      BranchFields.baseDeliveryFee: baseDeliveryFee,
      BranchFields.feePerKm: feePerKm,
      BranchFields.isTemporarilyClosed: isTemporarilyClosed,
    };
  }

  /// Hours on the day of [date].
  DayHours hoursOn(DateTime date) => weeklyHours[date.weekday - 1];

  /// Fee for a road distance of [km], rounded up to whole km.
  /// Null if the branch does not deliver that far.
  double? deliveryFee(double km) {
    if (km > maxDeliveryKm) return null;
    return baseDeliveryFee + km.ceil() * feePerKm;
  }

  /// Copy that is temporarily closed or open again.
  Branch withTemporarilyClosed({required bool closed}) =>
      copyWith(isTemporarilyClosed: closed);
}
