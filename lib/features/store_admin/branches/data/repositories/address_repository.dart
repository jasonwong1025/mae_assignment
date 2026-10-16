import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:mae_assignment/features/store_admin/branches/data/services/address_search_service.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(addressSearchServiceProvider));
});

/// One search result: a full address and where it is.
class AddressResult {
  const AddressResult({required this.address, required this.location});

  final String address;
  final LatLng location;
}

/// Turns typed addresses into map locations.
class AddressRepository {
  AddressRepository(this._service);

  final AddressSearchService _service;

  /// Up to 5 matches. Throws if the search fails.
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
    } catch (error) {
      debugPrint('Address search failed: $error');
      rethrow;
    }
  }
}
