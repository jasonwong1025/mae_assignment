// Guards the single source of truth for Firestore paths.
//
// Every Firestore collection and document reference must go through the
// constants in lib/core/firebase/firestore_paths.dart, so a path exists in
// exactly one place and cannot drift from firestore.rules. This check fails
// if any Dart file under lib/ passes a STRING LITERAL to .collection(...)
// or .doc(...), e.g. .collection('products'). Constant or variable
// arguments (.collection(FirestoreCollections.products), .doc(uid)) are
// fine.
//
// Run locally:  fvm dart run tool/check_firestore_paths.dart
// CI runs the same script, so a violation fails the build. Written in Dart
// (not a shell script) so it runs the same on macOS, Windows and Linux.

import 'dart:io';

/// `.collection(` or `.doc(` followed by a quote = a string-literal path.
final RegExp _literalPath = RegExp(r'''\.(collection|doc)\(\s*['"]''');

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Run this from the project root (no lib/ directory here).');
    exit(2);
  }

  final violations = <String>[];
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (_literalPath.hasMatch(lines[i])) {
        // Report with a forward-slash path and 1-based line number.
        final path = file.path.replaceAll(r'\', '/');
        violations.add('$path:${i + 1}: ${lines[i].trim()}');
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr
      ..writeln(
        'Firestore path used as a string literal. Use the constants in '
        'lib/core/firebase/firestore_paths.dart (FirestoreCollections.*) '
        'instead, so paths stay in one place and match firestore.rules.',
      )
      ..writeln();
    for (final violation in violations) {
      stderr.writeln('  $violation');
    }
    exit(1);
  }

  stdout.writeln(
    'Firestore paths check passed: no literal .collection()/.doc() paths.',
  );
}
