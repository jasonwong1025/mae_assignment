import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/repositories/review_repository.dart';
import 'package:mae_assignment/shared/services/review_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockReviewService extends Mock implements ReviewService {}

class _FakeReview extends Fake implements OrderReview {}

const _customer = AppUser(
  uid: 'u1',
  name: 'Aisha',
  email: 'a@example.com',
  phone: '012',
  role: UserRole.customer,
);

Order _order({
  OrderStatus status = OrderStatus.completed,
  bool isDelivery = true,
}) {
  return Order(
    id: 'o1',
    number: 2301,
    customerId: 'u1',
    customerName: 'Aisha',
    customerPhone: '012',
    branchId: 'ss15',
    branchName: 'SS15',
    isDelivery: isDelivery,
    items: const [],
    subtotal: 0,
    deliveryFee: 0,
    discount: 0,
    total: 0,
    status: status,
  );
}

void main() {
  late _MockReviewService service;
  late ReviewRepository repository;

  setUpAll(() => registerFallbackValue(_FakeReview()));

  setUp(() {
    service = _MockReviewService();
    repository = ReviewRepository(service);
    when(() => service.createReview(any())).thenAnswer((_) async {});
  });

  Future<void> submit(
    Order order, {
    int shopping = 5,
    int product = 4,
    int? delivery = 3,
    String? comment,
  }) {
    return repository.submit(
      order: order,
      customer: _customer,
      shoppingScore: shopping,
      productScore: product,
      deliveryScore: delivery,
      comment: comment,
    );
  }

  OrderReview saved() {
    return verify(() => service.createReview(captureAny())).captured.single
        as OrderReview;
  }

  test('saves a delivery order review with all three scores', () async {
    await submit(_order(), comment: '  Great  ');

    final review = saved();
    expect(review.id, 'o1');
    expect(review.orderNumber, 2301);
    expect(review.branchId, 'ss15');
    expect(review.customerId, 'u1');
    expect(review.customerName, 'Aisha');
    expect(
      [review.shoppingScore, review.productScore, review.deliveryScore],
      [5, 4, 3],
    );
    expect(review.comment, 'Great');
  });

  test('a pickup review drops any delivery score', () async {
    await submit(_order(isDelivery: false));

    expect(saved().deliveryScore, isNull);
  });

  test('an empty comment is not saved', () async {
    await submit(_order(), comment: '   ');

    expect(saved().comment, isNull);
  });

  test('only a completed order can be rated', () async {
    await expectLater(
      submit(_order(status: OrderStatus.packing)),
      throwsA(isA<ReviewException>()),
    );
    verifyNever(() => service.createReview(any()));
  });

  test('scores outside 1 to 5 are refused', () async {
    await expectLater(
      submit(_order(), shopping: 0),
      throwsA(isA<ReviewException>()),
    );
    await expectLater(
      submit(_order(), delivery: 6),
      throwsA(isA<ReviewException>()),
    );
  });

  test('a delivery order needs a delivery score', () async {
    await expectLater(
      submit(_order(), delivery: null),
      throwsA(isA<ReviewException>()),
    );
  });

  test('a comment over 500 characters is refused', () async {
    await expectLater(
      submit(_order(), comment: 'x' * 501),
      throwsA(isA<ReviewException>()),
    );
  });

  test('a backend failure becomes a friendly error', () async {
    when(() => service.createReview(any())).thenThrow(Exception('denied'));

    await expectLater(
      submit(_order()),
      throwsA(
        isA<ReviewException>().having(
          (e) => e.message,
          'message',
          contains('Could not save your rating'),
        ),
      ),
    );
  });
}
