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
const _savedOrder = Order(
  id: 'o1',
  number: 2301,
  customerId: 'u1',
  customerName: 'Aisha',
  customerPhone: '0123456789',
  branchId: 'ss15',
  branchName: 'SS15 Subang',
  isDelivery: true,
  items: [],
  subtotal: 24.6,
  deliveryFee: 4,
  discount: 5,
  total: 23.6,
  status: OrderStatus.pending,
);

Cart _cart({FulfilmentMethod fulfilment = FulfilmentMethod.delivery}) => Cart(
  lines: [
    const CartLine(
      product: CatalogueProduct(
        id: 'p1',
        name: 'Milk',
        brand: 'Brand',
        categoryId: 'dairy',
        packSize: '1L',
        price: 8.9,
        stock: 50,
      ),
      quantity: 2,
    ),
  ],
  fulfilment: fulfilment,
  promoCode: Cart.promoFresh5,
);

void main() {
  late _MockOrderService service;
  late OrderRepository repository;

  setUp(() {
    service = _MockOrderService();
    repository = OrderRepository(service);
  });

  void stubPlace() {
    when(
      () => service.placeOrder(
        branchId: any(named: 'branchId'),
        lines: any(named: 'lines'),
        fulfilment: any(named: 'fulfilment'),
        addressId: any(named: 'addressId'),
        promoCode: any(named: 'promoCode'),
        customerNote: any(named: 'customerNote'),
      ),
    ).thenAnswer((_) async => _savedOrder);
  }

  test('sends only cart intent and returns the saved server order', () async {
    stubPlace();
    final order = await repository.placeOrder(
      cart: _cart(),
      customer: _customer,
      branch: _branch,
      address: _address,
      deliveryFee: 999,
      customerNote: '  please ring  ',
    );
    expect(order, _savedOrder);
    final captured =
        verify(
              () => service.placeOrder(
                branchId: 'ss15',
                lines: captureAny(named: 'lines'),
                fulfilment: 'delivery',
                addressId: 'a1',
                promoCode: Cart.promoFresh5,
                customerNote: 'please ring',
              ),
            ).captured.single
            as List<Map<String, Object>>;
    expect(captured, [
      {'productId': 'p1', 'quantity': 2},
    ]);
  });

  test('pickup has no delivery address', () async {
    stubPlace();
    await repository.placeOrder(
      cart: _cart(fulfilment: FulfilmentMethod.pickup),
      customer: _customer,
      branch: _branch,
    );
    verify(
      () => service.placeOrder(
        branchId: 'ss15',
        lines: any(named: 'lines'),
        fulfilment: 'pickup',
        promoCode: Cart.promoFresh5,
      ),
    ).called(1);
  });

  test('rejects an empty cart and a delivery without an address', () async {
    await expectLater(
      repository.placeOrder(
        cart: const Cart(),
        customer: _customer,
        branch: _branch,
      ),
      throwsA(isA<OrderException>()),
    );
    await expectLater(
      repository.placeOrder(
        cart: _cart(),
        customer: _customer,
        branch: _branch,
      ),
      throwsA(isA<OrderException>()),
    );
    verifyZeroInteractions(service);
  });

  test('wraps a Function failure in a friendly error', () async {
    when(
      () => service.placeOrder(
        branchId: any(named: 'branchId'),
        lines: any(named: 'lines'),
        fulfilment: any(named: 'fulfilment'),
        addressId: any(named: 'addressId'),
        promoCode: any(named: 'promoCode'),
        customerNote: any(named: 'customerNote'),
      ),
    ).thenThrow(Exception('offline'));
    await expectLater(
      repository.placeOrder(
        cart: _cart(),
        customer: _customer,
        branch: _branch,
        address: _address,
      ),
      throwsA(isA<OrderException>()),
    );
  });

  group('cancelOrder', () {
    test('cancels a pending order', () async {
      when(() => service.cancelOrder('o1')).thenAnswer((_) async => true);
      await repository.cancelOrder('o1');
      verify(() => service.cancelOrder('o1')).called(1);
    });

    test('reports an order that can no longer be cancelled', () async {
      when(() => service.cancelOrder('o1')).thenAnswer((_) async => false);
      await expectLater(
        repository.cancelOrder('o1'),
        throwsA(isA<OrderException>()),
      );
    });
  });
}
