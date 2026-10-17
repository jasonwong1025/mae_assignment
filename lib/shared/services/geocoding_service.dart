import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// Finds places in Malaysia with OpenStreetMap's free Nominatim service,
/// and names the place at a map point (reverse geocoding).
///
/// Nominatim's usage policy allows at most 1 request per second and asks
/// for a descriptive User-Agent, so callers must only search on a button
/// press (never on every key) and keep this the single client.
class GeocodingService {
  static const String _host = 'nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'Grocerly student project',
  };

  /// Forward search: text -> up to 5 candidates. Each raw result has
  /// 'display_name', 'lat' and 'lon'.
  Future<List<Map<String, dynamic>>> search(String text) async {
    final url = Uri.https(_host, '/search', {
      'q': text,
      'format': 'json',
      'countrycodes': 'my',
      'limit': '5',
    });
    final response = await http.get(url, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Search failed (${response.statusCode})');
    }
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  /// Reverse geocoding: a map point -> the address text there, or null if
  /// the service has no name for it. Used when the customer drops the pin.
  Future<String?> reverse(double latitude, double longitude) async {
    final url = Uri.https(_host, '/reverse', {
      'lat': '$latitude',
      'lon': '$longitude',
      'format': 'json',
    });
    final response = await http.get(url, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Reverse lookup failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['display_name'] as String?;
  }
}
