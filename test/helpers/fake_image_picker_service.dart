import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/image_picker_service.dart';

/// A real 1x1 pixel PNG, so Image.memory can show it.
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

/// Stand-in for ImagePickerService, so tests do not open a real gallery.
class FakeImagePickerService extends Fake implements ImagePickerService {
  /// How many photos the "user" chooses.
  int photosChosen = 1;

  /// The limit the app asked for last time.
  int? lastLimit;

  @override
  Future<List<Uint8List>> pickPhotos(int limit) async {
    lastLimit = limit;
    final count = photosChosen < limit ? photosChosen : limit;
    return [for (var i = 0; i < count; i++) tinyPng];
  }
}
