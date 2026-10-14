import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/models/product.dart';

/// Row of photo tiles for the product form. Each photo has a remove
/// button, and an "Add" tile is shown until the limit is reached.
class ProductPhotosField extends StatelessWidget {
  const ProductPhotosField({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  static const double _tileSize = 72;

  final List<Uint8List> photos;
  final VoidCallback onAdd;

  /// Called with the position of the photo to remove.
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < photos.length; i++)
              _PhotoTile(
                photo: photos[i],
                size: _tileSize,
                onRemove: () => onRemove(i),
              ),
            if (photos.length < Product.maxPhotos)
              _AddTile(size: _tileSize, onTap: onAdd),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Up to ${Product.maxPhotos} photos. The first one is the cover.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.size,
    required this.onRemove,
  });

  final Uint8List photo;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              photo,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          // Small round "x" in the top right corner.
          Positioned(
            top: 2,
            right: 2,
            child: Tooltip(
              message: 'Remove photo',
              child: Material(
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(3),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(size, size),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined),
            SizedBox(height: 2),
            Text('Add', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
