import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/shared/models/order_review.dart';

final Provider<ReviewService> reviewServiceProvider = Provider<ReviewService>(
  (ref) => ReviewService(ref.watch(firebaseFirestoreProvider)),
);

/// Reads and writes reviews/{orderId} in Firestore. The customer app writes a
/// review once an order is completed; the Store Admin Reviews tab will read
/// them when it is connected. See `firestore.rules`.
class ReviewService {
  ReviewService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// Live review of one order, or null while it has not been rated.
  Stream<OrderReview?> watchReview(String orderId) {
    return _refs
        .review(orderId)
        .snapshots()
        .map((doc) => doc.toModel(fromFirestore: OrderReview.fromFirestore));
  }

  /// Saves [review] under its order id, with the server time as createdAt.
  /// The rules reject a second review of the same order.
  Future<void> createReview(OrderReview review) {
    return _refs.review(review.id).set({
      ...review.toFirestore(),
      ReviewFields.createdAt: FieldValue.serverTimestamp(),
    });
  }
}
