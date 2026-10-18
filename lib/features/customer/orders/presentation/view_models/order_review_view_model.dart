import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/repositories/review_repository.dart';

/// Live review of one order, or null while it has not been rated. The order
/// screen uses it to show either "Rate your order" or the rating given.
///
/// retry is disabled so a failed read settles instead of spinning.
final orderReviewProvider = StreamProvider.autoDispose
    .family<OrderReview?, String>((ref, orderId) {
      return ref.watch(reviewRepositoryProvider).watchReview(orderId);
    }, retry: (_, _) => null);

/// True while a rating is being saved, so the Send button shows it is busy
/// and ignores repeat taps. autoDispose: resets when the sheet closes.
final NotifierProvider<OrderReviewViewModel, bool>
orderReviewViewModelProvider =
    NotifierProvider.autoDispose<OrderReviewViewModel, bool>(
      OrderReviewViewModel.new,
    );

class OrderReviewViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  /// Saves the rating of [order]. Returns an error message, or null if it
  /// worked.
  Future<String?> submit({
    required Order order,
    required int shoppingScore,
    required int productScore,
    int? deliveryScore,
    String? comment,
  }) async {
    if (state) return null;
    state = true;
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return 'Please sign in to rate an order.';
      await ref
          .read(reviewRepositoryProvider)
          .submit(
            order: order,
            customer: user,
            shoppingScore: shoppingScore,
            productScore: productScore,
            deliveryScore: deliveryScore,
            comment: comment,
          );
      return null;
    } on AppException catch (error) {
      return error.message;
    } on Object {
      return 'Could not confirm your account. Please try again.';
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
