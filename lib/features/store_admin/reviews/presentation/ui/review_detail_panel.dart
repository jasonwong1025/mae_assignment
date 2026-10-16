import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/side_panel_frame.dart';
import 'package:mae_assignment/shared/ui/star_rating.dart';

/// Read-only details of one review: every score and the full comment.
class ReviewDetailPanel extends StatelessWidget {
  const ReviewDetailPanel({
    required this.review,
    required this.onClose,
    super.key,
  });

  final Review review;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SidePanelFrame(
      title: 'Review of #${review.orderNumber}',
      onClose: onClose,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              StarRating(score: review.averageScore, size: 24),
              const SizedBox(width: 10),
              Text(
                review.averageScore.toStringAsFixed(1),
                style: textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${review.customerName} · '
            '${Formatters.date(review.createdAt)} '
            '${Formatters.time(review.createdAt)}',
            style: textTheme.bodyMedium,
          ),

          const _SectionTitle('Scores'),
          _ScoreRow(label: 'Shopping experience', score: review.shoppingScore),
          _ScoreRow(label: 'Product quality', score: review.productScore),
          if (review.deliveryScore != null)
            _ScoreRow(label: 'Delivery service', score: review.deliveryScore!),

          const _SectionTitle('Order'),
          _InfoRow(
            icon: review.isDelivery
                ? Icons.local_shipping_outlined
                : Icons.storefront_outlined,
            text: review.isDelivery
                ? 'Delivered by ${review.driverName}'
                : 'Pickup at the store (no delivery score)',
          ),

          const _SectionTitle('Comment'),
          Text(
            review.comment ?? 'No comment left.',
            style: review.comment == null
                ? textTheme.bodyMedium
                : textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Small uppercase heading above each block of the panel.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// "Product quality ★★★★☆".
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          StarRating(score: score.toDouble(), size: 18),
        ],
      ),
    );
  }
}

/// An icon with a line of text beside it.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
