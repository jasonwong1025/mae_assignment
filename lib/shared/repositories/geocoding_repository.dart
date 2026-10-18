import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/shared/services/geocoding_service.dart';

part 'geocoding_repository.freezed.dart';

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepository(ref.watch(geocodingServiceProvider));
});

/// One search result: a full address and where it is.
@freezed
abstract class AddressResult with _$AddressResult {
  const factory AddressResult({
    required String address,
    required LatLng location,
  }) = _AddressResult;

  const AddressResult._();
}

/// Turns typed addresses into map locations and map points into addresses,
/// over the shared [GeocodingService]. Used by the admin branch form and
/// the customer address picker.
class GeocodingRepository {
  GeocodingRepository(this._service);

  final GeocodingService _service;

  /// Up to 5 matches for [text]. Throws if the search fails.
  Future<List<AddressResult>> search(String text) async {
    try {
      final results = await _service.search(text);
      return [
        for (final result in results)
          AddressResult(
            address: result['display_name'] as String,
            location: LatLng(
              double.parse(result['lat'] as String),
              double.parse(result['lon'] as String),
            ),
          ),
      ];
    } on Object catch (error) {
      debugPrint('Address search failed: $error');
      rethrow;
    }
  }

  /// The address text at [point], or null if none. Throws if the lookup
  /// fails for a reason other than "no result".
  Future<String?> addressAt(LatLng point) async {
    try {
      return await _service.reverse(point.latitude, point.longitude);
    } on Object catch (error) {
      debugPrint('Reverse geocoding failed: $error');
      rethrow;
    }
  }
}
