import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/ui/star_rating.dart';
import '../../data/models/review.dart';

/// Table heading. Uses the same columns as [ReviewRow].
class ReviewTableHeading extends StatelessWidget {
  const ReviewTableHeading({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: _RowLayout(
        customer: Text('CUSTOMER', style: style),
        overall: Text('OVERALL', style: style),
        driver: Text('DRIVER', style: style),
        comment: Text('COMMENT', style: style),
        date: Text('DATE', style: style),
      ),
    );
  }
}

/// One widget per column, so the heading and rows line up.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.customer,
    required this.overall,
    required this.driver,
    required this.comment,
    required this.date,
  });

  final Widget customer;
  final Widget overall;
  final Widget driver;
  final Widget comment;
  final Widget date;

  /// Adds a gap after a cell.
  Widget _spaced(Widget cell) {
    return Padding(padding: const EdgeInsets.only(right: 12), child: cell);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(flex: 3, child: _spaced(customer)),
          SizedBox(width: 130, child: _spaced(overall)),
          Expanded(flex: 2, child: _spaced(driver)),
          Expanded(flex: 4, child: _spaced(comment)),
          SizedBox(width: 96, child: date),
        ],
      ),
    );
  }
}

/// One review in the table.
class ReviewRow extends StatelessWidget {
  const ReviewRow({
    super.key,
    required this.review,
    required this.isSelected,
    required this.onTap,
  });

  final Review review;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Transparent, so the table's rounded corners show.
    return Material(
      color: isSelected ? AppColors.greenTint : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _RowLayout(
            customer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.customerName,
                  style: textTheme.titleMedium?.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text('#${review.orderNumber}', style: textTheme.bodySmall),
              ],
            ),
            overall: _OverallScore(review: review),
            driver: Text(
              review.driverName ?? 'Pickup',
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
            comment: Text(
              review.comment ?? '-',
              style: textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            date: Text(
              Formatters.date(review.createdAt),
              style: textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

/// One review as a card, for phones.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, required this.onTap});

  final Review review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.customerName,
                      style: textTheme.titleMedium?.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _OverallScore(review: review),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '#${review.orderNumber} · '
                '${review.driverName ?? 'Pickup'} · '
                '${Formatters.date(review.createdAt)}',
                style: textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
              if (review.comment != null) ...[
                const SizedBox(height: 8),
                Text(
                  review.comment!,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Stars and the average, e.g. "★★★★☆ 4.3".
class _OverallScore extends StatelessWidget {
  const _OverallScore({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRating(score: review.averageScore, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            review.averageScore.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
