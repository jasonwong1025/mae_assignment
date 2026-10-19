import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/storage_paths.dart';

final Provider<DeliveryProofService> deliveryProofServiceProvider =
    Provider<DeliveryProofService>(
      (ref) => DeliveryProofService(FirebaseStorage.instance),
    );

/// Uploads the photo a driver takes as proof of delivery to Firebase
/// Storage. An order stores only the download URL (`proofPhotoUrl`). See
/// `storage.rules` for who may write it.
class DeliveryProofService {
  DeliveryProofService(this._storage);

  final FirebaseStorage _storage;

  /// Uploads [photo] for [orderId] and returns its download URL. Uploading
  /// again replaces the earlier photo.
  Future<String> upload(String orderId, Uint8List photo) async {
    final file = _storage.ref(StoragePaths.deliveryProof(orderId));
    await file.putData(photo, SettableMetadata(contentType: 'image/jpeg'));
    return await file.getDownloadURL();
  }
}
