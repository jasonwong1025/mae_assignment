import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(ImagePicker());
});

/// Thin wrapper around the image_picker package.
/// Opens the phone gallery, or the file chooser on web.
class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  /// Returns the chosen photos as image data. Empty if cancelled.
  Future<List<Uint8List>> pickPhotos(int limit) async {
    if (limit <= 0) return [];

    // Shrink large photos so they load fast and upload small later.
    const maxWidth = 1600.0;
    const quality = 80;

    final List<XFile> files;
    if (limit == 1) {
      // The package's multi-picker needs a limit of at least 2.
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

    // Some platforms ignore the limit, so cut the list here too.
    return [for (final file in files.take(limit)) await file.readAsBytes()];
  }
}
