import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/qr_scanner_page.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// Sheet where the driver scans the QR code on the bag label, or types
/// the collection code printed under it, to confirm they are collecting the
/// right order. [onScan] and [onVerify] check the code and return an
/// error message, or null if it matched.
/// Returns true if the order was verified.
///
/// This only catches picking up the wrong bag; it is not a security check.
Future<bool> showVerifyOrderSheet(
  BuildContext context, {
  required Order order,
  required Future<String?> Function(String typedCode) onVerify,
  required Future<String?> Function(String scannedCode) onScan,
}) async {
  final verified = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        _VerifyOrderSheet(order: order, onVerify: onVerify, onScan: onScan),
  );
  return verified ?? false;
}

class _VerifyOrderSheet extends StatefulWidget {
  const _VerifyOrderSheet({
    required this.order,
    required this.onVerify,
    required this.onScan,
  });

  final Order order;
  final Future<String?> Function(String typedCode) onVerify;
  final Future<String?> Function(String scannedCode) onScan;

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
      setState(() => _error = 'Type the code from the bag label.');
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

  Future<void> _scan() async {
    final code = await scanBagQrCode(context);
    if (code == null || !mounted) return;
    setState(() {
      _isChecking = true;
      _error = null;
    });
    final error = await widget.onScan(code);
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
        // Keyboard when open, otherwise the gesture bar, like the
        // pages' bottom bars.
        bottom: MediaQuery.viewInsetsOf(context).bottom > 0
            ? MediaQuery.viewInsetsOf(context).bottom
            : MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Verify the order', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Scan the QR code on the bag label for '
            '${widget.order.customerName}.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton.icon(
            onPressed: _isChecking ? null : _scan,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scan QR code'),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Or type the code under the QR code',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 ]')),
              LengthLimitingTextInputFormatter(8),
            ],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verify(),
            decoration: InputDecoration(
              labelText: 'Collection code',
              hintText: 'e.g. K7P4QA',
              prefixIcon: const Icon(Icons.password_rounded),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          OutlinedButton.icon(
            onPressed: _isChecking ? null : _verify,
            icon: _isChecking
                ? const ButtonLoadingIndicator()
                : const Icon(Icons.verified_outlined),
            label: const Text('Verify'),
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
