import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

/// Where a branch is on the map, or null if unknown. Branches rarely move,
/// so this is read once per branch.
///
/// Not retried when the read fails: the map is a nicety, and a driver without
/// a connection should not trigger a loop of repeated reads.
final _branchLocationProvider = FutureProvider.autoDispose
    .family<LatLng?, String>(retry: (_, _) => null, (ref, branchId) async {
      final branches = await ref.watch(branchRepositoryProvider).getBranches();
      for (final branch in branches) {
        // A branch saved without a position reads as (0, 0).
        if (branch.id == branchId &&
            (branch.location.latitude != 0 || branch.location.longitude != 0)) {
          return branch.location;
        }
      }
      return null;
    });

/// A small map with the collection branch and the customer, and the
/// straight-line distance between them, so the driver sees at a glance
/// where they are going. Directions come from the Navigate button, which
/// opens the phone's maps app. Nothing is shown if neither place is known.
class DeliveryMapPreview extends ConsumerWidget {
  const DeliveryMapPreview({required this.order, super.key});

  final Order order;

  static const _height = 180.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(_branchLocationProvider(order.branchId)).value;
    final customer = order.addressLocation;
    final points = [?store, ?customer];
    if (points.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final metres = store != null && customer != null
        ? const Distance().as(LengthUnit.Meter, store, customer)
        : null;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _height,
            child: FlutterMap(
              // New map when the places change, so it refits to them.
              key: ValueKey(points),
              options: MapOptions(
                initialCenter: points.first,
                initialZoom: 15,
                initialCameraFit: points.length > 1
                    ? CameraFit.coordinates(
                        coordinates: points,
                        padding: const EdgeInsets.all(40),
                      )
                    : null,
                // A preview only: the Navigate button is for directions.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mae_assignment',
                ),
                if (store != null && customer != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [store, customer],
                        color: AppColors.darkGreen.withValues(alpha: 0.6),
                        strokeWidth: 3,
                        pattern: StrokePattern.dashed(segments: const [8, 6]),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (store != null)
                      Marker(
                        point: store,
                        width: 36,
                        height: 36,
                        child: const _Pin(
                          icon: Icons.storefront_rounded,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    if (customer != null)
                      Marker(
                        point: customer,
                        width: 36,
                        height: 36,
                        child: const _Pin(
                          icon: Icons.home_rounded,
                          color: AppColors.orange,
                        ),
                      ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (metres != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.straighten_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      // Not the road distance: that comes from the maps app.
                      '${Formatters.distance(metres)} from store to customer '
                      '(straight line)',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Round coloured map pin with a white icon.
class _Pin extends StatelessWidget {
  const _Pin({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
