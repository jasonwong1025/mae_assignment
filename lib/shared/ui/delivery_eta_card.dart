import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/shared/models/delivery_eta.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// Where a delivery is and when it should arrive, for the customer and the
/// admin. Shows nothing unless the order is a delivery on the road.
///
/// The estimate is rough (see [DeliveryEta]), so it is worded "about". With
/// [showMap] the driver and the drop-off are drawn on a small map.
class DeliveryEtaCard extends StatelessWidget {
  const DeliveryEtaCard({
    required this.order,
    super.key,
    this.showMap = false,
    this.now,
  });

  final Order order;
  final bool showMap;

  /// The time to measure from; defaults to the current time. Tests set it.
  final DateTime? now;

  /// True if [order] is on the road, so the card has something to say.
  static bool isShownFor(Order order) {
    return order.isDelivery && order.status == OrderStatus.outForDelivery;
  }

  @override
  Widget build(BuildContext context) {
    if (!isShownFor(order)) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final eta = order.etaAt(now ?? DateTime.now());
    final driver = order.driverName;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.darkGreen,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  eta == null
                      ? 'On the way'
                      : 'About ${Formatters.minutes(eta.remaining.inMinutes)} '
                            'away',
                  style: textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(_detail(eta, driver), style: textTheme.bodyMedium),
          if (eta != null && eta.isStale) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Last seen ${Formatters.minutes(eta.positionAge.inMinutes)} ago. '
              'The driver may be out of signal.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ],
          if (showMap &&
              order.driverPosition != null &&
              order.addressLocation != null) ...[
            const SizedBox(height: AppSpacing.m),
            _RouteMap(
              driver: order.driverPosition!,
              destination: order.addressLocation!,
            ),
          ],
        ],
      ),
    );
  }

  static String _detail(DeliveryEta? eta, String? driver) {
    final who = driver ?? 'Your driver';
    if (eta == null) {
      return '$who has your order. The arrival time appears once their '
          'location is shared.';
    }
    final km = Formatters.distance(eta.distanceKm * 1000);
    return '$who is about $km away. Arriving around '
        '${Formatters.time(eta.arrivalAt)}.';
  }
}

/// The driver and the drop-off, framed so both are visible.
class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.driver, required this.destination});

  final LatLng driver;
  final LatLng destination;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          // A new key re-frames the map whenever the driver moves.
          key: ValueKey('$driver-$destination'),
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: [driver, destination],
              padding: const EdgeInsets.all(48),
              maxZoom: 16,
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mae_assignment',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: destination,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.home_rounded,
                    size: 36,
                    color: AppColors.darkGreen,
                  ),
                ),
                Marker(
                  point: driver,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 32,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: ColoredBox(
                color: Colors.white70,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
