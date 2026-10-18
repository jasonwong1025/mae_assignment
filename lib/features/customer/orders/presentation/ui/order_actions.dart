import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/orders/presentation/ui/review_sheet.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/order_actions_view_model.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/order_review_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/confirm_sheet.dart';
import 'package:mae_assignment/shared/ui/star_rating.dart';

/// What the customer can do with an order, depending on where it is:
/// cancel it while it is still pending, order the same things again once it
/// is finished, and rate it once it is completed.
class OrderActions extends ConsumerWidget {
  const OrderActions({required this.order, super.key});

  final Order order;

  void _say(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.cancel_outlined,
      title: 'Cancel order #${order.number}?',
      message:
          'The store has not started packing it yet. This cannot be undone.',
      confirmLabel: 'Cancel order',
      cancelLabel: 'Keep order',
    );
    if (!confirmed || !context.mounted) return;

    final error = await ref
        .read(orderActionsViewModelProvider.notifier)
        .cancel(order);
    if (!context.mounted) return;
    _say(context, error ?? 'Order #${order.number} was cancelled.');
  }

  Future<void> _orderAgain(BuildContext context, WidgetRef ref) async {
    final cartCount = ref.read(cartCountProvider);
    if (cartCount > 0) {
      final confirmed = await showConfirmSheet(
        context,
        icon: Icons.shopping_cart_outlined,
        title: 'Replace your cart?',
        message:
            'Your cart has $cartCount ${cartCount == 1 ? 'item' : 'items'}. '
            'Ordering again replaces them with this order.',
        confirmLabel: 'Replace cart',
        cancelLabel: 'Keep my cart',
      );
      if (!confirmed || !context.mounted) return;
    }

    final result = await ref
        .read(orderActionsViewModelProvider.notifier)
        .reorder(order);
    if (!context.mounted) return;
    if (!result.isSuccess) {
      _say(context, result.error!);
      return;
    }
    if (result.unavailable.isNotEmpty) {
      _say(
        context,
        'Not available right now, so left out: '
        '${result.unavailable.join(', ')}.',
      );
    }
    context.go(AppRoutes.customerCart);
  }

  Future<void> _rate(BuildContext context) async {
    final sent = await showReviewSheet(context, order);
    if (sent && context.mounted) _say(context, 'Thanks for your feedback!');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(orderActionsViewModelProvider);
    final isPending = order.status == OrderStatus.pending;
    final isCompleted = order.status == OrderStatus.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCompleted) _ReviewSection(order: order, onRate: _rate),
        if (isPending)
          OutlinedButton.icon(
            key: const Key('cancel_order_button'),
            onPressed: busy ? null : () => _cancel(context, ref),
            icon: busy
                ? const ButtonLoadingIndicator()
                : const Icon(Icons.cancel_outlined),
            label: const Text('Cancel order'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
        if (order.status.isFinished)
          FilledButton.icon(
            key: const Key('reorder_button'),
            onPressed: busy ? null : () => _orderAgain(context, ref),
            icon: busy
                ? const ButtonLoadingIndicator()
                : const Icon(Icons.replay_rounded),
            label: const Text('Order again'),
          ),
      ],
    );
  }
}

/// "Rate your order" until the customer has rated; the rating given after.
class _ReviewSection extends ConsumerWidget {
  const _ReviewSection({required this.order, required this.onRate});

  final Order order;
  final Future<void> Function(BuildContext context) onRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(orderReviewProvider(order.id));
    // While loading, or if the read failed, show nothing rather than a
    // button that might rate an order twice.
    final value = review.value;
    if (!review.hasValue) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: value == null
          ? OutlinedButton.icon(
              key: const Key('rate_order_button'),
              onPressed: () => onRate(context),
              icon: const Icon(Icons.star_outline_rounded),
              label: const Text('Rate your order'),
            )
          : _RatingSummary(review: value),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.review});

  final OrderReview review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final comment = review.comment;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your rating', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              StarRating(score: review.averageScore, size: 22),
              const SizedBox(width: AppSpacing.s),
              Text(
                review.averageScore.toStringAsFixed(1),
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(comment, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
