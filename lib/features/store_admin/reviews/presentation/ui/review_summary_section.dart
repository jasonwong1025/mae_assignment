import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review_summary.dart';
import 'package:mae_assignment/shared/ui/star_rating.dart';

/// Top of the Reviews tab: the 3 average scores, the star breakdown and
/// the driver ranking.
class ReviewSummarySection extends StatelessWidget {
  const ReviewSummarySection({
    required this.summary,
    required this.isWide,
    required this.onDriverTap,
    super.key,
  });

  final ReviewSummary summary;
  final bool isWide;

  /// Filters the list by this driver.
  final ValueChanged<String> onDriverTap;

  @override
  Widget build(BuildContext context) {
    final gap = isWide ? 16.0 : 8.0;

    final scores = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ScoreCard(
            label: 'Shopping experience',
            average: summary.shoppingAverage,
            countText: '${summary.reviewCount} reviews',
            isWide: isWide,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _ScoreCard(
            label: 'Product quality',
            average: summary.productAverage,
            countText: '${summary.reviewCount} reviews',
            isWide: isWide,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _ScoreCard(
            label: 'Delivery service',
            average: summary.deliveryAverage,
            countText: '${summary.deliveryCount} deliveries',
            isWide: isWide,
          ),
        ),
      ],
    );

    final breakdown = _StarBreakdownCard(summary: summary);
    final drivers = _DriverRankingCard(
      drivers: summary.drivers,
      onDriverTap: onDriverTap,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        scores,
        SizedBox(height: gap),
        if (isWide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: breakdown),
                SizedBox(width: gap),
                Expanded(child: drivers),
              ],
            ),
          )
        else ...[
          breakdown,
          SizedBox(height: gap),
          drivers,
        ],
      ],
    );
  }
}

/// Small grey heading inside a card.
class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// One average score, e.g. "4.6 ★★★★★ from 46 reviews".
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.average,
    required this.countText,
    required this.isWide,
  });

  final String label;
  final double average;
  final String countText;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(isWide ? 20 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardTitle(label),
            const SizedBox(height: 8),
            Text(
              average.toStringAsFixed(1),
              style: isWide ? textTheme.headlineMedium : textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            StarRating(score: average, size: isWide ? 18 : 13),
            const SizedBox(height: 4),
            Text(countText, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Bars showing how many reviews got 5, 4, 3, 2 and 1 stars overall.
class _StarBreakdownCard extends StatelessWidget {
  const _StarBreakdownCard({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = summary.reviewCount;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardTitle('Overall rating'),
            const SizedBox(height: 12),
            for (var stars = 5; stars >= 1; stars--)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Row(
                        children: [
                          Text('$stars', style: textTheme.bodyMedium),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0
                              ? 0
                              : summary.starCounts[stars - 1] / total,
                          minHeight: 8,
                          color: AppColors.warning,
                          backgroundColor: AppColors.border,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${summary.starCounts[stars - 1]}',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Drivers of the branch, best rated first. Tap one to see their reviews.
class _DriverRankingCard extends StatelessWidget {
  const _DriverRankingCard({required this.drivers, required this.onDriverTap});

  final List<DriverRating> drivers;
  final ValueChanged<String> onDriverTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: _CardTitle('Drivers'),
          ),
          if (drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'No delivery reviews yet.',
                style: textTheme.bodyMedium,
              ),
            ),
          for (final driver in drivers)
            InkWell(
              onTap: () => onDriverTap(driver.driverId),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        driver.name,
                        style: textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StarRating(score: driver.average, size: 14),
                    SizedBox(
                      width: 36,
                      child: Text(
                        driver.average.toStringAsFixed(1),
                        style: textTheme.titleMedium?.copyWith(fontSize: 14),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '(${driver.reviewCount})',
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
