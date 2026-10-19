import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Opens the camera full screen and returns the first QR code it reads,
/// or null if the person goes back. [title] heads the page and [hint] tells
/// them what to point at.
Future<String?> scanQrCode(
  BuildContext context, {
  required String title,
  required String hint,
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _QrScannerPage(title: title, hint: hint),
    ),
  );
}

/// Scans the QR code on a bag label (the driver collecting a bag).
Future<String?> scanBagQrCode(BuildContext context) {
  return scanQrCode(
    context,
    title: 'Scan bag label',
    hint: 'Point the camera at the QR code on the bag label.',
  );
}

/// How screens open the camera. A provider, so tests can answer with a
/// fixed code instead of opening a camera.
final qrScannerProvider =
    Provider<
      Future<String?> Function(
        BuildContext context, {
        required String title,
        required String hint,
      })
    >((ref) => scanQrCode);

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        _done = true;
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Torch',
            onPressed: _controller.toggleTorch,
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'The camera could not be opened. Go back and type the '
                  'collection code under the QR code instead.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Frame to aim at the QR code on the label.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.xl * 2,
            child: Text(
              widget.hint,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
