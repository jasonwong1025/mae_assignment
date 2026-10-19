import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review_summary.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/repositories/reviews_repository.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/ui/review_rows.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/views/reviews_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/review_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// Shows the Reviews tab on a screen of [size].
Future<void> _pumpReviews(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeAuthRepository()
    ..userToSignIn = _admin
    ..signedIn = true;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        firebaseFirestoreProvider.overrideWithValue(await _reviewsDatabase()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const ReviewsView()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls the page (not the sideways filter row) until [finder] shows.
Future<void> _scrollTo(WidgetTester tester, Finder finder) {
  return tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

/// SS15 has 46 reviews, newest first: order #2279 is the newest and every
/// 8 hours older after that. 35 are for deliveries (Azlan delivered 7,
/// Amir and Firdaus the rest), every 3rd has a comment and every 9th is a
/// 1-star review.
Future<FakeFirebaseFirestore> _reviewsDatabase() async {
  final firestore = FakeFirebaseFirestore();
  final now = DateTime.now();
  var delivery = 0;
  for (var i = 0; i < 46; i++) {
    final isDelivery = i % 4 != 3;
    final driver = isDelivery
        ? (delivery % 5 == 2
              ? ('driver-azlan', 'Azlan Shah')
              : (delivery.isEven
                    ? ('driver-amir', 'Amir Hamzah')
                    : ('driver-firdaus', 'Firdaus Rahim')))
        : null;
    if (isDelivery) delivery++;
    final low = i % 9 == 5;
    await firestore.collection('reviews').doc('ord-${2279 + i}').set({
      'orderNumber': 2279 + i,
      'branchId': 'ss15',
      'customerId': 'customer-$i',
      'customerName': i == 0 ? 'Farah Idris' : 'Customer $i',
      'shoppingScore': low ? 1 : 4 + (i % 2),
      'productScore': low ? 1 : 5,
      if (isDelivery) 'deliveryScore': low ? 1 : 4,
      if (driver != null) 'driverId': driver.$1,
      if (driver != null) 'driverName': driver.$2,
      if (i % 3 == 0) 'comment': 'Comment $i',
      'createdAt': Timestamp.fromDate(now.subtract(Duration(hours: 8 * i))),
    });
  }
  return firestore;
}

Review _review({
  required int shopping,
  required int product,
  int? delivery,
  String? driverId,
}) {
  return Review(
    id: 'r$shopping$product$delivery',
    orderNumber: 1,
    branchId: 'ss15',
    customerName: 'Customer',
    createdAt: DateTime(2026),
    shoppingScore: shopping,
    productScore: product,
    deliveryScore: delivery,
    driverId: driverId,
    driverName: driverId == null ? null : 'Driver $driverId',
  );
}

void main() {
  // Tall enough to show a page of rows.
  const desktop = Size(1600, 1500);
  const phone = Size(390, 844);

  group('Review', () {
    test('averages only the scores given', () {
      expect(_review(shopping: 5, product: 3).averageScore, 4);
      expect(_review(shopping: 5, product: 4, delivery: 3).averageScore, 4);
      expect(_review(shopping: 2, product: 1, delivery: 1).stars, 1);
    });
  });

  group('ReviewSummary', () {
    test('averages scores and ranks drivers', () {
      final summary = ReviewSummary.from([
        _review(shopping: 5, product: 5, delivery: 5, driverId: 'a'),
        _review(shopping: 3, product: 3, delivery: 2, driverId: 'b'),
        _review(shopping: 4, product: 4),
      ]);

      expect(summary.reviewCount, 3);
      expect(summary.deliveryCount, 2);
      expect(summary.shoppingAverage, 4);
      expect(summary.deliveryAverage, 3.5);
      // 5 stars, 3 stars, 4 stars.
      expect(summary.starCounts, [0, 0, 1, 1, 1]);
      expect(summary.drivers.map((d) => d.driverId), ['a', 'b']);
    });
  });

  group('ReviewsRepository', () {
    late ReviewsRepository repository;

    setUp(() async {
      repository = ReviewsRepository(ReviewService(await _reviewsDatabase()));
    });

    test('returns pages of 20, newest first', () async {
      final first = await repository.getReviews('ss15');

      expect(first.totalCount, 46);
      expect(first.pageCount, 3);
      expect(first.items.length, 20);
      expect(
        first.items.first.createdAt.isAfter(first.items.last.createdAt),
        isTrue,
      );
    });

    test('filters by stars, driver and comment', () async {
      final low = await repository.getReviews('ss15', stars: 1);
      final azlan = await repository.getReviews(
        'ss15',
        driverId: 'driver-azlan',
      );
      final withComment = await repository.getReviews(
        'ss15',
        commentsOnly: true,
      );

      expect(low.items, isNotEmpty);
      expect(low.items.every((review) => review.stars == 1), isTrue);
      expect(azlan.items.every((r) => r.driverName == 'Azlan Shah'), isTrue);
      expect(withComment.items.every((r) => r.comment != null), isTrue);
    });

    test('date filter keeps only recent reviews', () async {
      final all = await repository.getReviews('ss15');
      final week = await repository.getReviews(
        'ss15',
        period: ReviewPeriod.last7Days,
      );

      expect(week.totalCount, lessThan(all.totalCount));
      expect(week.totalCount, greaterThan(0));
    });

    test('search finds an order number', () async {
      final result = await repository.getReviews('ss15', searchText: '#2279');

      expect(result.totalCount, 1);
      expect(result.items.single.customerName, 'Farah Idris');
    });
  });

  testWidgets('Shows the scores, drivers and the first page', (tester) async {
    await _pumpReviews(tester, desktop);

    expect(find.text('What customers say about SS15 Subang'), findsOneWidget);
    expect(find.text('46 reviews'), findsNWidgets(2));
    expect(find.text('35 deliveries'), findsOneWidget);
    expect(find.text('Azlan Shah'), findsWidgets);
    expect(find.byType(ReviewRow), findsWidgets);

    await _scrollTo(tester, find.text('1-20 of 46 reviews'));
    expect(find.text('1-20 of 46 reviews'), findsOneWidget);
  });

  testWidgets('Tapping a driver shows only their reviews', (tester) async {
    await _pumpReviews(tester, desktop);

    // The first "Azlan Shah" is in the driver ranking.
    await tester.tap(find.text('Azlan Shah').first);
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('1-7 of 7 reviews'));
    expect(find.text('1-7 of 7 reviews'), findsOneWidget);
    expect(find.text('Firdaus Rahim'), findsOneWidget);
  });

  testWidgets('Tapping a review opens its details', (tester) async {
    await _pumpReviews(tester, desktop);

    await tester.tap(find.text('Farah Idris').first);
    await tester.pumpAndSettle();

    expect(find.text('Review of #2279'), findsOneWidget);
    expect(find.text('Delivered by Amir Hamzah'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Review of #2279'), findsNothing);
  });

  testWidgets('Phone shows cards and opens a full page', (tester) async {
    await _pumpReviews(tester, phone);

    // Cards are only built once scrolled into view.
    await _scrollTo(tester, find.text('Farah Idris'));
    expect(find.byType(ReviewCard), findsWidgets);

    await tester.tap(find.text('Farah Idris'));
    await tester.pumpAndSettle();
    expect(find.text('Review of #2279'), findsOneWidget);
  });
}
