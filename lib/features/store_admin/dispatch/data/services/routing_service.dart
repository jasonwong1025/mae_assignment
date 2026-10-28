import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/road_route.dart';

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService();
});

/// Finds the road route through some points with the free OSRM demo server,
/// which uses the same OpenStreetMap roads as the Dispatch map.
///
/// The demo server allows about 1 request per second, so callers should only
/// ask again when the points really change.
class RoutingService {
  static const String _host = 'router.project-osrm.org';

  /// Road route from the first point, through the others in order, to the
  /// last one.
  Future<RoadRoute> roadRoute(List<LatLng> points) async {
    // OSRM wants "longitude,latitude" pairs joined by ";".
    final path = points
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');
    final url = Uri.https(_host, '/route/v1/driving/$path', {
      'overview': 'full',
      'geometries': 'geojson',
    });
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Route lookup failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = body['routes'] as List? ?? const [];
    if (routes.isEmpty) throw Exception('No road route found');
    final route = routes.first as Map;
    final geometry = route['geometry'] as Map;
    return RoadRoute(
      points: [
        for (final pair in geometry['coordinates'] as List)
          LatLng(
            ((pair as List)[1] as num).toDouble(),
            (pair[0] as num).toDouble(),
          ),
      ],
      metres: (route['distance'] as num).toDouble(),
      seconds: (route['duration'] as num).toDouble(),
    );
  }
}
