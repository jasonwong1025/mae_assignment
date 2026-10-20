import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/wallet/data/models/wallet_entry.dart';
import 'package:mae_assignment/features/customer/wallet/data/repositories/wallet_repository.dart';
import 'package:mae_assignment/features/customer/wallet/data/services/wallet_service.dart';
import 'package:mae_assignment/features/customer/wallet/presentation/views/wallet_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';

/// A wallet service whose top up is a closure, since the real one calls the
/// Cloud Function.
class _TestWalletService extends WalletService {
  _TestWalletService(super.firestore, this.onTopUp);

  final Future<double> Function(double amount) onTopUp;
  final topUps = <double>[];

  @override
  Future<double> topUp(double amount, {required String method}) {
    topUps.add(amount);
    return onTopUp(amount);
  }
}

void main() {
  late FakeFirebaseFirestore firestore;

  Future<void> seedWallet({
    double balance = 50,
    List<Map<String, Object?>> entries = const [],
  }) async {
    final user = firestore.collection('users').doc('u1');
    await user.collection('wallet').doc('current').set({'balance': balance});
    for (final (index, entry) in entries.indexed) {
      await user.collection('walletTransactions').doc('e$index').set(entry);
    }
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  group('WalletEntry', () {
    test('reads an entry from Firestore', () {
      final entry = WalletEntry.fromFirestore('a', {
        'type': 'refund',
        'amount': 8.9,
        'balanceAfter': 58.9,
        'description': 'Refund for cancelled order #1001',
        'orderId': 'o1',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 16, 15)),
      });

      expect(entry.type, WalletEntryType.refund);
      expect(entry.amount, 8.9);
      expect(entry.isCredit, isTrue);
      expect(entry.orderId, 'o1');
      expect(entry.createdAt, DateTime(2026, 10, 16, 15));
    });

    test('a payment is a debit', () {
      final entry = WalletEntry.fromFirestore('a', {
        'type': 'payment',
        'amount': -12.8,
        'balanceAfter': 37.2,
        'description': 'Payment for order #1002',
      });

      expect(entry.isCredit, isFalse);
      expect(entry.orderId, isNull);
    });

    test('an unknown type reads as an adjustment, not a crash', () {
      final entry = WalletEntry.fromFirestore('a', {
        'type': 'bonus',
        'amount': 1,
        'balanceAfter': 1,
        'description': 'x',
      });

      expect(entry.type, WalletEntryType.adjustment);
    });
  });

  group('WalletService', () {
    test('the balance is 0 until the wallet exists', () async {
      final service = WalletService(firestore);

      expect(await service.watchBalance('u1').first, 0);
    });

    test('the balance follows the wallet document', () async {
      final service = WalletService(firestore);
      await seedWallet(balance: 12.5);

      expect(await service.watchBalance('u1').first, 12.5);
      expect(await service.watchBalance('someone-else').first, 0);
    });

    test('the history is newest first', () async {
      final service = WalletService(firestore);
      await seedWallet(
        entries: [
          {
            'type': 'topUp',
            'amount': 50,
            'balanceAfter': 50,
            'description': 'Top up',
            'createdAt': Timestamp.fromDate(DateTime(2026, 10)),
          },
          {
            'type': 'payment',
            'amount': -10,
            'balanceAfter': 40,
            'description': 'Payment for order #1001',
            'createdAt': Timestamp.fromDate(DateTime(2026, 10, 2)),
          },
        ],
      );

      final entries = await service.watchEntries('u1').first;

      expect(entries.map((e) => e.type), [
        WalletEntryType.payment,
        WalletEntryType.topUp,
      ]);
    });
  });

  group('WalletRepository', () {
    test('tops up through the service', () async {
      final service = _TestWalletService(firestore, (amount) async => 70);

      final balance = await WalletRepository(service).topUp(20);

      expect(balance, 70);
      expect(service.topUps, [20]);
    });

    test('refuses an amount outside the limits without calling out', () async {
      final service = _TestWalletService(firestore, (amount) async => 0);
      final repository = WalletRepository(service);

      for (final amount in [0.0, 0.5, 501.0, -5.0]) {
        expect(
          repository.topUp(amount),
          throwsA(isA<WalletException>()),
          reason: '$amount',
        );
      }
      expect(service.topUps, isEmpty);
    });

    test("shows the Function's reason when it refuses", () async {
      final service = _TestWalletService(
        firestore,
        (amount) async => throw FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'A wallet can hold at most RM 2000.',
        ),
      );

      expect(
        WalletRepository(service).topUp(100),
        throwsA(
          isA<WalletException>().having(
            (e) => e.message,
            'message',
            'A wallet can hold at most RM 2000.',
          ),
        ),
      );
    });

    test('any other failure gives a connection message', () async {
      final service = _TestWalletService(
        firestore,
        (amount) async => throw FirebaseFunctionsException(
          code: 'unavailable',
          message: 'raw backend text',
        ),
      );

      expect(
        WalletRepository(service).topUp(100),
        throwsA(
          isA<WalletException>().having(
            (e) => e.message,
            'message',
            contains('check your connection'),
          ),
        ),
      );
    });
  });

  group('WalletView', () {
    late _TestWalletService service;

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final auth = FakeAuthRepository()
        ..signedIn = true
        ..uidStream = Stream.value('u1')
        ..userToSignIn = const AppUser(
          uid: 'u1',
          name: 'Aisha',
          email: 'a@example.com',
          phone: '012',
          role: UserRole.customer,
        );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            walletServiceProvider.overrideWithValue(service),
          ],
          child: const MaterialApp(home: WalletView()),
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      service = _TestWalletService(firestore, (amount) async {
        await seedWallet(balance: 50 + amount);
        return 50 + amount;
      });
    });

    testWidgets('shows the balance, the note and the history', (tester) async {
      await seedWallet(
        entries: [
          {
            'type': 'payment',
            'amount': -17.8,
            'balanceAfter': 32.2,
            'description': 'Payment for order #1001',
            'createdAt': Timestamp.fromDate(DateTime(2026, 10, 16, 15)),
          },
        ],
      );

      await pump(tester);

      expect(find.text('RM 50.00'), findsOneWidget);
      expect(find.textContaining('No real money'), findsOneWidget);
      expect(find.text('Payment for order #1001'), findsOneWidget);
      expect(find.text('−RM 17.80'), findsOneWidget);
    });

    testWidgets('an empty wallet shows a hint and RM 0.00', (tester) async {
      await pump(tester);

      expect(find.text('RM 0.00'), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('tops up the chosen amount and shows the new balance', (
      tester,
    ) async {
      await seedWallet();
      await pump(tester);

      await tester.tap(find.text('RM 100'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wallet_top_up_button')));
      await tester.pumpAndSettle();

      expect(service.topUps, [100]);
      expect(find.text('RM 100.00 added to your wallet.'), findsOneWidget);
      expect(find.text('RM 150.00'), findsOneWidget);
    });

    testWidgets('a typed amount wins over the chip', (tester) async {
      await seedWallet();
      await pump(tester);

      await tester.enterText(
        find.byKey(const Key('wallet_custom_amount')),
        '35.5',
      );
      await tester.pumpAndSettle();
      expect(find.text('Top up RM 35.50'), findsOneWidget);
      await tester.tap(find.byKey(const Key('wallet_top_up_button')));
      await tester.pumpAndSettle();

      expect(service.topUps, [35.5]);
    });

    testWidgets('an amount over the limit is not sent', (tester) async {
      await seedWallet();
      await pump(tester);

      await tester.enterText(
        find.byKey(const Key('wallet_custom_amount')),
        '900',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wallet_top_up_button')));
      await tester.pumpAndSettle();

      expect(service.topUps, isEmpty);
      expect(
        find.text('Enter an amount between RM 1 and RM 500.'),
        findsOneWidget,
      );
    });

    testWidgets('shows why a top up was refused', (tester) async {
      service = _TestWalletService(
        firestore,
        (amount) async => throw FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'A wallet can hold at most RM 2000.',
        ),
      );
      await seedWallet();
      await pump(tester);

      await tester.tap(find.byKey(const Key('wallet_top_up_button')));
      await tester.pumpAndSettle();

      expect(find.text('A wallet can hold at most RM 2000.'), findsOneWidget);
    });
  });
}
