import 'dart:typed_data';

/// A group of products, e.g. "Dairy & Eggs".
class ProductCategory {
  const ProductCategory({required this.id, required this.name});

  final String id;
  final String name;
}

/// A product in the company catalogue. Shared by every branch.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.packSize,
    required this.description,
    required this.lowStockLevel,
    this.photos = const [],
  });

  final String id;
  final String name;
  final String brand;
  final String categoryId;

  /// Size of one unit, e.g. "1L" or "500g".
  final String packSize;

  /// Shown to customers. Can be empty.
  final String description;

  /// Stock at or below this counts as low.
  final int lowStockLevel;

  /// Up to [maxPhotos] pictures. The first one is the cover.
  /// Kept as image data for now; will be Firebase Storage links later.
  final List<Uint8List> photos;

  static const int maxPhotos = 5;

  /// Cover picture, or null if there are no photos.
  Uint8List? get cover => photos.isEmpty ? null : photos.first;
}
