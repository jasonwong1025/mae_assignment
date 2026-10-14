import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/image_picker_service.dart';

/// A real 1x1 pixel PNG.
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

/// Fake ImagePickerService, so tests do not open a gallery.
class FakeImagePickerService extends Fake implements ImagePickerService {
  /// Number of photos to return.
  int photosChosen = 1;

  /// Limit asked for in the last call.
  int? lastLimit;

  @override
  Future<List<Uint8List>> pickPhotos(int limit) async {
    lastLimit = limit;
    final count = photosChosen < limit ? photosChosen : limit;
    return [for (var i = 0; i < count; i++) tinyPng];
  }
}
