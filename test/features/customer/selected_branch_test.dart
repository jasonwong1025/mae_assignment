import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';
import 'package:mae_assignment/shared/services/address_service.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_address_service.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

/// Says which branches have products; everything else is unused here.
class _StockedBranches implements CatalogueRepository {
  _StockedBranches(this.stocked);

  final Set<String> stocked;
  bool failChecks = false;

  @override
  Future<bool> hasProducts(String branchId) async {
    if (failChecks) throw const CatalogueException('offline');
    return stocked.contains(branchId);
  }

  @override
  Future<CatalogueData> loadCatalogue(String branchId) =>
      throw UnimplementedError();
}

// Sample branches: ss15 (oldest), bukit-jalil, puchong.
const _nearPuchong = LatLng(3.0240, 101.6175);
const _nearBukitJalil = LatLng(3.0590, 101.6880);

CustomerAddress _address(LatLng location) => CustomerAddress(
  id: 'a1',
  label: 'Home',
  line: '1 Jalan Test',
  location: location,
  isDefault: true,
);

void main() {
  late FakeBranchService branches;

  ProviderContainer makeContainer({
    required Set<String> stocked,
    List<CustomerAddress> addresses = const [],
    _StockedBranches? catalogue,
  }) {
    final auth = FakeAuthRepository()
      ..signedIn = true
      ..userToSignIn = const AppUser(
        uid: 'u1',
        name: 'Aisha',
        email: 'aisha@example.com',
        phone: '0123456789',
        role: UserRole.customer,
      );
    final container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(auth),
        branchServiceProvider.overrideWithValue(branches),
        addressServiceProvider.overrideWithValue(
          FakeAddressService(addresses: addresses),
        ),
        catalogueRepositoryProvider.overrideWithValue(
          catalogue ?? _StockedBranches(stocked),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => branches = FakeBranchService());

  Future<String> selectedId(ProviderContainer container) async =>
      (await container.read(selectedBranchProvider.future)).id;

  test('with no address, picks the oldest branch that has products', () async {
    final container = makeContainer(stocked: {'ss15', 'bukit-jalil'});

    expect(await selectedId(container), 'ss15');
  });

  test('skips a branch with no products', () async {
    final container = makeContainer(stocked: {'bukit-jalil'});

    expect(await selectedId(container), 'bukit-jalil');
  });

  test('prefers the branch nearest the default address', () async {
    final container = makeContainer(
      stocked: {'ss15', 'bukit-jalil', 'puchong'},
      addresses: [_address(_nearPuchong)],
    );

    expect(await selectedId(container), 'puchong');
  });

  test('the nearest branch is skipped when it has no products', () async {
    final container = makeContainer(
      stocked: {'ss15', 'bukit-jalil'},
      addresses: [_address(_nearPuchong)],
    );

    // Puchong is empty; SS15 is the next nearest to that address (about
    // 6 km, against about 8 km for Bukit Jalil).
    expect(await selectedId(container), 'ss15');
  });

  test('skips temporarily closed branches', () async {
    branches.branches[1] = branches.branches[1].withTemporarilyClosed(
      closed: true,
    );
    final container = makeContainer(
      stocked: {'ss15', 'bukit-jalil', 'puchong'},
      addresses: [_address(_nearBukitJalil)],
    );

    expect(await selectedId(container), isNot('bukit-jalil'));
  });

  test('falls back to the first candidate when nothing has products', () async {
    final container = makeContainer(stocked: {});

    expect(await selectedId(container), 'ss15');
  });

  test('a failed stock check never blocks shopping', () async {
    final container = makeContainer(
      stocked: {},
      catalogue: _StockedBranches({})..failChecks = true,
    );

    expect(await selectedId(container), 'ss15');
  });

  test(
    'a store chosen by hand wins, and clearing returns to automatic',
    () async {
      final container = makeContainer(stocked: {'ss15'});
      expect(await selectedId(container), 'ss15');

      container.read(branchChoiceProvider.notifier).choose('puchong');
      expect(await selectedId(container), 'puchong');

      container.read(branchChoiceProvider.notifier).clear();
      expect(await selectedId(container), 'ss15');
    },
  );

  test('a chosen store that no longer exists is ignored', () async {
    final container = makeContainer(stocked: {'ss15'});
    container.read(branchChoiceProvider.notifier).choose('gone');

    expect(await selectedId(container), 'ss15');
  });

  test('no branches at all is a BranchException', () async {
    branches = FakeBranchService(empty: true);
    final container = makeContainer(stocked: {});

    await expectLater(
      container.read(selectedBranchProvider.future),
      throwsA(isA<BranchException>()),
    );
  });
}
