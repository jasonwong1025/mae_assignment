import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final addressSearchServiceProvider = Provider<AddressSearchService>((ref) {
  return AddressSearchService();
});

/// Finds places in Malaysia with OpenStreetMap's free Nominatim search.
/// Their rules: at most 1 search per second, so only search on a button
/// press, never on every key.
class AddressSearchService {
  /// Raw results: each has 'display_name', 'lat' and 'lon'.
  Future<List<Map<String, dynamic>>> search(String text) async {
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': text,
      'format': 'json',
      'countrycodes': 'my',
      'limit': '5',
    });
    final response = await http.get(
      url,
      headers: {'User-Agent': 'Grocerly student project'},
    );
    if (response.statusCode != 200) {
      throw Exception('Search failed (${response.statusCode})');
    }
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }
}
