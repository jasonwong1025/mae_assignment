import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';

/// Five tappable stars for choosing a score from 1 to 5. [value] 0 means
/// nothing chosen yet. Tapping the chosen star again keeps it (a score can
/// be changed but not cleared). The display-only version is `StarRating`.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  /// What is being rated, for screen readers (for example "Delivery").
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value == 0 ? 'Not rated' : '$value out of 5 stars',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var star = 1; star <= 5; star++)
            IconButton(
              tooltip: '$label: $star ${star == 1 ? 'star' : 'stars'}',
              onPressed: () => onChanged(star),
              icon: Icon(
                star <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 32,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}
