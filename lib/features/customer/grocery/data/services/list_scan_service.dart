import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final listScanServiceProvider = Provider<ListScanService>((ref) {
  return ListScanService();
});

/// Why a scan could not be done.
enum ScanProblem {
  /// This device cannot scan (the document scanner is Android only).
  unsupported,

  /// The scanner or the text reader failed.
  failed,
}

/// Thrown by [ListScanService]; a repository turns it into a message.
class ScanException implements Exception {
  const ScanException(this.problem);

  final ScanProblem problem;

  @override
  String toString() => 'ScanException($problem)';
}

/// Photographs a written list and reads its text, on the phone, with two
/// Google ML Kit parts:
/// - the document scanner: a camera screen that finds the page, takes the
///   photo by itself when the page is steady, and lets the user crop it;
/// - text recognition: reads the words in the photo (Latin script).
///
/// Nothing is uploaded: ML Kit runs on the device.
class ListScanService {
  /// The document scanner is Google Play services only, so Android.
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Opens the scanner and returns the text on the scanned pages, or null if
  /// the user closed the scanner without scanning. Throws a
  /// [ScanException] if the device cannot scan or something fails.
  Future<String?> scanText() async {
    if (!isSupported) throw const ScanException(ScanProblem.unsupported);

    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        pageLimit: 3,
        // Crop, rotate and clean-up tools are part of the scanner screen.
        isGalleryImport: true,
      ),
    );
    final recognizer = TextRecognizer();
    try {
      final DocumentScanningResult result;
      try {
        result = await scanner.scanDocument();
      } on PlatformException catch (error) {
        if (error.message == 'Operation cancelled') return null;
        debugPrint('Document scanner failed: $error');
        throw const ScanException(ScanProblem.failed);
      }
      final pages = result.images ?? const <String>[];
      if (pages.isEmpty) return null;

      final text = StringBuffer();
      for (final path in pages) {
        final recognised = await recognizer.processImage(
          InputImage.fromFilePath(path),
        );
        text.writeln(recognised.text);
      }
      return text.toString();
    } on ScanException {
      rethrow;
    } on Object catch (error) {
      debugPrint('Reading the list failed: $error');
      throw const ScanException(ScanProblem.failed);
    } finally {
      await recognizer.close();
      await scanner.close();
    }
  }
}
