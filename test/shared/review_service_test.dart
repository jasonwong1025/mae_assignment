import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/services/review_service.dart';

const _review = OrderReview(
  id: 'o1',
  orderNumber: 2301,
  branchId: 'ss15',
  customerId: 'u1',
  customerName: 'Aisha',
  shoppingScore: 5,
  productScore: 4,
  deliveryScore: 3,
  comment: 'Fast and fresh',
);

void main() {
  late FakeFirebaseFirestore firestore;
  late ReviewService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = ReviewService(firestore);
  });

  test('createReview saves under the order id with the server time', () async {
    await service.createReview(_review);

    final doc = await firestore
        .collection(FirestoreCollections.reviews)
        .doc('o1')
        .get();
    final data = doc.data()!;
    expect(data[ReviewFields.shoppingScore], 5);
    expect(data[ReviewFields.comment], 'Fast and fresh');
    expect(data[ReviewFields.createdAt], isA<Timestamp>());
    expect(data.containsKey('id'), isFalse);
  });

  test('watchReview emits null until the order is rated', () async {
    final events = <OrderReview?>[];
    final subscription = service.watchReview('o1').listen(events.add);
    await Future<void>.delayed(Duration.zero);

    await service.createReview(_review);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(events.first, isNull);
    expect(events.last?.id, 'o1');
    expect(events.last?.deliveryScore, 3);
  });
}
