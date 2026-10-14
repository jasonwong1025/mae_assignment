import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../shared/ui/page_indicator.dart';
import 'product_labels.dart';

/// Product photos, one at a time. Swipe or use the arrows to change.
/// Shows the category icon if there are no photos.
class ProductPhotoCarousel extends StatefulWidget {
  const ProductPhotoCarousel({
    super.key,
    required this.photos,
    required this.categoryId,
  });

  final List<Uint8List> photos;
  final String categoryId;

  @override
  State<ProductPhotoCarousel> createState() => _ProductPhotoCarouselState();
}

class _ProductPhotoCarouselState extends State<ProductPhotoCarousel> {
  static const double _height = 220;

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;

    if (photos.isEmpty) {
      return Container(
        height: _height,
        decoration: BoxDecoration(
          color: AppColors.greenTint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoryIcon(widget.categoryId),
              size: 64,
              color: AppColors.darkGreen,
            ),
            const SizedBox(height: 8),
            Text('No photos yet', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: _height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: photos.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    return Image.memory(
                      photos[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
                // Arrows, because a mouse cannot swipe.
                if (_currentPage > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ArrowButton(
                      tooltip: 'Previous photo',
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => _goTo(_currentPage - 1),
                    ),
                  ),
                if (_currentPage < photos.length - 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _ArrowButton(
                      tooltip: 'Next photo',
                      icon: Icons.chevron_right_rounded,
                      onPressed: () => _goTo(_currentPage + 1),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: 10),
          PageIndicator(count: photos.length, currentIndex: _currentPage),
        ],
      ],
    );
  }
}

/// Round white button on top of the photo.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: IconButton.filled(
        tooltip: tooltip,
        icon: Icon(icon),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface.withValues(alpha: 0.9),
          foregroundColor: AppColors.textPrimary,
        ),
      ),
    );
  }
}
