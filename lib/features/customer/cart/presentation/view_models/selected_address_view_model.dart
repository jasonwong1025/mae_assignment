import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';

/// The delivery address the customer picked for this order, or null if they
/// have not chosen one yet. The cart sets it; checkout reads it.
///
/// Not autoDispose: it must survive moving between the Home and Cart tabs,
/// like the cart itself.
final NotifierProvider<SelectedAddressViewModel, CustomerAddress?>
selectedAddressProvider =
    NotifierProvider<SelectedAddressViewModel, CustomerAddress?>(
      SelectedAddressViewModel.new,
    );

class SelectedAddressViewModel extends Notifier<CustomerAddress?> {
  @override
  CustomerAddress? build() => null;

  /// Picks [address] for this order. No-op if it is already selected.
  void select(CustomerAddress address) {
    if (state?.id == address.id) return;
    state = address;
  }

  void clear() => state = null;
}

/// The address to show in the cart: the one the customer picked, or their
/// default saved address if they have not picked one yet. Null when they
/// have no saved addresses.
final FutureProvider<CustomerAddress?> effectiveDeliveryAddressProvider =
    FutureProvider<CustomerAddress?>((ref) async {
      final picked = ref.watch(selectedAddressProvider);
      if (picked != null) return picked;
      final saved = await ref.watch(savedAddressesProvider.future);
      if (saved.isEmpty) return null;
      return saved.firstWhere(
        (address) => address.isDefault,
        orElse: () => saved.first,
      );
    });

/// A delivery fee quote for the chosen branch and address: the straight-line
/// distance and the branch's fee for it, or an out-of-range flag. The real
/// app would use road distance; straight-line is a reasonable stand-in and
/// keeps the fee deterministic for this slice.
class DeliveryQuote {
  const DeliveryQuote({
    required this.distanceKm,
    required this.fee,
    required this.inRange,
  });

  /// Distance from the branch to the address, in kilometres.
  final double distanceKm;

  /// Delivery fee in ringgit. Zero when out of range (then [inRange] is
  /// false and checkout is blocked).
  final double fee;

  /// False when the address is beyond the branch's delivery radius.
  final bool inRange;
}

/// Works out the delivery fee for the selected branch and address. Null
/// while either is still loading or no address is chosen.
final FutureProvider<DeliveryQuote?> deliveryQuoteProvider =
    FutureProvider<DeliveryQuote?>((ref) async {
      final address = await ref.watch(effectiveDeliveryAddressProvider.future);
      if (address == null) return null;
      final branch = await ref.watch(selectedBranchProvider.future);
      return quoteFor(branch: branch, destination: address.location);
    });

/// Pure helper (easy to unit-test): the quote for a destination from a
/// branch, using straight-line distance.
DeliveryQuote quoteFor({required Branch branch, required LatLng destination}) {
  final metres = const Distance().as(
    LengthUnit.Meter,
    branch.location,
    destination,
  );
  final km = metres / 1000;
  final fee = branch.deliveryFee(km);
  return DeliveryQuote(distanceKm: km, fee: fee ?? 0, inRange: fee != null);
}
