import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreRefs refs;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    refs = FirestoreRefs(firestore);
  });

  test('FirestoreRefs builds the documented paths', () {
    expect(refs.user('u1').path, 'users/u1');
    expect(refs.address('u1', 'a1').path, 'users/u1/addresses/a1');
    expect(refs.cart('u1').path, 'users/u1/cart/current');
    expect(refs.product('p1').path, 'products/p1');
    expect(refs.inventory('ss15').path, 'branches/ss15/inventory');
    expect(refs.order('o1').path, 'orders/o1');
    expect(refs.counter('orders').path, 'counters/orders');
  });

  test('toModel adds the document id when reading', () async {
    await refs.address('u1', 'a1').set({
      'label': 'Home',
      'line': '1 Jalan',
      'location': const GeoPoint(3, 101),
    });

    final snapshot = await refs.address('u1', 'a1').get();
    final address = snapshot.toModel(
      fromFirestore: CustomerAddress.fromFirestore,
    );

    expect(address?.id, 'a1');
    expect(address?.location, const LatLng(3, 101));
  });

  test('toModels skips malformed documents instead of failing', () async {
    await refs.address('u1', 'good').set({
      'label': 'Home',
      'line': '1 Jalan',
      'location': const GeoPoint(3, 101),
    });
    await refs.address('u1', 'bad').set({'label': 'No location'});

    final snapshot = await refs.addresses('u1').get();

    expect(
      snapshot
          .toModels(fromFirestore: CustomerAddress.fromFirestore)
          .map((a) => a.id),
      ['good'],
    );
  });

  test('toModel is null for a missing or malformed document', () async {
    await refs.address('u1', 'bad').set({'label': 'No location'});

    final missing = await refs.address('u1', 'missing').get();
    final bad = await refs.address('u1', 'bad').get();

    expect(
      missing.toModel(fromFirestore: CustomerAddress.fromFirestore),
      isNull,
    );
    expect(bad.toModel(fromFirestore: CustomerAddress.fromFirestore), isNull);
  });
}
