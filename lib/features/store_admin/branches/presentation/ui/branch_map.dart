import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../app/theme/app_colors.dart';

/// Small map with a pin at [location].
/// If [onTap] is given, tapping the map moves the pin there.
class BranchMap extends StatefulWidget {
  const BranchMap({super.key, required this.location, this.onTap});

  final LatLng location;
  final ValueChanged<LatLng>? onTap;

  @override
  State<BranchMap> createState() => _BranchMapState();
}

class _BranchMapState extends State<BranchMap> {
  final _controller = MapController();

  @override
  void didUpdateWidget(BranchMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the pin when it moves, e.g. after an address search.
    if (oldWidget.location != widget.location) {
      _controller.move(widget.location, _controller.camera.zoom);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: widget.location,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: widget.onTap == null
                ? null
                : (tapPosition, point) => widget.onTap!(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mae_assignment',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.location,
                  width: 40,
                  height: 40,
                  // Bottom of the pin icon sits on the point.
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 40,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            // OpenStreetMap asks every map to show this.
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
