// Guards the layering and coding conventions that review would otherwise
// have to catch by eye. Run from the project root:
//
//   fvm dart run tool/check_architecture.dart
//
// CI runs the same script. Written in Dart (not a shell script) so it runs
// the same on macOS, Windows and Linux. The rules are explained in the
// README, section "Code conventions".

import 'dart:io';

/// One broken rule at one place in the code.
class Violation {
  const Violation(this.rule, this.file, this.line, this.detail);

  final String rule;
  final String file;
  final int line;
  final String detail;

  @override
  String toString() => '  [$rule] $file:$line  $detail';
}

/// Device-only services (no Firebase) that screens may use directly.
const Set<String> _deviceServices = {
  'camera_service.dart',
  'launcher_service.dart',
  'label_print_service.dart',
  'image_picker_service.dart',
};

final RegExp _firebaseImport = RegExp(
  r'''import\s+['"]package:(cloud_firestore|firebase_auth|firebase_core|google_sign_in)/''',
);
final RegExp _serviceImport = RegExp(
  r'''import\s+['"]package:mae_assignment/[^'"]*/services/([^'"/]+\.dart)['"]''',
);
final RegExp _classDecl = RegExp(
  r'^(?:abstract\s+|sealed\s+|final\s+|base\s+)*class\s+(\w+)',
);

String _normalise(String path) => path.replaceAll(r'\', '/');

bool _isGenerated(String path) =>
    path.endsWith('.freezed.dart') || path.endsWith('.g.dart');

bool _inPresentationOrUi(String path) =>
    path.contains('/presentation/') ||
    path.startsWith('lib/shared/ui/') ||
    path.startsWith('lib/app/');

bool _inModels(String path) =>
    path.contains('/data/models/') || path.startsWith('lib/shared/models/');

bool _inViewModels(String path) => path.contains('/presentation/view_models/');

/// True if the line before [index] (skipping doc comments, other
/// annotations and blank lines) holds `@freezed`.
bool _isFreezed(List<String> lines, int index) {
  for (var i = index - 1; i >= 0; i--) {
    final line = lines[i].trim();
    if (line.startsWith('@freezed') || line.startsWith('@Freezed')) {
      return true;
    }
    if (line.isEmpty || line.startsWith('//') || line.startsWith('@')) {
      continue;
    }
    return false;
  }
  return false;
}

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Run this from the project root (no lib/ directory here).');
    exit(2);
  }

  final violations = <Violation>[];
  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !_isGenerated(file.path));

  for (final file in files) {
    final path = _normalise(file.path);
    final lines = file.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final number = i + 1;

      // Rule 1: screens, widgets and models never touch the Firebase SDKs.
      // They talk to view models, which talk to repositories and services.
      if (_firebaseImport.hasMatch(line) &&
          (_inPresentationOrUi(path) || _inModels(path))) {
        violations.add(
          Violation(
            'layering',
            path,
            number,
            'Firebase SDK imported in '
                '${_inModels(path) ? 'a model' : 'UI code'}. '
                'Use a service in data/services and a repository.',
          ),
        );
      }

      // Rule 2: screens go through view models and repositories, never a
      // service directly (device-only services are the listed exception).
      if (_inPresentationOrUi(path)) {
        final match = _serviceImport.firstMatch(line);
        if (match != null && !_deviceServices.contains(match.group(1))) {
          violations.add(
            Violation(
              'layering',
              path,
              number,
              'UI code imports ${match.group(1)}. Go through a repository.',
            ),
          );
        }
      }

      final declaration = _classDecl.firstMatch(line);
      if (declaration == null) continue;
      final name = declaration.group(1)!;
      final isPrivate = name.startsWith('_');

      // Rule 3: data classes in models/ are Freezed (immutable, equality,
      // copyWith), so every model behaves the same way.
      if (_inModels(path) && !isPrivate && !_isFreezed(lines, i)) {
        violations.add(
          Violation(
            'model',
            path,
            number,
            '$name must be a Freezed class (@freezed). See '
                'lib/core/reference/freezed_example.dart.',
          ),
        );
      }

      // Rule 4: view-model state and filter classes are Freezed too.
      final isStateClass = name.endsWith('State') || name.endsWith('Filter');
      final extendsNotifier = line.contains('extends');
      if (_inViewModels(path) &&
          isStateClass &&
          !extendsNotifier &&
          !isPrivate &&
          !_isFreezed(lines, i)) {
        violations.add(
          Violation(
            'state',
            path,
            number,
            '$name must be a Freezed class (@freezed).',
          ),
        );
      }

      // Rule 5: every user-facing error (declared in a repository) is an
      // AppException, so the screens and the shared guard() treat them all
      // alike. Services may keep small internal exceptions that a
      // repository translates into a friendly one.
      if (path.contains('/repositories/') &&
          name.endsWith('Exception') &&
          name != 'AppException' &&
          !line.contains('extends AppException')) {
        violations.add(
          Violation(
            'errors',
            path,
            number,
            '$name must extend AppException (lib/core/errors).',
          ),
        );
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr
      ..writeln('Architecture check failed (${violations.length}):')
      ..writeln();
    violations.forEach(stderr.writeln);
    stderr
      ..writeln()
      ..writeln('See "Code conventions" in the README for the reasons.');
    exit(1);
  }

  stdout.writeln('Architecture check passed.');
}
