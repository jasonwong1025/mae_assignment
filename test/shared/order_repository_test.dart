import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';
import 'package:mae_assignment/shared/services/order_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrderService extends Mock implements OrderService {}

CatalogueProduct _product(String id, String name, double price) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: 'BrandCo',
    categoryId: 'produce',
    packSize: '1kg',
    price: price,
    stock: 50,
    imageUrls: ['https://img/$id.png'],
  );
}

class _FakeOrder extends Fake implements Order {}

const _customer = AppUser(
  uid: 'u1',
  name: 'Aisha',
  email: 'aisha@example.com',
  phone: '0123456789',
  role: UserRole.customer,
);

const _branch = Branch(
  id: 'ss15',
  name: 'SS15 Subang',
  address: '1 Jalan SS15',
  phone: '0377778888',
  location: LatLng(3, 101),
  weeklyHours: [],
  maxDeliveryKm: 10,
  baseDeliveryFee: 3,
  feePerKm: 1,
);

const _address = CustomerAddress(
  id: 'a1',
  label: 'Home',
  line: '12 Jalan Besar',
  location: LatLng(3.001, 101.001),
);

Cart _cart({
  FulfilmentMethod fulfilment = FulfilmentMethod.delivery,
  String? promo,
}) {
  return Cart(
    lines: [
      CartLine(product: _product('p1', 'Fresh milk', 8.9), quantity: 2),
      CartLine(product: _product('p2', 'Roma tomato', 6.8), quantity: 1),
    ],
    fulfilment: fulfilment,
    promoCode: promo,
  );
}

void main() {
  late _MockOrderService service;
  late OrderRepository repository;

  setUpAll(() {
    registerFallbackValue(_FakeOrder());
  });

  setUp(() {
    service = _MockOrderService();
    repository = OrderRepository(service);
  });

  void stubCreate({int highest = 0, String newId = 'o1'}) {
    when(service.highestOrderNumber).thenAnswer((_) async => highest);
    when(() => service.createOrder(any())).thenAnswer((_) async => newId);
  }

  test(
    'turns the cart into an order with the next number and new id',
    () async {
      stubCreate(highest: 2300, newId: 'o-new');

      final order = await repository.placeOrder(
        cart: _cart(),
        customer: _customer,
        branch: _branch,
        address: _address,
        deliveryFee: 3,
      );

      expect(order.id, 'o-new');
      expect(order.number, 2301);
      expect(order.customerId, 'u1');
      expect(order.branchId, 'ss15');
      expect(order.status, OrderStatus.pending);
      expect(order.items, hasLength(2));
      expect(order.itemCount, 3);
      expect(order.address, '12 Jalan Besar');
      expect(order.addressLocation, const LatLng(3.001, 101.001));
    },
  );

  test('captures line prices and the quoted delivery fee', () async {
    stubCreate();

    final order = await repository.placeOrder(
      cart: _cart(),
      customer: _customer,
      branch: _branch,
      address: _address,
      deliveryFee: 4.5,
    );

    // Subtotal 8.9*2 + 6.8 = 24.6, + 4.5 quoted delivery.
    expect(order.subtotal, closeTo(24.6, 0.001));
    expect(order.deliveryFee, 4.5);
    expect(order.total, closeTo(29.1, 0.001));
    final milk = order.items.firstWhere((i) => i.productId == 'p1');
    expect(milk.unitPrice, 8.9);
    expect(milk.quantity, 2);
    expect(milk.imageUrl, 'https://img/p1.png');
  });

  test('pickup orders carry no address and no delivery fee', () async {
    stubCreate();

    final order = await repository.placeOrder(
      cart: _cart(fulfilment: FulfilmentMethod.pickup),
      customer: _customer,
      branch: _branch,
    );

    expect(order.isDelivery, isFalse);
    expect(order.address, isNull);
    expect(order.addressLocation, isNull);
    expect(order.deliveryFee, 0);
  });

  test('rejects an empty cart', () async {
    stubCreate();

    await expectLater(
      repository.placeOrder(
        cart: const Cart(),
        customer: _customer,
        branch: _branch,
        address: _address,
        deliveryFee: 3,
      ),
      throwsA(isA<OrderException>()),
    );
    verifyNever(() => service.createOrder(any()));
  });

  test('requires an address for delivery', () async {
    stubCreate();

    await expectLater(
      repository.placeOrder(
        cart: _cart(),
        customer: _customer,
        branch: _branch,
      ),
      throwsA(
        isA<OrderException>().having(
          (e) => e.message,
          'message',
          contains('address'),
        ),
      ),
    );
    verifyNever(() => service.createOrder(any()));
  });

  test('wraps a Firestore failure in a friendly OrderException', () async {
    when(service.highestOrderNumber).thenThrow(Exception('offline'));

    await expectLater(
      repository.placeOrder(
        cart: _cart(),
        customer: _customer,
        branch: _branch,
        address: _address,
        deliveryFee: 3,
      ),
      throwsA(
        isA<OrderException>().having(
          (e) => e.message,
          'message',
          contains('Could not reach the server'),
        ),
      ),
    );
  });

  test('carries the applied promo code onto the order', () async {
    stubCreate();

    final order = await repository.placeOrder(
      cart: _cart(promo: Cart.promoFresh5),
      customer: _customer,
      branch: _branch,
      address: _address,
      deliveryFee: 3,
    );

    expect(order.promoCode, Cart.promoFresh5);
    expect(order.discount, 5);
  });
}
