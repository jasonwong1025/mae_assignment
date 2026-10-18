import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

/// The store the customer picked by hand, or null to let the app choose
/// (see [selectedBranchProvider]).
///
/// Not autoDispose: the choice is session-wide state, like the cart. It is
/// cleared when the account changes (see `cartSyncProvider`).
final NotifierProvider<BranchChoiceViewModel, String?> branchChoiceProvider =
    NotifierProvider<BranchChoiceViewModel, String?>(BranchChoiceViewModel.new);

class BranchChoiceViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  // A named action reads better at call sites than a setter on a Notifier.
  // ignore: use_setters_to_change_properties
  void choose(String branchId) => state = branchId;

  /// Goes back to the automatic choice.
  void clear() => state = null;
}

/// Every branch, for the store picker. autoDispose, so it is read again each
/// time the picker opens.
final FutureProvider<List<Branch>> customerBranchesProvider =
    FutureProvider.autoDispose<List<Branch>>((ref) {
      return ref.watch(branchRepositoryProvider).getBranches();
    });

/// The branch the customer is shopping from.
///
/// 1. The store they picked by hand, if there is one.
/// 2. Otherwise the nearest open store to their default saved address that
///    has products to sell, or the oldest such store when they have no
///    address. A store with an empty shelf (for example one just created by
///    HQ, before stock is added) is skipped, so one empty branch never
///    empties the whole app.
/// 3. If no store has products, the first candidate, so Home can say so.
///
/// The automatic choice is made when this first loads and is not redone when
/// the customer picks another delivery address: switching store changes
/// prices and stock, so it should not happen behind their back.
///
/// Not autoDispose: the chosen branch is session-wide state, like the cart,
/// so it must survive moving between the Home, Cart and Orders tabs.
/// Checkout reads it from the Cart tab, where the catalogue (which also
/// watches it) is no longer mounted; if this disposed, checkout would see
/// no branch and fail with "No store selected".
///
/// A failure to reach Firestore (no connection, timeout) surfaces as a
/// retryable [BranchException] rather than a raw error, so the Home screen
/// shows "Try again" instead of a message only a developer understands.
final selectedBranchProvider = FutureProvider<Branch>(retry: (_, _) => null, (
  ref,
) async {
  final chosenId = ref.watch(branchChoiceProvider);

  final List<Branch> branches;
  try {
    branches = await ref.watch(branchRepositoryProvider).getBranches();
  } on BranchException {
    rethrow;
  } on Object {
    throw const BranchException(
      'Could not reach the store. Please check your connection and try '
      'again.',
    );
  }

  if (branches.isEmpty) {
    throw const BranchException('No stores are available right now.');
  }

  if (chosenId != null) {
    for (final branch in branches) {
      if (branch.id == chosenId) return branch;
    }
    // The chosen store no longer exists: fall through to automatic.
  }

  final open = [
    for (final branch in branches)
      if (!branch.isTemporarilyClosed) branch,
  ];
  final candidates = open.isEmpty ? branches : open;
  final ordered = await _nearestFirst(ref, candidates);

  for (final branch in ordered) {
    if (await _hasProducts(ref, branch)) return branch;
  }
  return ordered.first;
});

/// [branches] sorted by distance from the customer's default saved address,
/// or unchanged (oldest first) when they have none or it cannot be read.
Future<List<Branch>> _nearestFirst(Ref ref, List<Branch> branches) async {
  final CustomerAddress? address;
  try {
    // The repository directly, not savedAddressesProvider: a provider that
    // fails is retried with a delay, which would hold up choosing a store.
    final saved = await ref
        .read(addressRepositoryProvider)
        .getAddresses()
        .timeout(const Duration(seconds: 5));
    address = saved.isEmpty
        ? null
        : saved.firstWhere((a) => a.isDefault, orElse: () => saved.first);
  } on Object {
    return branches;
  }
  if (address == null) return branches;
  return sortByDistance(branches, address.location);
}

/// Whether [branch] has anything to sell. A failed check counts as yes, so
/// a flaky connection never blocks shopping; the catalogue then shows its
/// own error.
Future<bool> _hasProducts(Ref ref, Branch branch) async {
  try {
    return await ref.read(catalogueRepositoryProvider).hasProducts(branch.id);
  } on Object catch (error) {
    debugPrint('Could not check ${branch.name} for products: $error');
    return true;
  }
}

/// Straight-line distance between two points, in metres.
double distanceBetween(LatLng a, LatLng b) {
  return const Distance().as(LengthUnit.Meter, a, b);
}

/// [branches] ordered from nearest to furthest from [point]. Ties keep their
/// original (oldest first) order.
List<Branch> sortByDistance(List<Branch> branches, LatLng point) {
  return [...branches]..sort(
    (a, b) => distanceBetween(
      a.location,
      point,
    ).compareTo(distanceBetween(b.location, point)),
  );
}
