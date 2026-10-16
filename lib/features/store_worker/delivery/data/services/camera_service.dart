import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService(ImagePicker());
});

/// Takes the proof of delivery photo with the phone's camera.
class CameraService {
  CameraService(this._picker);

  final ImagePicker _picker;

  /// Opens the camera and returns the photo, or null if cancelled.
  /// Where there is no camera (web, desktop) it opens a file chooser
  /// instead, so the flow can still be tried out.
  Future<Uint8List?> takePhoto() async {
    final source = _picker.supportsImageSource(ImageSource.camera)
        ? ImageSource.camera
        : ImageSource.gallery;
    final file = await _picker.pickImage(
      source: source,
      // Big enough to see the door and the bag, small enough to upload.
      maxWidth: 1280,
      imageQuality: 75,
    );
    if (file == null) return null;
    return await file.readAsBytes();
  }
}
