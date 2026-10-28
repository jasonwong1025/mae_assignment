import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/dispatch_labels.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_state.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// OpenStreetMap with the branch, delivery addresses, drivers and their
/// routes. Routes follow the roads, or are straight lines while the road
/// route loads or if it cannot be found.
class DispatchMap extends ConsumerStatefulWidget {
  const DispatchMap({
    required this.state,
    required this.selectedOrderNumber,
    required this.selectedDriverId,
    required this.onOrderTap,
    required this.onDriverTap,
    super.key,
  });

  final DispatchState state;
  final int? selectedOrderNumber;
  final String? selectedDriverId;
  final ValueChanged<Order> onOrderTap;
  final ValueChanged<DispatchDriver> onDriverTap;

  @override
  ConsumerState<DispatchMap> createState() => _DispatchMapState();
}

class _DispatchMapState extends ConsumerState<DispatchMap> {
  final _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shows the branch, its deliveries and their drivers.
  CameraFit _fitBranch() {
    final state = widget.state;
    final points = [
      state.branch.location,
      for (final order in state.deliveries)
        if (order.addressLocation != null) order.addressLocation!,
      for (final driver in state.drivers)
        if (driver.order != null && driver.location != null)
          driver.location!.position,
    ];
    return CameraFit.coordinates(
      coordinates: points,
      padding: const EdgeInsets.all(64),
      maxZoom: 15,
    );
  }

  /// The road route through [points], or the straight line until it loads.
  List<LatLng> _roadOrStraight(List<LatLng> points) {
    final road = ref.watch(roadRouteProvider(RouteStops(points))).value;
    return road?.points ?? points;
  }

  void _zoomBy(double change) {
    final camera = _controller.camera;
    _controller.move(camera.center, camera.zoom + change);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    // Drivers with this branch's orders, selected one last so it is on top.
    final driversWithRoutes =
        state.drivers.where((driver) => driver.order != null).toList()..sort(
          (a, b) => (a.id == widget.selectedDriverId ? 1 : 0).compareTo(
            b.id == widget.selectedDriverId ? 1 : 0,
          ),
        );

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCameraFit: _fitBranch(),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mae_assignment',
            ),
            PolylineLayer(
              polylines: [
                for (final driver in driversWithRoutes)
                  if (driver.route.isNotEmpty)
                    Polyline(
                      points: _roadOrStraight(driver.route),
                      strokeWidth: driver.id == widget.selectedDriverId ? 5 : 3,
                      color: driver.id == widget.selectedDriverId
                          ? AppColors.darkGreen
                          : AppColors.info.withValues(alpha: 0.6),
                    ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final order in state.deliveries)
                  if (order.addressLocation != null)
                    _pin(
                      point: order.addressLocation!,
                      icon: Icons.home_rounded,
                      color: deliveryColor(order),
                      label: '#${order.number}',
                      isSelected: order.number == widget.selectedOrderNumber,
                      onTap: () => widget.onOrderTap(order),
                    ),
                _pin(
                  point: state.branch.location,
                  icon: Icons.storefront_rounded,
                  color: AppColors.darkGreen,
                  label: state.branch.name,
                  isSelected: false,
                ),
                // Offline drivers share no location.
                for (final driver in state.drivers)
                  if (!driver.isOffline)
                    _pin(
                      point: driver.location!.position,
                      icon: Icons.two_wheeler_rounded,
                      color: driverColor(driver),
                      label: driver.isFree
                          ? driver.firstName
                          : '${driver.firstName} · '
                                '#${driver.worker.currentOrderNumber}',
                      isSelected: driver.id == widget.selectedDriverId,
                      onTap: () => widget.onDriverTap(driver),
                    ),
              ],
            ),
            // OpenStreetMap asks every map to show this.
            const Align(
              alignment: Alignment.bottomRight,
              child: _Attribution(),
            ),
          ],
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              _MapButton(
                tooltip: 'Zoom in',
                icon: Icons.add_rounded,
                onPressed: () => _zoomBy(1),
              ),
              const SizedBox(height: 8),
              _MapButton(
                tooltip: 'Zoom out',
                icon: Icons.remove_rounded,
                onPressed: () => _zoomBy(-1),
              ),
              const SizedBox(height: 8),
              _MapButton(
                tooltip: 'Show whole branch',
                icon: Icons.center_focus_strong_rounded,
                onPressed: () => _controller.fitCamera(_fitBranch()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Marker _pin({
    required LatLng point,
    required IconData icon,
    required Color color,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final size = isSelected ? 40.0 : 32.0;
    return Marker(
      point: point,
      width: 140,
      // Room for the label above and below, so the circle sits on the point.
      height: size + 2 * _MapPin.labelHeight,
      child: _MapPin(
        icon: icon,
        color: color,
        label: label,
        size: size,
        isSelected: isSelected,
        onTap: onTap,
      ),
    );
  }
}

/// Coloured circle with an icon and a small label under it.
class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.icon,
    required this.color,
    required this.label,
    required this.size,
    required this.isSelected,
    this.onTap,
  });

  static const double labelHeight = 24;

  final IconData icon;
  final Color color;
  final String label;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: labelHeight),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.yellow : Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.55),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
