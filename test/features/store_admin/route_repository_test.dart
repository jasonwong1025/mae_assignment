import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/road_route.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/repositories/route_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/routing_service.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_view_model.dart';

/// Answers with a fixed route, or throws when [fails] is set.
class _FakeRoutingService extends RoutingService {
  bool fails = false;
  int calls = 0;

  @override
  Future<RoadRoute> roadRoute(List<LatLng> points) async {
    calls++;
    if (fails) throw Exception('server busy');
    return RoadRoute(points: points, metres: 2400, seconds: 330);
  }
}

void main() {
  const branch = LatLng(3.0738, 101.5895);
  const customer = LatLng(3.0812, 101.6015);

  late _FakeRoutingService routing;
  late RouteRepository repository;

  setUp(() {
    routing = _FakeRoutingService();
    repository = RouteRepository(routing);
  });

  test('returns the road route with its distance and time', () async {
    final route = await repository.roadRoute([branch, customer]);

    expect(route!.metres, 2400);
    expect(route.minutes, 6);
  });

  test('returns null when the routing service fails', () async {
    routing.fails = true;

    expect(await repository.roadRoute([branch, customer]), isNull);
  });

  test('does not ask the service for a single point', () async {
    expect(await repository.roadRoute([branch]), isNull);
    expect(routing.calls, 0);
  });

  test('stops a few metres apart count as the same route', () {
    const moved = LatLng(3.07381, 101.58952);

    expect(
      RouteStops(const [branch, customer]),
      RouteStops(const [moved, customer]),
    );
    expect(
      RouteStops(const [branch, customer]),
      isNot(RouteStops(const [customer, branch])),
    );
  });
}
