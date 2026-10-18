import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';

/// One product photo, whether it is already uploaded (loaded from its URL) or
/// just picked from the gallery (shown from memory).
class ProductPhotoImage extends StatelessWidget {
  const ProductPhotoImage({
    required this.photo,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final ProductPhoto photo;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return switch (photo) {
      StoredPhoto(:final url) => Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : _placeholder(loading: true);
        },
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
      PickedPhoto(:final bytes) => Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
      ),
    };
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.greenTint,
      alignment: Alignment.center,
      child: Icon(
        loading ? Icons.image_outlined : Icons.broken_image_outlined,
        color: AppColors.darkGreen,
      ),
    );
  }
}
