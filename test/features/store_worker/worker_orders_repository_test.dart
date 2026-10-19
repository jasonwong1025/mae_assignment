import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';

import '../../helpers/worker_profiles.dart';
import '../../helpers/worker_test_store.dart';

WorkerProfile _worker(String name) {
  return testWorkers.firstWhere((worker) => worker.name == name);
}

final WorkerProfile _daniel = _worker('Daniel Lee');
final WorkerProfile _hakim = _worker('Hakim Roslan');
final WorkerProfile _amir = _worker('Amir Hamzah');
final WorkerProfile _nadia = _worker('Nadia Yusof');
final WorkerProfile _hafiz = _worker('Hafiz Zainal');
final WorkerProfile _weiJie = _worker('Tan Wei Jie');

/// A non-empty proof-of-delivery photo (content is not inspected).
final Uint8List _proofPhoto = Uint8List.fromList([1, 2, 3]);

/// A repository with a fixed clock and no delay.
Future<WorkerOrdersRepository> _repository({
  Duration delay = Duration.zero,
}) async {
  final store = await WorkerTestStore.create(
    clock: () => DateTime(2026, 10, 15, 12),
    delay: delay,
  );
  return store.repository;
}

List<String> _ids(List<Order> orders) {
  return orders.map((order) => order.id).toList();
}

/// Lets queued stream events reach their listeners.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

/// Collects every list [stream] sends, as order ids.
Future<List<List<String>>> _record(Stream<List<Order>> stream) async {
  final values = <List<String>>[];
  final subscription = stream.listen((orders) => values.add(_ids(orders)));
  addTearDown(subscription.cancel);
  await _settle();
  return values;
}

Matcher _throwsMessage(String message) {
  return throwsA(
    isA<WorkerOrderException>().having((e) => e.message, 'message', message),
  );
}

Matcher get _throwsWorkerOrderException {
  return throwsA(isA<WorkerOrderException>());
}

void main() {
  group('lists', () {
    test('each list starts with the current orders in scope', () async {
      final repository = await _repository();

      expect(await repository.watchMyPackingTasks(_daniel).first.then(_ids), [
        'ord-2301',
        'ord-2303',
        'ord-2302',
      ]);
      expect(await repository.watchMyPackingTasks(_hakim).first.then(_ids), [
        'ord-2304',
      ]);
      expect(await repository.watchMyPackingTasks(_hafiz).first.then(_ids), [
        'ord-1182',
        'ord-1181',
      ]);
      expect(await repository.watchReadyForPickup(_daniel).first.then(_ids), [
        'ord-2305',
        'ord-2306',
      ]);
      expect(await repository.watchReadyForPickup(_hafiz).first.then(_ids), [
        'ord-1183',
      ]);
      expect(await repository.watchMyDeliveries(_amir).first.then(_ids), [
        'ord-2309', // out for delivery
        'ord-2308', // ready
        'ord-1184', // ready (Bukit Jalil, cross-branch)
        'ord-2303', // being packed
        'ord-2275', // completed (history)
        'ord-2281',
        'ord-2310',
      ]);
      expect(await repository.watchMyDeliveries(_weiJie).first.then(_ids), [
        'ord-1185', // out for delivery
        'ord-2301', // pending
        'ord-1181', // pending
        'ord-1170', // completed (history)
      ]);
    });

    test("roles get nothing from the other role's lists", () async {
      final repository = await _repository();

      expect(await repository.watchMyPackingTasks(_amir).first, isEmpty);
      expect(await repository.watchReadyForPickup(_amir).first, isEmpty);
      expect(await repository.watchMyDeliveries(_daniel).first, isEmpty);
    });

    test('an inactive worker gets empty lists', () async {
      final repository = await _repository();

      expect(await repository.watchMyPackingTasks(_nadia).first, isEmpty);
      expect(await repository.watchReadyForPickup(_nadia).first, isEmpty);
    });

    test("watchOrder hides orders outside the worker's scope", () async {
      final repository = await _repository();

      expect(await repository.watchOrder(_daniel, 'ord-2302').first, isNotNull);
      expect(await repository.watchOrder(_hakim, 'ord-2302').first, isNull);
      expect(await repository.watchOrder(_hafiz, 'ord-2302').first, isNull);
      expect(await repository.watchOrder(_daniel, 'missing').first, isNull);

      // Drivers can open their delivery while it is still being packed.
      expect(await repository.watchOrder(_amir, 'ord-2303').first, isNotNull);
    });
  });

  group('packing', () {
    test('pending -> packing -> ready by the assigned packer', () async {
      final repository = await _repository();

      await repository.startPacking(_daniel, 'ord-2301');
      for (final line in ['L1', 'L2', 'L3']) {
        await repository.setItemPacked(_daniel, 'ord-2301', line, packed: true);
      }
      await repository.markReady(_daniel, 'ord-2301');

      // ord-2301 is a delivery for Wei Jie, who can view it in any status.
      final order = await repository.watchOrder(_weiJie, 'ord-2301').first;
      expect(order!.status, OrderStatus.ready);
      expect(order.readyBy, _daniel.id);
      expect(order.readyAt, DateTime(2026, 10, 15, 12));
      expect(order.packingStartedAt, isNotNull);

      final tasks = await repository.watchMyPackingTasks(_daniel).first;
      expect(_ids(tasks), isNot(contains('ord-2301')));
    });

    test('ticking and unticking change the progress', () async {
      final repository = await _repository();

      await repository.setItemPacked(_daniel, 'ord-2302', 'L3', packed: true);
      var order = await repository.watchOrder(_daniel, 'ord-2302').first;
      expect(order!.packedLineCount, 3);

      await repository.setItemPacked(_daniel, 'ord-2302', 'L1', packed: false);
      order = await repository.watchOrder(_daniel, 'ord-2302').first;
      expect(order!.packedLineIds, {'L2', 'L3'});
    });

    test('ready is refused until every line is packed', () async {
      final repository = await _repository();

      expect(
        repository.markReady(_daniel, 'ord-2302'),
        _throwsMessage('3 items still need to be packed.'),
      );
      final order = await repository.watchOrder(_daniel, 'ord-2302').first;
      expect(order!.status, OrderStatus.packing);
    });

    test('invalid packing actions are refused and change nothing', () async {
      final repository = await _repository();

      expect(
        repository.setItemPacked(_daniel, 'ord-2301', 'L1', packed: true),
        _throwsMessage('Start packing before ticking items.'),
      );
      expect(
        repository.setItemPacked(_hakim, 'ord-2302', 'L3', packed: true),
        _throwsWorkerOrderException,
      );
      expect(
        repository.startPacking(_amir, 'ord-2301'),
        _throwsWorkerOrderException,
      );
      expect(
        repository.startPacking(_daniel, 'ord-2311'),
        _throwsMessage('This order was cancelled.'),
      );

      final order = await repository.watchOrder(_daniel, 'ord-2302').first;
      expect(order!.packedLineIds, {'L1', 'L2'});
    });

    test('an unknown order is reported clearly', () async {
      final repository = await _repository();

      expect(
        repository.startPacking(_daniel, 'missing'),
        _throwsMessage('This order no longer exists.'),
      );
    });
  });

  group('pickup', () {
    test('a packer hands over an order packed by someone else', () async {
      final repository = await _repository();
      final hakimQueue = await _record(repository.watchReadyForPickup(_hakim));

      await repository.completePickup(
        _daniel,
        'ord-2306',
        method: VerificationMethod.manual,
      );
      await _settle();

      expect(hakimQueue, [
        ['ord-2305', 'ord-2306'],
        ['ord-2305'],
      ]);

      final order = await repository.watchOrder(_daniel, 'ord-2306').first;
      expect(order!.status, OrderStatus.completed);
      expect(order.pickupCompletedBy, _daniel.id);
      expect(order.pickupCompletedByName, 'Daniel Lee');
      expect(order.pickupVerification, VerificationMethod.manual);
      expect(order.completedAt, DateTime(2026, 10, 15, 12));

      // Hakim packed it, so he can still open it (read-only) and sees it is
      // done. Another branch never can.
      final asPacker = await repository.watchOrder(_hakim, 'ord-2306').first;
      expect(asPacker!.status, OrderStatus.completed);
      expect(await repository.watchOrder(_hafiz, 'ord-2306').first, isNull);
    });

    test('a second handover fails with who did it', () async {
      final repository = await _repository();

      await repository.completePickup(
        _daniel,
        'ord-2306',
        method: VerificationMethod.qr,
      );

      expect(
        repository.completePickup(
          _hakim,
          'ord-2306',
          method: VerificationMethod.manual,
        ),
        _throwsMessage(
          'This order has already been handed over by Daniel Lee.',
        ),
      );
    });

    test(
      'two packers finishing one after the other: only the first wins',
      () async {
        // Firestore transactions retry when two workers touch the same order
        // at once, so the second one sees the finished order and is refused.
        // The in-memory test database runs them one at a time.
        final repository = await _repository();

        await repository.completePickup(
          _daniel,
          'ord-2305',
          method: VerificationMethod.manual,
        );

        await expectLater(
          repository.completePickup(
            _hakim,
            'ord-2305',
            method: VerificationMethod.manual,
          ),
          _throwsWorkerOrderException,
        );
      },
    );

    test('other branches, drivers and delivery orders are refused', () async {
      final repository = await _repository();
      const manual = VerificationMethod.manual;

      expect(
        repository.completePickup(_hafiz, 'ord-2306', method: manual),
        _throwsMessage('This order belongs to another branch.'),
      );
      expect(
        repository.completePickup(_amir, 'ord-2306', method: manual),
        _throwsWorkerOrderException,
      );
      expect(
        repository.completePickup(_daniel, 'ord-2308', method: manual),
        _throwsWorkerOrderException,
      );
      expect(
        repository.completePickup(_daniel, 'ord-2304', method: manual),
        _throwsMessage('This order is not ready for pickup yet.'),
      );
    });
  });

  group('delivery', () {
    test('ready -> verify -> out for delivery -> completed', () async {
      final repository = await _repository();
      final deliveries = await _record(repository.watchMyDeliveries(_amir));

      // Manual verification matches the bag's collection code, read from the
      // order itself rather than hard-coded.
      final toVerify = await repository.watchOrder(_amir, 'ord-2308').first;
      await repository.verifyCollection(
        _amir,
        'ord-2308',
        method: VerificationMethod.manual,
        code: toVerify!.collectionCode,
      );
      await repository.startDelivery(_amir, 'ord-2308');
      await repository.completeDelivery(_amir, 'ord-2308', photo: _proofPhoto);
      await _settle();

      final order = await repository.watchOrder(_amir, 'ord-2308').first;
      expect(order!.status, OrderStatus.completed);
      expect(order.collectionVerifiedBy, _amir.id);
      expect(order.collectionVerification, VerificationMethod.manual);
      expect(order.outForDeliveryAt, isNotNull);
      expect(order.deliveredBy, _amir.id);
      expect(order.deliveredByName, 'Amir Hamzah');

      // After completing, 2308 moves to the end of the completed group.
      expect(deliveries.last, [
        'ord-2309', // out for delivery
        'ord-1184', // ready
        'ord-2303', // being packed
        'ord-2275', // completed (history)
        'ord-2281',
        'ord-2310',
        'ord-2308', // just completed
      ]);
    });

    test('start is refused before verification', () async {
      final repository = await _repository();

      expect(
        repository.startDelivery(_amir, 'ord-2308'),
        _throwsMessage('Verify the order before starting the delivery.'),
      );
    });

    test('a wrong code does not verify the order', () async {
      final repository = await _repository();

      expect(
        repository.verifyCollection(
          _amir,
          'ord-2308',
          method: VerificationMethod.manual,
          code: '2309',
        ),
        _throwsWorkerOrderException,
      );
      final order = await repository.watchOrder(_amir, 'ord-2308').first;
      expect(order!.collectionVerifiedBy, isNull);
    });

    test('nothing can happen before the order is ready', () async {
      final repository = await _repository();

      expect(
        repository.verifyCollection(
          _amir,
          'ord-2303',
          method: VerificationMethod.manual,
          code: '2303',
        ),
        _throwsMessage('This order is still being packed.'),
      );
      expect(
        repository.startDelivery(_amir, 'ord-2303'),
        _throwsMessage('This order is still being packed.'),
      );
    });

    test('a second completion fails', () async {
      final repository = await _repository();

      await repository.completeDelivery(_amir, 'ord-2309', photo: _proofPhoto);

      expect(
        repository.completeDelivery(_amir, 'ord-2309', photo: _proofPhoto),
        _throwsMessage('This delivery is already completed.'),
      );
    });

    test('other drivers and packers cannot touch the delivery', () async {
      final repository = await _repository();

      expect(
        repository.completeDelivery(_weiJie, 'ord-2309', photo: _proofPhoto),
        _throwsWorkerOrderException,
      );
      expect(
        repository.completeDelivery(_daniel, 'ord-2309', photo: _proofPhoto),
        _throwsWorkerOrderException,
      );
      expect(
        repository.completeDelivery(_amir, 'ord-2305', photo: _proofPhoto),
        _throwsWorkerOrderException,
      );
    });
  });

  group('shared state', () {
    test(
      'open lists update and late listeners start from the latest',
      () async {
        final repository = await _repository();
        final danielTasks = await _record(
          repository.watchMyPackingTasks(_daniel),
        );

        await repository.startPacking(_daniel, 'ord-2301');
        await _settle();

        // Same order of ids (sorted by due time), but the list is resent
        // because 2301 itself changed.
        expect(danielTasks, [
          ['ord-2301', 'ord-2303', 'ord-2302'],
          ['ord-2301', 'ord-2303', 'ord-2302'],
        ]);

        // A screen that opens now still sees 2301 as being packed. ord-2301
        // is Wei Jie's delivery, so read it as him.
        final order = await repository.watchOrder(_weiJie, 'ord-2301').first;
        expect(order!.status, OrderStatus.packing);
      },
    );

    test('a list does not resend when an unrelated order changes', () async {
      final repository = await _repository();
      final hafizTasks = await _record(repository.watchMyPackingTasks(_hafiz));

      await repository.startPacking(_daniel, 'ord-2301');
      await _settle();

      expect(hafizTasks, hasLength(1));
    });

    test('switching workers keeps the orders and changes the scope', () async {
      final repository = await _repository();
      final container = ProviderContainer(
        overrides: [
          workerOrdersRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final session = container.read(workerSessionProvider.notifier);

      // Daniel packs the last line of 2303.
      // The two session.select calls are separate steps of the scenario,
      // not a cascade.
      // ignore: cascade_invocations
      session.open(_daniel);
      await repository.setItemPacked(
        container.read(workerSessionProvider)!,
        'ord-2303',
        'L4',
        packed: true,
      );

      // Switch to Amir: same store, his scope.
      session.open(_amir);
      final amir = container.read(workerSessionProvider)!;
      expect(container.read(workerOrdersRepositoryProvider), same(repository));

      final order = await repository.watchOrder(amir, 'ord-2303').first;
      expect(order!.isFullyPacked, isTrue);
      expect(await repository.watchMyPackingTasks(amir).first, isEmpty);
      // Amir's deliveries now include his Bukit Jalil order and completed
      // history: 7 in total.
      expect(await repository.watchMyDeliveries(amir).first, hasLength(7));

      // Back to Daniel: his change is still there.
      session.open(_daniel);
      final again = await repository
          .watchOrder(container.read(workerSessionProvider)!, 'ord-2303')
          .first;
      expect(again!.packedLineIds, {'L1', 'L2', 'L3', 'L4'});
    });

    test('cancelling a subscription stops its updates', () async {
      final repository = await _repository();
      final values = <List<Order>>[];
      final subscription = repository
          .watchReadyForPickup(_daniel)
          .listen(values.add);
      await _settle();
      await subscription.cancel();

      await repository.completePickup(
        _daniel,
        'ord-2305',
        method: VerificationMethod.manual,
      );
      await _settle();

      expect(values, hasLength(1));
    });
  });
}
