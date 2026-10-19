import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/packing/data/services/label_print_service.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/bag_label_card.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// Opens the bag label on its own screen, for a packer who did not print
/// it straight after packing or needs a new one. Any packer at the branch
/// can open it while the order is waiting to be collected.
Future<void> showBagLabelScreen(BuildContext context, Order order) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => _BagLabelScreen(order: order),
    ),
  );
}

class _BagLabelScreen extends ConsumerStatefulWidget {
  const _BagLabelScreen({required this.order});

  final Order order;

  @override
  ConsumerState<_BagLabelScreen> createState() => _BagLabelScreenState();
}

class _BagLabelScreenState extends ConsumerState<_BagLabelScreen> {
  bool _isPrinting = false;

  Future<void> _print() async {
    setState(() => _isPrinting = true);
    try {
      await ref.read(labelPrintServiceProvider).printLabel(widget.order);
    } on Object catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The label could not be printed. Write the order number on '
              'the bag instead.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Bag label #${widget.order.number}'),
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: BagLabelCard(order: widget.order)),
                ),
              ),
            ),
            BottomActionBar(
              children: [
                FilledButton.icon(
                  onPressed: _isPrinting ? null : _print,
                  icon: _isPrinting
                      ? const ButtonLoadingIndicator()
                      : const Icon(Icons.print_outlined),
                  label: const Text('Print label'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
