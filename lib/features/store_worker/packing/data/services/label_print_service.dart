import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

final labelPrintServiceProvider = Provider<LabelPrintService>((ref) {
  return LabelPrintService();
});

/// The bag label, laid out like a courier shipping label: a 100 x 150 mm
/// sticker (the common 4 x 6 inch size) with a barcode, sender and
/// recipient boxes, and the QR code the driver scans to verify the bag.
///
/// Printing opens the phone's print dialog, so any printer the phone can
/// reach works, and "Save as PDF" when there is none.
class LabelPrintService {
  static const labelFormat = PdfPageFormat(
    100 * PdfPageFormat.mm,
    150 * PdfPageFormat.mm,
    marginAll: 4 * PdfPageFormat.mm,
  );

  pw.MemoryImage? _logo;
  pw.ThemeData? _theme;

  /// Returns false if the packer cancelled or nothing could print.
  Future<bool> printLabel(WorkerOrder order) {
    return Printing.layoutPdf(
      name: 'Grocerly label #${order.number}',
      format: labelFormat,
      onLayout: (_) => buildLabel(order),
    );
  }

  /// The label as a picture, for showing it on screen exactly as printed.
  /// Fails after a few seconds instead of waiting forever if the
  /// printing plugin cannot draw it.
  Future<Uint8List> previewImage(WorkerOrder order) async {
    final pdf = await buildLabel(order);
    final page = await Printing.raster(
      pdf,
      dpi: 200,
    ).first.timeout(const Duration(seconds: 8));
    return await page.toPng();
  }

  /// The label as a PDF document.
  Future<Uint8List> buildLabel(WorkerOrder order) async {
    _logo ??= pw.MemoryImage(
      (await rootBundle.load('assets/logo/logo.png')).buffer.asUint8List(),
    );
    // The app's Nunito font, which also covers characters the built-in
    // PDF fonts cannot print.
    _theme ??= pw.ThemeData.withFont(
      base: pw.Font.ttf(
        await rootBundle.load('assets/fonts/Nunito-Regular.ttf'),
      ),
      bold: pw.Font.ttf(await rootBundle.load('assets/fonts/Nunito-Bold.ttf')),
    );
    final logo = _logo!;
    final doc = pw.Document(title: 'Order #${order.number}', theme: _theme)
      ..addPage(
        pw.Page(
          pageFormat: labelFormat,
          build: (context) => _label(order, logo),
        ),
      );
    return await doc.save();
  }

  // -------------------------------------------------------------------
  // Layout
  // -------------------------------------------------------------------

  static const _line = pw.BorderSide();

  pw.Widget _label(WorkerOrder order, pw.MemoryImage logo) {
    final dueAt = order.dueAt;
    final kind = order.isDelivery ? 'DELIVERY' : 'PICKUP';
    final postcode = _postcode(order.isDelivery ? order.address : null);
    final recipientAddress = order.isDelivery
        ? (order.address ?? '-')
        : 'Self-pickup at Grocerly ${order.branchName}';

    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Brand and barcode.
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: _line),
            ),
            child: pw.Row(
              children: [
                pw.Image(logo, height: 26),
                pw.SizedBox(width: 4),
                pw.Text(
                  'Grocerly',
                  style: const pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Spacer(),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: 'GRC${order.number}',
                  width: 40 * PdfPageFormat.mm,
                  height: 13 * PdfPageFormat.mm,
                  textStyle: const pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Order details and service type. Not stretched: in an unbounded
          // column a stretched row takes all the space. Order details is
          // the taller box, so its right line still runs the full height.
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: _line),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: _box(
                    'Order details',
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _field('Order no.', '#${order.number}', bold: true),
                        _field('Placed', Formatters.date(order.placedAt)),
                        _field('Items', '${order.itemCount}'),
                        if (dueAt != null)
                          _field(
                            order.isDelivery ? 'Deliver by' : 'Pickup by',
                            Formatters.time(dueAt),
                          ),
                      ],
                    ),
                    rightLine: true,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _box(
                    'Service',
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          kind,
                          style: const pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          order.isDelivery
                              ? 'Driver: ${order.driverName ?? '-'}'
                              : 'Collect at counter',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sender and recipient on the left, routing and QR on the right.
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: _line),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: _line),
                          ),
                          child: _box(
                            'Sender (From)',
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _field('Name', 'Grocerly ${order.branchName}'),
                                if (order.branchAddress != null)
                                  _field('Address', order.branchAddress!),
                              ],
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: _box(
                            'Recipient (To)',
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _field('Name', order.customerName, bold: true),
                                _field('Phone', order.customerPhone),
                                _field('Address', recipientAddress),
                                if (order.customerNote != null)
                                  _field('Note', order.customerNote!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          order.branchId.toUpperCase(),
                          style: const pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Divider(height: 8),
                        pw.Text(
                          postcode ?? kind,
                          style: pw.TextStyle(
                            fontSize: postcode == null ? 14 : 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Spacer(),
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: order.qrPayload,
                          width: 30 * PdfPageFormat.mm,
                          height: 30 * PdfPageFormat.mm,
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Scan to verify, or enter code',
                          style: const pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.8),
                          ),
                          child: pw.Text(
                            order.collectionCode,
                            style: const pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        pw.Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Big order number, readable from a distance on the shelf.
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: const pw.BoxDecoration(border: pw.Border(top: _line)),
            child: pw.Center(
              child: pw.Text(
                '#${order.number}',
                style: const pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A titled section of the label.
  pw.Widget _box(String title, pw.Widget child, {bool rightLine = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: rightLine
          ? const pw.BoxDecoration(border: pw.Border(right: _line))
          : null,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          child,
        ],
      ),
    );
  }

  /// "Label   value" on one row, the value wrapping under itself.
  pw.Widget _field(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 15 * PdfPageFormat.mm,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 7)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The 5-digit Malaysian postcode in [address], for sorting bags.
  static String? _postcode(String? address) {
    if (address == null) return null;
    return RegExp(r'\b\d{5}\b').firstMatch(address)?.group(0);
  }
}
