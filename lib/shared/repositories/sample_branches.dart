import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/shared/models/branch.dart';

/// Same hours every day.
List<DayHours> _everyDay(int opensAt, int closesAt) {
  return List.filled(7, DayHours(opensAt: opensAt, closesAt: closesAt));
}

/// The first 3 branches, added once with the "Add sample branches" button.
/// Their ids match the sample orders, stock, sales and reviews.
// TODO(team): delete once those tabs read Firestore too.
List<Branch> sampleBranches() => [
  Branch(
    id: 'ss15',
    name: 'SS15 Subang',
    address: '12, Jalan SS15/4D, 47500 Subang Jaya, Selangor',
    phone: '03-5611 2201',
    location: const LatLng(3.0757, 101.5869),
    weeklyHours: _everyDay(8 * 60, 21 * 60),
    maxDeliveryKm: 8,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
  ),
  Branch(
    id: 'bukit-jalil',
    name: 'Bukit Jalil',
    address: '3, Jalan Jalil Perkasa 1, 57000 Bukit Jalil, Kuala Lumpur',
    phone: '03-8996 4410',
    location: const LatLng(3.0584, 101.6890),
    weeklyHours: [
      ..._everyDay(9 * 60, 22 * 60).take(6),
      const DayHours(opensAt: 10 * 60, closesAt: 20 * 60),
    ],
    maxDeliveryKm: 10,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
  ),
  Branch(
    id: 'puchong',
    name: 'Puchong',
    address: '21, Jalan Puteri 1/2, 47100 Bandar Puteri Puchong, Selangor',
    phone: '03-8061 7720',
    location: const LatLng(3.0235, 101.6170),
    weeklyHours: [..._everyDay(8 * 60, 20 * 60).take(6), DayHours.closed],
    maxDeliveryKm: 6,
    baseDeliveryFee: 4,
    feePerKm: 0.6,
  ),
];
