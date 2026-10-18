import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/order_review_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/star_rating_input.dart';

/// Opens the rating sheet for a completed [order]. Resolves to true if the
/// customer sent a rating.
Future<bool> showReviewSheet(BuildContext context, Order order) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ReviewSheet(order: order),
  );
  return sent ?? false;
}

/// Rate the shopping experience, the products and (for delivery orders) the
/// delivery with stars, and optionally leave a comment.
class ReviewSheet extends ConsumerStatefulWidget {
  const ReviewSheet({required this.order, super.key});

  final Order order;

  @override
  ConsumerState<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<ReviewSheet> {
  final _comment = TextEditingController();
  int _shopping = 0;
  int _product = 0;
  int _delivery = 0;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _isComplete {
    return _shopping > 0 &&
        _product > 0 &&
        (!widget.order.isDelivery || _delivery > 0);
  }

  Future<void> _send() async {
    setState(() => _error = null);
    final error = await ref
        .read(orderReviewViewModelProvider.notifier)
        .submit(
          order: widget.order,
          shoppingScore: _shopping,
          productScore: _product,
          deliveryScore: widget.order.isDelivery ? _delivery : null,
          comment: _comment.text,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sending = ref.watch(orderReviewViewModelProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rate order #${widget.order.number}',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'How did we do? Your rating helps the store improve.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            _RatingRow(
              label: 'Shopping experience',
              value: _shopping,
              onChanged: (value) => setState(() => _shopping = value),
            ),
            _RatingRow(
              label: 'Product quality',
              value: _product,
              onChanged: (value) => setState(() => _product = value),
            ),
            if (widget.order.isDelivery)
              _RatingRow(
                label: 'Delivery',
                value: _delivery,
                onChanged: (value) => setState(() => _delivery = value),
              ),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: _comment,
              maxLength: ReviewFields.maxCommentLength,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                _error!,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              onPressed: _isComplete && !sending ? _send : null,
              child: sending
                  ? const ButtonLoadingIndicator()
                  : const Text('Send rating'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        StarRatingInput(label: label, value: value, onChanged: onChanged),
      ],
    );
  }
}
