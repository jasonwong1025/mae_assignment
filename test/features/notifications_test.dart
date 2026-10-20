import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/notifications/data/models/app_notification.dart';
import 'package:mae_assignment/features/notifications/data/repositories/notification_repository.dart';
import 'package:mae_assignment/features/notifications/data/services/inbox_service.dart';
import 'package:mae_assignment/features/notifications/data/services/push_service.dart';
import 'package:mae_assignment/features/notifications/presentation/view_models/push_sync.dart';
import 'package:mae_assignment/features/notifications/presentation/views/notifications_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../helpers/fake_auth_repository.dart';

/// The phone's FCM, driven by hand.
class _FakePush extends PushService {
  _FakePush(super.firestore);

  bool allowed = true;
  String? currentToken = 'token-1';
  bool failing = false;
  final saved = <(String, String)>[];
  int removals = 0;
  final refreshes = StreamController<String>.broadcast();
  final taps = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async {
    if (failing) throw Exception('no play services');
    return allowed;
  }

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Stream<String> openedOrderIds() => taps.stream;

  @override
  Future<void> saveDevice(String uid, String token) async {
    saved.add((uid, token));
  }

  @override
  Future<void> removeThisDevice() async {
    if (failing) throw Exception('offline');
    removals++;
  }
}

void main() {
  late FakeFirebaseFirestore firestore;

  Future<void> addNotification(
    String id, {
    String title = 'Order ready',
    bool read = false,
    String? orderId = 'o1',
    DateTime? at,
  }) {
    return firestore
        .collection('users')
        .doc('u1')
        .collection('notifications')
        .doc(id)
        .set({
          'title': title,
          'body': 'Come and get it',
          'read': read,
          'orderId': ?orderId,
          'createdAt': Timestamp.fromDate(at ?? DateTime(2026, 10, 16, 15)),
        });
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  group('AppNotification', () {
    test('reads an inbox entry', () {
      final notification = AppNotification.fromFirestore('a', {
        'title': 'T',
        'body': 'B',
        'orderId': 'o1',
        'read': true,
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 16)),
      });

      expect(notification.isRead, isTrue);
      expect(notification.orderId, 'o1');
      expect(notification.createdAt, DateTime(2026, 10, 16));
    });

    test('a missing read flag means unread', () {
      final notification = AppNotification.fromFirestore('a', {
        'title': 'T',
        'body': 'B',
      });

      expect(notification.isRead, isFalse);
      expect(notification.orderId, isNull);
    });
  });

  group('InboxService', () {
    test('lists notifications newest first', () async {
      await addNotification('old', title: 'Old', at: DateTime(2026, 10));
      await addNotification('new', title: 'New', at: DateTime(2026, 10, 2));

      final inbox = await InboxService(firestore).watch('u1').first;

      expect(inbox.map((n) => n.title), ['New', 'Old']);
    });

    test('marks notifications read, and only those', () async {
      await addNotification('a');
      await addNotification('b');
      final service = InboxService(firestore);

      await service.markRead('u1', ['a']);

      final inbox = await service.watch('u1').first;
      expect(inbox.singleWhere((n) => n.id == 'a').isRead, isTrue);
      expect(inbox.singleWhere((n) => n.id == 'b').isRead, isFalse);
    });

    test('deletes one notification', () async {
      await addNotification('a');
      await addNotification('b');
      final service = InboxService(firestore);

      await service.delete('u1', 'a');

      expect((await service.watch('u1').first).map((n) => n.id), ['b']);
    });

    test('keeps each user separate', () async {
      await addNotification('a');

      expect(await InboxService(firestore).watch('u2').first, isEmpty);
    });
  });

  group('NotificationRepository push', () {
    late _FakePush push;
    late NotificationRepository repository;

    setUp(() {
      push = _FakePush(firestore);
      repository = NotificationRepository(InboxService(firestore), push);
    });

    test('registers this phone once permission is given', () async {
      expect(await repository.registerDevice('u1'), isTrue);
      expect(push.saved, [('u1', 'token-1')]);
    });

    test('registers nothing when the user says no', () async {
      push.allowed = false;

      expect(await repository.registerDevice('u1'), isFalse);
      expect(push.saved, isEmpty);
    });

    test('registers nothing when the phone has no token', () async {
      push.currentToken = null;

      expect(await repository.registerDevice('u1'), isFalse);
      expect(push.saved, isEmpty);
    });

    test('a failure never escapes, so sign-in is not blocked', () async {
      push.failing = true;

      expect(await repository.registerDevice('u1'), isFalse);
      await repository.unregisterDevice();
    });

    test('unregisters this phone', () async {
      await repository.unregisterDevice();

      expect(push.removals, 1);
    });

    test('saves a replaced token', () async {
      await repository.saveToken('u1', 'token-2');

      expect(push.saved, [('u1', 'token-2')]);
    });
  });

  group('pushSyncProvider', () {
    late _FakePush push;
    late StreamController<String?> auth;
    late ProviderContainer container;

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    setUp(() {
      push = _FakePush(firestore);
      auth = StreamController<String?>();
      final fakeAuth = FakeAuthRepository()
        ..uidStream = auth.stream
        ..userToSignIn = const AppUser(
          uid: 'u1',
          name: 'Aisha',
          email: 'a@example.com',
          phone: '012',
          role: UserRole.customer,
        );
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuth),
          notificationRepositoryProvider.overrideWithValue(
            NotificationRepository(InboxService(firestore), push),
          ),
        ],
      )..listen(pushSyncProvider, (_, _) {});
      addTearDown(container.dispose);
      addTearDown(auth.close);
    });

    test('registers the phone when someone signs in', () async {
      auth.add('u1');
      await settle();

      expect(push.saved, [('u1', 'token-1')]);
    });

    test('registers nothing while signed out', () async {
      auth.add(null);
      await settle();

      expect(push.saved, isEmpty);
    });

    test('registers a replaced token for the signed-in account', () async {
      auth.add('u1');
      await settle();

      push.refreshes.add('token-2');
      await settle();

      expect(push.saved.last, ('u1', 'token-2'));
    });

    test('stops following token changes after sign-out', () async {
      auth.add('u1');
      await settle();
      auth.add(null);
      await settle();

      push.refreshes.add('token-3');
      await settle();

      expect(push.saved.where((s) => s.$2 == 'token-3'), isEmpty);
    });

    test('registers again for the next account on the same phone', () async {
      auth.add('u1');
      await settle();
      auth
        ..add(null)
        ..add('u2');
      await settle();

      expect(push.saved.map((s) => s.$1), ['u1', 'u2']);
    });
  });

  group('NotificationsView', () {
    Future<GoRouter> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final auth = FakeAuthRepository()
        ..signedIn = true
        ..uidStream = Stream.value('u1');
      final router = GoRouter(
        initialLocation: '/inbox',
        routes: [
          GoRoute(
            path: '/inbox',
            builder: (context, state) => const NotificationsView(),
          ),
          GoRoute(
            path: '${AppRoutes.customerOrders}/:id',
            builder: (context, state) =>
                Scaffold(body: Text('ORDER ${state.pathParameters['id']}')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            inboxServiceProvider.overrideWithValue(InboxService(firestore)),
            pushServiceProvider.overrideWithValue(_FakePush(firestore)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('an empty inbox says so', (tester) async {
      await pump(tester);

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.byKey(const Key('mark_all_read')), findsNothing);
    });

    testWidgets('lists notifications, unread first in the eye', (tester) async {
      await addNotification('a', title: 'Order #1001 is ready');
      await addNotification('b', title: 'Packing started', read: true);

      await pump(tester);

      expect(find.text('Order #1001 is ready'), findsOneWidget);
      expect(find.text('Packing started'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    });

    testWidgets('tapping one marks it read and opens the order', (
      tester,
    ) async {
      await addNotification('a', orderId: 'order-9');
      await pump(tester);

      await tester.tap(find.text('Order ready'));
      await tester.pumpAndSettle();

      expect(find.text('ORDER order-9'), findsOneWidget);
      final stored = await InboxService(firestore).watch('u1').first;
      expect(stored.single.isRead, isTrue);
    });

    testWidgets('mark all read clears every unread notification', (
      tester,
    ) async {
      await addNotification('a');
      await addNotification('b');
      await addNotification('c', read: true);
      await pump(tester);

      await tester.tap(find.byKey(const Key('mark_all_read')));
      await tester.pumpAndSettle();

      final stored = await InboxService(firestore).watch('u1').first;
      expect(stored.every((n) => n.isRead), isTrue);
      expect(find.byKey(const Key('mark_all_read')), findsNothing);
    });

    testWidgets('swiping a notification away deletes it', (tester) async {
      await addNotification('a');
      await pump(tester);

      await tester.drag(find.text('Order ready'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(await InboxService(firestore).watch('u1').first, isEmpty);
      expect(find.text('No notifications yet'), findsOneWidget);
    });
  });
}
