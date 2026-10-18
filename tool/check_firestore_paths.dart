// Guards the single source of truth for Firestore paths.
//
// Collection names live in lib/core/firebase/firestore_paths.dart and every
// collection/document path is built in lib/core/firebase/firestore_refs.dart
// (FirestoreRefs), so a path exists in exactly one place and cannot drift
// from firestore.rules or DATABASE/FIRESTORE.md. This check fails if any
// Dart file under lib/ other than firestore_refs.dart
//   - calls .collection(...) (services use FirestoreRefs instead), or
//   - reads FirebaseFirestore.instance (services receive it through
//     firebaseFirestoreProvider), or
//   - passes a STRING LITERAL to .doc(...), e.g. .doc('abc'). Variables and
//     constants (.doc(uid), .doc(CounterDocs.orders)) are fine.
//
// Run locally:  fvm dart run tool/check_firestore_paths.dart
// CI runs the same script, so a violation fails the build. Written in Dart
// (not a shell script) so it runs the same on macOS, Windows and Linux.

import 'dart:io';

/// `.collection(` or `.doc(` followed by a quote = a string-literal path.
final RegExp _literalPath = RegExp(r'''\.(collection|doc)\(\s*['"]''');

/// Any `.collection(` call: only FirestoreRefs may build collection paths.
final RegExp _collectionCall = RegExp(r'\.collection\(');

/// The real Firestore instance is read in one place.
final RegExp _instanceUse = RegExp(r'FirebaseFirestore\.instance');

/// The only file allowed to build paths and read the Firestore instance.
const String _refsFile = 'lib/core/firebase/firestore_refs.dart';

/// Reads the emulator wiring, which must reach the instance directly.
const String _emulatorFile = 'lib/core/firebase/firebase_emulators.dart';

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
    // Report with a forward-slash path and 1-based line number.
    final path = file.path.replaceAll(r'\', '/');
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      final isRefs = path == _refsFile;
      final problem = _literalPath.hasMatch(line)
          ? 'string-literal path'
          : (!isRefs && _collectionCall.hasMatch(line))
          ? '.collection() outside FirestoreRefs'
          : (!isRefs && path != _emulatorFile && _instanceUse.hasMatch(line))
          ? 'FirebaseFirestore.instance outside firestore_refs.dart'
          : null;
      if (problem != null) {
        violations.add('$path:${i + 1}: $problem: ${line.trim()}');
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr
      ..writeln(
        'Firestore paths must be built in FirestoreRefs '
        '(lib/core/firebase/firestore_refs.dart) from the names in '
        'firestore_paths.dart, so they stay in one place and match '
        'firestore.rules and DATABASE/FIRESTORE.md.',
      )
      ..writeln();
    for (final violation in violations) {
      stderr.writeln('  $violation');
    }
    exit(1);
  }

  stdout.writeln('Firestore paths check passed.');
}
