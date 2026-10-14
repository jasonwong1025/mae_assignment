import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(ImagePicker());
});

/// Wrapper around the image_picker package.
class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  /// Opens the gallery (file chooser on web). Empty list if cancelled.
  Future<List<Uint8List>> pickPhotos(int limit) async {
    if (limit <= 0) return [];

    // Shrink large photos.
    const maxWidth = 1600.0;
    const quality = 80;

    final List<XFile> files;
    if (limit == 1) {
      // pickMultiImage needs a limit of 2 or more.
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        imageQuality: quality,
      );
      files = [?file];
    } else {
      files = await _picker.pickMultiImage(
        limit: limit,
        maxWidth: maxWidth,
        imageQuality: quality,
      );
    }

    // Some platforms ignore the limit.
    return [for (final file in files.take(limit)) await file.readAsBytes()];
  }
}
