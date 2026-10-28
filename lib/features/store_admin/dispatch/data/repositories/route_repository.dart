import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/road_route.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/routing_service.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(ref.watch(routingServiceProvider));
});

/// Road routes for the Dispatch map and table.
class RouteRepository {
  RouteRepository(this._routing);

  final RoutingService _routing;

  /// Road route through [points] in order, or null if it cannot be found
  /// (no connection, the free server is busy, or no road between them).
  Future<RoadRoute?> roadRoute(List<LatLng> points) async {
    if (points.length < 2) return null;
    try {
      return await _routing.roadRoute(points);
    } on Object {
      return null;
    }
  }
}
