import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/storage_paths.dart';

final Provider<ProductPhotoService> productPhotoServiceProvider =
    Provider<ProductPhotoService>(
      (ref) => ProductPhotoService(FirebaseStorage.instance),
    );

/// Uploads and removes product photos in Firebase Storage. Admin only; see
/// `storage.rules`. A product stores only the download URLs.
class ProductPhotoService {
  ProductPhotoService(this._storage);

  final FirebaseStorage _storage;

  /// Uploads [bytes] under [productId] and returns the download URL.
  Future<String> upload(String productId, Uint8List bytes) async {
    final type = _typeOf(bytes);
    final name = '${DateTime.now().microsecondsSinceEpoch}.${type.extension}';
    final file = _storage.ref(StoragePaths.productPhoto(productId, name));
    await file.putData(bytes, SettableMetadata(contentType: type.mime));
    return await file.getDownloadURL();
  }

  /// Removes the photo at [url]. A photo that is already gone is not an
  /// error.
  Future<void> delete(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }

  /// The image type from the file's first bytes. The picker usually returns
  /// JPEG, but a PNG or WebP can come through unchanged.
  ({String mime, String extension}) _typeOf(Uint8List bytes) {
    final isPng =
        bytes.length > 3 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    if (isPng) return (mime: 'image/png', extension: 'png');
    final isWebp =
        bytes.length > 11 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
    if (isWebp) return (mime: 'image/webp', extension: 'webp');
    return (mime: 'image/jpeg', extension: 'jpg');
  }
}
