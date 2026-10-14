import 'dart:typed_data';

/// Product category, e.g. "Dairy & Eggs".
class ProductCategory {
  const ProductCategory({required this.id, required this.name});

  final String id;
  final String name;
}

/// A product. Shared by every branch.
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

  /// E.g. "1L" or "500g".
  final String packSize;

  /// Can be empty.
  final String description;

  /// Stock at or below this counts as low.
  final int lowStockLevel;

  /// Up to [maxPhotos]. The first is the cover.
  /// Image data for now. Firebase Storage links later.
  final List<Uint8List> photos;

  static const int maxPhotos = 5;

  /// First photo. Null if none.
  Uint8List? get cover => photos.isEmpty ? null : photos.first;
}
