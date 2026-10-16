import 'models/review.dart';

/// Sample reviews for every branch, newest first.
/// Dates are worked out from [now], so they always look recent.
/// TODO: delete once reviews come from Firestore.
List<Review> sampleReviews(DateTime now) {
  return [
    ..._branchReviews(
      now,
      branchId: 'ss15',
      count: 46,
      firstOrderNumber: 2279,
      drivers: _ss15Drivers,
    ),
    ..._branchReviews(
      now,
      branchId: 'bukit-jalil',
      count: 18,
      firstOrderNumber: 1174,
      drivers: _bukitJalilDrivers,
    ),
    ..._branchReviews(
      now,
      branchId: 'puchong',
      count: 9,
      firstOrderNumber: 902,
      drivers: _puchongDrivers,
    ),
  ];
}

/// A driver with the delivery scores they usually get.
class _SampleDriver {
  const _SampleDriver(this.id, this.name, this.scores);

  final String id;
  final String name;
  final List<int> scores;
}

const _ss15Drivers = [
  _SampleDriver('w7', 'Amir Hamzah', [5, 5, 5, 4, 5]),
  _SampleDriver('w8', 'Firdaus Rahim', [5, 4, 4, 5, 4, 3]),
  _SampleDriver('w10', 'Kumar Selvam', [4, 4, 3, 5]),
  _SampleDriver('w30', 'Jason Tan', [5, 4, 5]),
  _SampleDriver('w25', 'Azlan Shah', [3, 2, 4, 3]),
];

const _bukitJalilDrivers = [
  _SampleDriver('w9', 'Lau Wei Jie', [5, 5, 4, 5]),
  _SampleDriver('w31', 'Marcus Ho', [4, 3, 4]),
  _SampleDriver('w28', 'Ganesh Pillai', [4, 5, 4]),
];

const _puchongDrivers = [
  _SampleDriver('w27', 'Danish Iskandar', [4, 4, 5]),
  _SampleDriver('w29', 'Haziq Amir', [3, 4, 2]),
];

const _customers = [
  'Farah Idris',
  'Wong Kar Yee',
  'Nur Aisyah',
  'Mei Ling Tan',
  'David Wong',
  'Siti Aminah',
  'Raj Kumar',
  'Chong Wei Ling',
  'Wei Ming',
  'Lim H.',
  'K. Devi',
  'Priya Nair',
  'Kelvin Lim',
  'Tan Boon Huat',
  'Aisyah Rahman',
  'Jun Hao Lee',
  'Ooi Hui Min',
  'Ahmad Fauzi',
  'Lee Mei Fong',
  'Muthu Krishnan',
];

const _shoppingScores = [5, 4, 5, 5, 3, 4, 5, 2];
const _productScores = [5, 5, 4, 3, 5, 4];

// Comments for good, okay and bad scores.
const _goodComments = [
  'Everything was fresh and well packed.',
  'Vegetables were very fresh, will order again.',
  'Easy to order and the app is simple to use.',
  'Great service, thank you!',
];
const _okayComments = [
  'Bread was a little squashed.',
  'Good overall, packing could be neater.',
];
const _badComments = [
  'Bananas were overripe.',
  'Wrong brand of milk was packed.',
];

// Extra comments that only fit delivery orders.
const _goodDeliveryComments = [
  'Driver was friendly and on time.',
  'Fast delivery, eggs not broken at all.',
];
const _okayDeliveryComments = [
  'Delivery was a bit late but the items were fine.',
];
const _badDeliveryComments = [
  'Driver could not find my block and did not call.',
  'Arrived 40 minutes late and the ice cream had melted.',
];

// Extra comments that only fit pickup orders.
const _okayPickupComments = ['Took a while to find my order at pickup.'];

/// [count] reviews for one branch. Every 4th order is a pickup.
List<Review> _branchReviews(
  DateTime now, {
  required String branchId,
  required int count,
  required int firstOrderNumber,
  required List<_SampleDriver> drivers,
}) {
  return [
    for (var i = 0; i < count; i++)
      _review(
        now,
        index: i,
        branchId: branchId,
        orderNumber: firstOrderNumber - i,
        driver: i % 4 == 3 ? null : drivers[i % drivers.length],
      ),
  ];
}

Review _review(
  DateTime now, {
  required int index,
  required String branchId,
  required int orderNumber,
  required _SampleDriver? driver,
}) {
  // Every 9th customer was unhappy, so there are some 1 and 2 star reviews.
  final isUnhappy = index % 9 == 4;
  final low = 1 + index % 2;

  final shoppingScore = isUnhappy
      ? 2
      : _shoppingScores[index % _shoppingScores.length];
  final productScore = isUnhappy
      ? low
      : _productScores[index % _productScores.length];
  final int? deliveryScore;
  if (driver == null) {
    deliveryScore = null;
  } else {
    deliveryScore = isUnhappy
        ? low
        : driver.scores[index % driver.scores.length];
  }

  // The comment matches how good the scores are. Every 3rd has none.
  final scores = [shoppingScore, productScore, ?deliveryScore];
  final average = scores.reduce((a, b) => a + b) / scores.length;
  final isDelivery = driver != null;
  final List<String> comments;
  if (average >= 4) {
    comments = [..._goodComments, if (isDelivery) ..._goodDeliveryComments];
  } else if (average >= 3) {
    comments = [
      ..._okayComments,
      if (isDelivery) ..._okayDeliveryComments,
      if (!isDelivery) ..._okayPickupComments,
    ];
  } else {
    comments = [..._badComments, if (isDelivery) ..._badDeliveryComments];
  }

  return Review(
    id: '$branchId-$orderNumber',
    orderNumber: orderNumber,
    branchId: branchId,
    customerName: _customers[index % _customers.length],
    // About one review every 17 hours, going back about a month.
    createdAt: now.subtract(Duration(hours: index * 17, minutes: index * 7)),
    shoppingScore: shoppingScore,
    productScore: productScore,
    deliveryScore: deliveryScore,
    driverId: driver?.id,
    driverName: driver?.name,
    comment: index % 3 == 2 ? null : comments[index % comments.length],
  );
}
