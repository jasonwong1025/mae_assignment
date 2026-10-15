import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/ui/button_loading_indicator.dart';
import '../../../orders/data/models/worker_order.dart';

/// Sheet where the driver types the order number printed on the bag, to
/// confirm they are collecting the right order. [onVerify] checks it and
/// returns an error message, or null if it matched.
/// Returns true if the order was verified.
///
/// This only catches picking up the wrong bag; it is not a security check.
Future<bool> showVerifyOrderSheet(
  BuildContext context, {
  required WorkerOrder order,
  required Future<String?> Function(String typedNumber) onVerify,
}) async {
  final verified = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _VerifyOrderSheet(order: order, onVerify: onVerify),
  );
  return verified ?? false;
}

class _VerifyOrderSheet extends StatefulWidget {
  const _VerifyOrderSheet({required this.order, required this.onVerify});

  final WorkerOrder order;
  final Future<String?> Function(String typedNumber) onVerify;

  @override
  State<_VerifyOrderSheet> createState() => _VerifyOrderSheetState();
}

class _VerifyOrderSheetState extends State<_VerifyOrderSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _isChecking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Type the order number from the bag.');
      return;
    }
    setState(() {
      _isChecking = true;
      _error = null;
    });
    final error = await widget.onVerify(_controller.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isChecking = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Keep the field and button above the keyboard.
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Verify the order', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Type the order number printed on the bag label for '
            '${widget.order.customerName}.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9#]'))],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verify(),
            decoration: InputDecoration(
              labelText: 'Order number on the bag',
              hintText: 'e.g. 2308',
              prefixIcon: const Icon(Icons.tag_rounded),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton(
            onPressed: _isChecking ? null : _verify,
            child: _isChecking
                ? const ButtonLoadingIndicator()
                : const Text('Verify'),
          ),
          const SizedBox(height: AppSpacing.s),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
