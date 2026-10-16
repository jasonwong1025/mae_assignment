import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/packing/data/services/label_print_service.dart';

/// Preview of the bag label, drawn from the same PDF that is printed, so
/// the packer sees exactly what will come out of the printer.
class BagLabelCard extends ConsumerStatefulWidget {
  const BagLabelCard({required this.order, super.key});

  final WorkerOrder order;

  @override
  ConsumerState<BagLabelCard> createState() => _BagLabelCardState();
}

class _BagLabelCardState extends ConsumerState<BagLabelCard> {
  late final Future<Uint8List> _image = ref
      .read(labelPrintServiceProvider)
      .previewImage(widget.order);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Same shape as the 100 x 150 mm sticker.
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: FutureBuilder<Uint8List>(
          future: _image,
          builder: (context, snapshot) {
            final image = snapshot.data;
            if (image != null) {
              return Image.memory(image, fit: BoxFit.contain);
            }
            if (snapshot.hasError) {
              // Still give the packer the number to write on the bag.
              return Center(
                child: Text(
                  '#${widget.order.number}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            );
          },
        ),
      ),
    );
  }
}
