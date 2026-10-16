import 'dart:convert';
import 'dart:io';

Future<void> run(
  String command,
  List<String> arguments,
  String projectRoot,
) async {
  final process = await Process.start(
    command,
    arguments,
    workingDirectory: projectRoot,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  if (await process.exitCode != 0) {
    stderr.writeln('$command failed.');
    exit(1);
  }
}

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    stderr.writeln('Usage: fvm exec dart run tool/setup_firebase.dart');
    exit(2);
  }

  final projectRoot = File.fromUri(Platform.script).parent.parent.path;
  final projectId =
      (jsonDecode(
            File('$projectRoot/.firebaserc').readAsStringSync(),
          )['projects']['default']
          as String);

  try {
    await run('flutter', ['pub', 'get', '--enforce-lockfile'], projectRoot);
    await run('dart', [
      'pub',
      'global',
      'run',
      'flutterfire_cli:flutterfire',
      'configure',
      '--yes',
      '--project=$projectId',
      '--platforms=${Platform.isMacOS ? 'android,ios,web' : 'android,web'}',
      '--android-package-name=com.example.mae_assignment',
      '--ios-bundle-id=com.example.maeAssignment',
    ], projectRoot);

    final database = await Process.run(
      'firebase',
      ['firestore:databases:get', '(default)', '--project', projectId],
      workingDirectory: projectRoot,
      runInShell: Platform.isWindows,
    );
    if (database.exitCode != 0) {
      await run('gcloud', [
        'services',
        'enable',
        'firestore.googleapis.com',
        '--project',
        projectId,
      ], projectRoot);
      await run('firebase', [
        'firestore:databases:create',
        '(default)',
        '--location=asia-southeast1',
        '--project',
        projectId,
      ], projectRoot);
    }

    await run('firebase', [
      'deploy',
      '--only',
      'auth,firestore:rules',
      '--project',
      projectId,
    ], projectRoot);
    stdout.writeln(
      'Shared Firebase project is ready. Commit any updated app configuration files.',
    );
  } on ProcessException catch (error) {
    stderr.writeln(
      'Could not run ${error.executable}. Check that it is installed and on PATH.',
    );
    exit(1);
  }
}
