import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';

/// Five stars showing a score out of 5. Halves are shown as half stars.
/// Display only.
class StarRating extends StatelessWidget {
  const StarRating({required this.score, super.key, this.size = 16});

  final double score;
  final double size;

  IconData _iconFor(int star) {
    if (score >= star - 0.25) return Icons.star_rounded;
    if (score >= star - 0.75) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${score.toStringAsFixed(1)} out of 5 stars',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var star = 1; star <= 5; star++)
              Icon(_iconFor(star), size: size, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}
