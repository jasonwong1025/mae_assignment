// Runs the Patrol end-to-end flow against a throwaway Android emulator (AVD),
// fully automated so it works on a fresh machine for the whole team:
//   1. Locates the Android SDK.
//   2. Installs the `emulator` package and a system image if missing.
//   3. Creates a dedicated AVD ("grocerly_e2e") if missing.
//   4. Boots it (headless) and waits until it is ready.
//   5. Checks the Firebase emulators are running on the host.
//   6. Runs `patrol test` against the AVD (reaches the host on 10.0.2.2).
//
// Why an AVD, not a physical device: APK installs over wireless adb stall,
// and an AVD needs no network wiring to reach the host's Firebase emulators.
// Keep using a real device for everyday `flutter run`; use this for E2E.
//
// Run:  fvm dart run tool/run_e2e.dart [extra patrol test args]
// Written in Dart (like tool/check_firestore_paths.dart) so it runs the same
// on macOS, Windows and Linux.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// The AVD this script manages. Namespaced so it never clashes with AVDs the
/// developer created themselves.
const _avdName = 'grocerly_e2e';

/// Pinned emulator image: API 35 (matches targetSdk), Google APIs (Play
/// services for Firebase), x86_64 (fast on desktop hosts).
const _systemImage = 'system-images;android-35;google_apis;x86_64';

/// Firebase emulator ports from firebase.json (firestore, auth).
const _firestorePort = 8085;

Future<void> main(List<String> args) async {
  final sdk = _AndroidSdk.locate();
  if (sdk == null) {
    _fail(
      'Could not find the Android SDK. Set ANDROID_HOME (or ANDROID_SDK_ROOT) '
      'to your SDK path, e.g. ~/Android/Sdk.',
    );
  }

  // The Firebase emulators must be up on the host first.
  if (!await _tcpReachable('localhost', _firestorePort)) {
    _fail(
      'The Firebase emulators are not running (localhost:$_firestorePort).\n'
      'Start them, then seed, in a separate shell:\n'
      '  cd test_firebase\n'
      '  npx firebase emulators:start --only auth,firestore '
      '--project mae-assignment-grocerly\n'
      '  FIRESTORE_EMULATOR_HOST=localhost:8085 '
      'FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 '
      'node seed.mjs --with-customer',
    );
  }

  await _ensureEmulatorInstalled(sdk!);
  await _ensureAvdExists(sdk);
  final serial = await _ensureAvdRunning(sdk);

  stdout.writeln('Emulator ready: $serial. Running the Patrol flow...');

  // Default to the customer journey flow unless the caller named a target.
  final passedArgs = [...args];
  if (!passedArgs.contains('--target')) {
    passedArgs.insertAll(0, const [
      '--target',
      'integration_test/customer_journey_test.dart',
    ]);
  }
  if (!passedArgs.contains('--device') && !passedArgs.contains('-d')) {
    passedArgs.addAll(['--device', serial]);
  }

  // On an AVD the SDK maps the emulator host to 10.0.2.2 automatically, so
  // we only turn the emulator mode on.
  final command = [
    'test',
    ...passedArgs,
    '--dart-define=USE_FIREBASE_EMULATOR=true',
  ];
  exit(await _runPatrolQuietly(command, verbose: args.contains('--verbose')));
}

/// Where the full, unfiltered Patrol/Gradle output is written.
const _logPath = 'build/e2e/patrol.log';

/// Runs patrol, writing everything to [_logPath] and printing only what a
/// developer needs: progress phases, test steps, the summary, and the error
/// of a failing step. Gradle/plugin warnings stay in the log file. Pass
/// `--verbose` to stream everything instead.
Future<int> _runPatrolQuietly(
  List<String> command, {
  required bool verbose,
}) async {
  final patrolArgs = command.where((a) => a != '--verbose').toList();
  final logFile = File(_logPath)..parent.createSync(recursive: true);
  final log = logFile.openWrite()..writeln('patrol ${patrolArgs.join(' ')}');
  stdout
    ..writeln('Running Patrol (full log: $_logPath)')
    ..writeln(
      'First run builds and installs the app; this takes a few '
      'minutes.',
    );

  final process = await Process.start(
    'patrol',
    patrolArgs,
    runInShell: Platform.isWindows,
  );

  // Exception blocks can run to thousands of lines (render tree dumps), so
  // show only the first few blocks, each cut to its header and message.
  const maxErrorBlocks = 2;
  const maxLinesPerBlock = 6;
  var errorBlocks = 0;
  var errorLinesLeft = 0;

  void handle(String line) {
    log.writeln(line);
    if (verbose) {
      stdout.writeln(line);
      return;
    }
    final text = line.trimRight();
    if (text.contains('EXCEPTION CAUGHT')) {
      errorBlocks++;
      errorLinesLeft = errorBlocks <= maxErrorBlocks ? maxLinesPerBlock : 0;
      if (errorBlocks == maxErrorBlocks + 1) {
        stdout.writeln('(more errors in $_logPath)');
      }
    }
    if (errorLinesLeft > 0) {
      if (text.startsWith('When the exception was thrown')) {
        errorLinesLeft = 0;
      } else {
        errorLinesLeft--;
        stdout.writeln(text);
      }
      return;
    }
    if (_isUsefulLine(text)) stdout.writeln(text);
  }

  final done = Future.wait([
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(handle),
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(handle),
  ]);
  final code = await process.exitCode;
  await done;
  await log.close();

  stdout.writeln(
    code == 0
        ? '\nE2E passed.'
        : '\nE2E failed (exit $code). Full log: $_logPath',
  );
  return code;
}

/// Lines worth showing in the terminal. Steps in progress (⏳) are skipped;
/// only their final ✅/❌ result is shown.
bool _isUsefulLine(String text) {
  if (text.contains('⏳')) return false;
  const markers = [
    '✅', '❌', '🧪', '📝', '⏩', '📊', '⏱', // steps and summary
    '✓ ', '✗ ', '• ', // patrol phases (build, install, execute)
    'Test summary', 'Successful:', 'Failed:',
  ];
  return markers.any(text.contains);
}

/// On Linux the x86_64 emulator needs hardware acceleration via /dev/kvm,
/// which requires the user to be in the `kvm` group. This is a one-time
/// privileged host change we cannot do automatically, so detect it and fail
/// fast with the exact fix rather than letting the emulator crash on boot.
Future<void> _ensureKvmAccess() async {
  if (!Platform.isLinux) return;
  if (!File('/dev/kvm').existsSync()) {
    _fail(
      '/dev/kvm is missing. Enable virtualization (VT-x/AMD-V) in your BIOS, '
      'or run the Patrol flow on a machine/CI runner with KVM.',
    );
  }
  final groups = await _run('id', ['-nG']);
  if (groups != null && groups.split(RegExp(r'\s+')).contains('kvm')) return;

  _fail(
    'Your user cannot access /dev/kvm, so the x86_64 emulator cannot start.\n'
    'Grant KVM access once (needs sudo), then apply it to this shell:\n'
    '  sudo gpasswd -a "\$USER" kvm\n'
    '  newgrp kvm   # or log out and back in\n'
    'Then re-run this command.',
  );
}

/// Installs the `emulator` package and the system image if either is missing.
/// Licenses are auto-accepted; downloads only happen when absent.
Future<void> _ensureEmulatorInstalled(_AndroidSdk sdk) async {
  final needEmulator = !File(sdk.emulatorBinary).existsSync();
  final needImage = !Directory(
    '${sdk.root}/${_systemImage.replaceAll(';', '/')}',
  ).existsSync();

  if (!needEmulator && !needImage) return;

  final packages = <String>[
    if (needEmulator) 'emulator',
    if (needImage) _systemImage,
  ];
  stdout.writeln(
    'Installing Android packages (one-time, may download ~1GB): '
    '${packages.join(', ')}',
  );
  // `yes` pipes license acceptances to sdkmanager.
  final ok = await _runInherit(sdk.sdkmanager, packages, acceptLicenses: true);
  if (!ok) _fail('Failed to install: ${packages.join(', ')}');
}

/// Creates the managed AVD if it does not already exist.
Future<void> _ensureAvdExists(_AndroidSdk sdk) async {
  final existing = await _run(sdk.emulatorBinary, ['-list-avds']);
  final avds = const LineSplitter()
      .convert(existing ?? '')
      .map((l) => l.trim())
      .toList();
  if (avds.contains(_avdName)) return;

  stdout.writeln('Creating AVD "$_avdName" from $_systemImage...');
  final process = await Process.start(sdk.avdmanager, [
    'create',
    'avd',
    '--name',
    _avdName,
    '--package',
    _systemImage,
    '--device',
    'pixel_6',
    '--force',
  ], runInShell: Platform.isWindows);
  // avdmanager asks "Do you wish to create a custom hardware profile?";
  // answer "no" to take the device defaults.
  process.stdin.write('no\n');
  await process.stdin.close();
  final out = await process.stdout.transform(utf8.decoder).join();
  final err = await process.stderr.transform(utf8.decoder).join();
  if (await process.exitCode != 0) {
    _fail('Failed to create AVD:\n$out\n$err');
  }
}

/// Boots the AVD if it is not already running and returns its adb serial.
Future<String> _ensureAvdRunning(_AndroidSdk sdk) async {
  final already = await _runningAvdSerial(sdk);
  if (already != null) {
    stdout.writeln('Emulator already running ($already).');
    return already;
  }

  await _ensureKvmAccess();
  stdout.writeln('Booting emulator "$_avdName" (headless)...');
  // Detached: the emulator keeps running after this process; we just wait
  // for it to come up. -no-window keeps CI/headless hosts happy; -no-snapshot
  // gives a clean boot each run.
  await Process.start(sdk.emulatorBinary, [
    '-avd',
    _avdName,
    '-no-window',
    '-no-snapshot',
    '-no-boot-anim',
    '-gpu',
    'swiftshader_indirect',
  ], mode: ProcessStartMode.detached);

  // Wait for a device to attach, then for Android to finish booting.
  final serial = await _waitForDevice(sdk, const Duration(minutes: 3));
  if (serial == null) _fail('Emulator did not attach to adb in time.');
  await _waitForBootCompleted(sdk, serial!, const Duration(minutes: 3));
  return serial;
}

/// The serial of a running emulator (emulator-*), or null.
Future<String?> _runningAvdSerial(_AndroidSdk sdk) async {
  final out = await _run(sdk.adb, ['devices']);
  for (final line in const LineSplitter().convert(out ?? '')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length == 2 &&
        parts[1] == 'device' &&
        parts[0].startsWith('emulator-')) {
      return parts[0];
    }
  }
  return null;
}

/// Polls adb until an emulator serial appears or [timeout] elapses.
Future<String?> _waitForDevice(_AndroidSdk sdk, Duration timeout) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final serial = await _runningAvdSerial(sdk);
    if (serial != null) return serial;
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  return null;
}

/// Polls `getprop sys.boot_completed` until the emulator has finished booting.
Future<void> _waitForBootCompleted(
  _AndroidSdk sdk,
  String serial,
  Duration timeout,
) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final booted = await _run(sdk.adb, [
      '-s',
      serial,
      'shell',
      'getprop',
      'sys.boot_completed',
    ]);
    if (booted?.trim() == '1') {
      // Give the launcher a moment to settle after boot.
      await Future<void>.delayed(const Duration(seconds: 2));
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  _fail('Emulator booted but Android did not report boot_completed in time.');
}

/// True if a TCP connection to [host]:[port] succeeds quickly.
Future<bool> _tcpReachable(String host, int port) async {
  try {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 3),
    );
    socket.destroy();
    return true;
  } on Object {
    return false;
  }
}

/// Runs a command, returning stdout on success or null otherwise.
Future<String?> _run(String executable, List<String> args) async {
  try {
    final result = await Process.run(
      executable,
      args,
      runInShell: Platform.isWindows,
    );
    return result.exitCode == 0 ? result.stdout as String : null;
  } on ProcessException {
    return null;
  }
}

/// Runs a command with inherited stdio (so progress shows). When
/// [acceptLicenses] is set, feeds "y" repeatedly to stdin for sdkmanager.
Future<bool> _runInherit(
  String executable,
  List<String> args, {
  bool acceptLicenses = false,
}) async {
  final process = await Process.start(
    executable,
    args,
    mode: acceptLicenses
        ? ProcessStartMode.normal
        : ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  if (acceptLicenses) {
    // Accept any license prompts; sdkmanager reads one "y" per line.
    process.stdin.write('y\n' * 50);
    await process.stdin.close();
    unawaited(process.stdout.pipe(stdout));
    unawaited(process.stderr.pipe(stderr));
  }
  return (await process.exitCode) == 0;
}

void _fail(String message) {
  stderr.writeln('\n$message');
  exit(1);
}

/// Resolves the Android SDK location and the tools inside it.
class _AndroidSdk {
  _AndroidSdk(this.root);

  final String root;

  static _AndroidSdk? locate() {
    final env = Platform.environment;
    final candidates = <String?>[
      env['ANDROID_HOME'],
      env['ANDROID_SDK_ROOT'],
      if (env['HOME'] != null) '${env['HOME']}/Android/Sdk',
      if (env['HOME'] != null) '${env['HOME']}/Library/Android/sdk',
      if (env['LOCALAPPDATA'] != null) '${env['LOCALAPPDATA']}\\Android\\Sdk',
    ];
    for (final path in candidates) {
      if (path != null && path.isNotEmpty && Directory(path).existsSync()) {
        return _AndroidSdk(path);
      }
    }
    return null;
  }

  String get _exe => Platform.isWindows ? '.exe' : '';
  String get _bat => Platform.isWindows ? '.bat' : '';

  String get emulatorBinary => '$root/emulator/emulator$_exe';
  String get adb => '$root/platform-tools/adb$_exe';
  String get sdkmanager => '$root/cmdline-tools/latest/bin/sdkmanager$_bat';
  String get avdmanager => '$root/cmdline-tools/latest/bin/avdmanager$_bat';
}
