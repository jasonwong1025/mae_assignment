import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';
import 'package:mae_assignment/features/customer/cart/data/services/cart_service.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_sync.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/shared/services/address_service.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_address_service.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

/// In-memory carts keyed by uid, with a log of writes.
class _FakeCartService extends Fake implements CartService {
  final Map<String, StoredCart> carts = {};
  final List<String> log = [];
  bool failLoads = false;

  /// When set, getCart waits for it, to model a slow connection.
  Completer<void>? loadGate;

  @override
  Future<StoredCart?> getCart(String uid) async {
    if (failLoads) throw Exception('offline');
    await loadGate?.future;
    return carts[uid];
  }

  @override
  Future<void> saveCart(String uid, StoredCart cart) async {
    log.add('save $uid');
    carts[uid] = cart;
  }

  @override
  Future<void> deleteCart(String uid) async {
    log.add('delete $uid');
    carts.remove(uid);
  }
}

class _FakeCatalogueRepository implements CatalogueRepository {
  _FakeCatalogueRepository(this.products);

  final List<CatalogueProduct> products;

  @override
  Future<CatalogueData> loadCatalogue(String branchId) async =>
      CatalogueData(categories: const [], products: products);

  @override
  Future<bool> hasProducts(String branchId) async => true;
}

CatalogueProduct _product(String id, {double price = 4, int stock = 20}) {
  return CatalogueProduct(
    id: id,
    name: 'Product $id',
    brand: 'BrandCo',
    categoryId: 'produce',
    packSize: '1kg',
    price: price,
    stock: stock,
  );
}

void main() {
  late _FakeCartService service;
  late StreamController<String?> auth;
  late ProviderContainer container;

  ProviderContainer makeContainer(List<CatalogueProduct> catalogue) {
    final fakeAuth = FakeAuthRepository()..uidStream = auth.stream;
    return ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(fakeAuth),
        cartServiceProvider.overrideWithValue(service),
        catalogueRepositoryProvider.overrideWithValue(
          _FakeCatalogueRepository(catalogue),
        ),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        addressServiceProvider.overrideWithValue(FakeAddressService()),
      ],
    )..listen(cartSyncProvider, (_, _) {}); // Mounted, as the app root does.
  }

  Future<void> settle() => pumpEventQueue();

  Cart cart() => container.read(cartViewModelProvider);
  CartViewModel notifier() => container.read(cartViewModelProvider.notifier);

  setUp(() {
    service = _FakeCartService();
    auth = StreamController<String?>.broadcast();
    container = makeContainer([_product('p1'), _product('p2', stock: 3)]);
  });
  tearDown(() async {
    container.dispose();
    await auth.close();
  });

  Future<void> signIn(String uid) async {
    auth.add(uid);
    await settle();
    await settle();
    await settle();
  }

  test('restores the saved cart after sign-in', () async {
    service.carts['u1'] = const StoredCart(
      lines: [
        StoredCartLine(productId: 'p1', quantity: 2),
        StoredCartLine(productId: 'p2', quantity: 9),
        StoredCartLine(productId: 'gone', quantity: 1),
      ],
      fulfilment: FulfilmentMethod.pickup,
      promoCode: Cart.promoFresh5,
    );

    await signIn('u1');

    expect(cart().quantityOf('p1'), 2);
    // Capped at the stock; the product that is no longer sold is dropped.
    expect(cart().quantityOf('p2'), 3);
    expect(cart().lines, hasLength(2));
    expect(cart().fulfilment, FulfilmentMethod.pickup);
    expect(cart().promoCode, Cart.promoFresh5);
  });

  test('saves every change after the first load', () async {
    await signIn('u1');
    notifier().add(_product('p1'));
    await settle();

    expect(service.carts['u1']?.lines, [
      const StoredCartLine(productId: 'p1', quantity: 1),
    ]);

    notifier().clear();
    await settle();
    expect(service.carts.containsKey('u1'), isFalse);
  });

  test('items added while loading are kept and merged', () async {
    service
      ..loadGate = Completer<void>()
      ..carts['u1'] = const StoredCart(
        lines: [StoredCartLine(productId: 'p2', quantity: 1)],
      );

    auth.add('u1');
    await settle();
    notifier().add(_product('p1'));
    await settle();
    // Nothing is saved while the saved cart is still unread.
    expect(service.log, isEmpty);

    service.loadGate!.complete();
    await settle();
    await settle();
    await settle();

    expect(cart().quantityOf('p1'), 1);
    expect(cart().quantityOf('p2'), 1);
    expect(service.carts['u1']?.lines, hasLength(2));
  });

  test('a failed load never overwrites the saved cart', () async {
    service
      ..failLoads = true
      ..carts['u1'] = const StoredCart(
        lines: [StoredCartLine(productId: 'p1', quantity: 5)],
      );

    await signIn('u1');
    notifier().add(_product('p2'));
    await settle();

    expect(service.log, isEmpty);
    expect(service.carts['u1']?.lines.single.quantity, 5);

    // Once the connection is back, the next change loads then saves.
    service.failLoads = false;
    notifier().add(_product('p2'));
    await settle();
    await settle();
    await settle();

    expect(service.carts['u1']?.lines, hasLength(2));
  });

  test('signing out clears the cart without touching the saved one', () async {
    await signIn('u1');
    notifier().add(_product('p1'));
    await settle();

    auth.add(null);
    await settle();

    expect(cart().isEmpty, isTrue);
    expect(service.carts['u1']?.lines, hasLength(1));
  });

  test('another account never sees the previous cart', () async {
    await signIn('u1');
    notifier().add(_product('p1'));
    await settle();

    await signIn('u2');

    expect(cart().isEmpty, isTrue);
    expect(service.carts['u1']?.lines, hasLength(1));
    expect(service.carts.containsKey('u2'), isFalse);
  });

  test('a signed-out cart is not saved', () async {
    notifier().add(_product('p1'));
    await settle();

    expect(service.log, isEmpty);
  });
}
