import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/camera_service.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/expandable_photo.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// Asks for a photo of the delivery before the order is marked
/// delivered. Returns the photo, or null if the driver closes the sheet.
Future<Uint8List?> showProofOfDeliverySheet(
  BuildContext context, {
  required Order order,
}) {
  return showModalBottomSheet<Uint8List>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (sheetContext) => _ProofOfDeliverySheet(order: order),
  );
}

class _ProofOfDeliverySheet extends ConsumerStatefulWidget {
  const _ProofOfDeliverySheet({required this.order});

  final Order order;

  @override
  ConsumerState<_ProofOfDeliverySheet> createState() =>
      _ProofOfDeliverySheetState();
}

class _ProofOfDeliverySheetState extends ConsumerState<_ProofOfDeliverySheet> {
  Uint8List? _photo;
  bool _isOpeningCamera = false;

  Future<void> _takePhoto() async {
    setState(() => _isOpeningCamera = true);
    try {
      final photo = await ref.read(cameraServiceProvider).takePhoto();
      if (!mounted) return;
      setState(() {
        if (photo != null) _photo = photo;
        _isOpeningCamera = false;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _isOpeningCamera = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The camera could not be opened. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photo = _photo;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle in the middle, close (X) in the top-right corner,
          // like the packing review sheet.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.s,
              0,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Proof of delivery', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.l),
                  if (photo == null)
                    _PhotoPlaceholder(
                      isBusy: _isOpeningCamera,
                      onTap: _takePhoto,
                    )
                  else ...[
                    ExpandablePhoto(image: MemoryImage(photo)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _isOpeningCamera ? null : _takePhoto,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retake'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: photo == null
                        ? null
                        : () => Navigator.of(context).pop<Uint8List>(photo),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('Mark delivered'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed-looking empty box that opens the camera.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.greenTint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Center(
            child: isBusy
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        size: 40,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        'Take photo',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
