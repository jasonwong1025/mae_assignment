// Runs the Patrol end-to-end flow on an Android emulator, fully automated so
// it works on a fresh machine for the whole team and in CI:
//   1. Checks the Firebase emulators are running on the host.
//   2. Picks the device:
//      - `--device <serial>` if given;
//      - otherwise any Android emulator already connected to adb (including
//        one running on the Windows host and attached from WSL2 with
//        `adb connect`);
//      - otherwise boots its own AVD ("grocerly_e2e"), installing the
//        emulator and a system image matching this CPU on first use.
//   3. Runs `patrol test` on it (an emulator reaches the host on 10.0.2.2).
//
// Why an emulator, not a phone: APK installs over wireless adb stall, and an
// emulator needs no network wiring to reach the host's Firebase emulators.
// Keep using a real device for everyday `flutter run`; use this for E2E.
//
// Run:  fvm dart run tool/run_e2e.dart [--verbose] [extra patrol test args]
// Written in Dart (like tool/check_firestore_paths.dart) so it runs the same
// on macOS, Windows and Linux.

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

/// The AVD this script manages. Namespaced so it never clashes with AVDs the
/// developer created themselves.
const _avdName = 'grocerly_e2e';

/// Firestore emulator port from firebase.json.
const _firestorePort = 8085;

/// Where the full, unfiltered Patrol/Gradle output is written.
const _logPath = 'build/e2e/patrol.log';

/// System image for the managed AVD: API 35 (matches targetSdk) with Google
/// APIs (Play services for Firebase). The ABI must match the host CPU: the
/// emulator cannot run x86_64 images on Apple Silicon (or other arm64
/// hosts), and arm64 images are slow on Intel/AMD.
String get _systemImage => 'system-images;android-35;google_apis;$_imageAbi';

String get _imageAbi {
  final abi = Abi.current();
  final isArm64Host =
      abi == Abi.macosArm64 || abi == Abi.linuxArm64 || abi == Abi.windowsArm64;
  return isArm64Host ? 'arm64-v8a' : 'x86_64';
}

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

  final serial = await _pickDevice(sdk, args);
  stdout.writeln('Device ready: $serial. Running the Patrol flow...');

  // Default to the customer journey flow unless the caller named a target.
  final patrolArgs = args.where((a) => a != '--verbose').toList();
  if (!patrolArgs.contains('--target')) {
    patrolArgs.insertAll(0, const [
      '--target',
      'integration_test/customer_journey_test.dart',
    ]);
  }
  if (_requestedDevice(args) == null) {
    patrolArgs.addAll(['--device', serial]);
  }

  // On an emulator the Firebase SDK maps the emulator host to 10.0.2.2
  // automatically, so we only turn the emulator mode on.
  final command = [
    'test',
    ...patrolArgs,
    '--dart-define=USE_FIREBASE_EMULATOR=true',
  ];
  exit(await _runPatrolQuietly(command, verbose: args.contains('--verbose')));
}

/// The value of `--device`/`-d` if the caller passed one, else null.
String? _requestedDevice(List<String> args) {
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--device' || args[i] == '-d') return args[i + 1];
  }
  return null;
}

/// Returns the adb serial to test on: the requested device, an emulator
/// that is already connected, or our own AVD booted for the run.
Future<String> _pickDevice(_AndroidSdk sdk, List<String> args) async {
  final requested = _requestedDevice(args);
  if (requested != null) {
    stdout.writeln('Using the requested device ($requested).');
    return requested;
  }

  final connected = await _connectedEmulator(sdk);
  if (connected != null) {
    stdout.writeln('Using the connected emulator ($connected).');
    return await _waitForBoot(sdk, timeout: _bootTimeout);
  }

  return await _bootManagedAvd(sdk);
}

/// Installs what the managed AVD needs, boots it headless, and waits until
/// Android has finished booting. Returns its adb serial.
Future<String> _bootManagedAvd(_AndroidSdk sdk) async {
  await _ensureEmulatorInstalled(sdk);
  await _ensureAvdExists(sdk);
  await _ensureKvmAccess();

  stdout.writeln(
    'Booting emulator "$_avdName" (headless). A first boot can take a few '
    'minutes; emulator output goes to $_emulatorLogPath.',
  );
  // -no-window suits CI/headless hosts; -no-snapshot gives a clean boot.
  final pid = await _startEmulatorDetached(sdk, const [
    '-avd',
    _avdName,
    '-no-window',
    '-no-snapshot',
    '-no-boot-anim',
    '-no-audio',
    '-gpu',
    'swiftshader_indirect',
  ]);

  return await _waitForBoot(sdk, emulatorPid: pid, timeout: _bootTimeout);
}

/// How long a cold boot may take. CI runners often need several minutes on
/// first boot.
const _bootTimeout = Duration(minutes: 10);

/// Where the managed emulator's own output is written.
const _emulatorLogPath = 'build/e2e/emulator.log';

/// Starts the emulator so it keeps running after this script exits (the
/// next run reuses it) and returns its pid. On macOS/Linux its output is
/// redirected to [_emulatorLogPath], so a boot failure can be explained; a
/// detached Windows process has no output to capture.
Future<int> _startEmulatorDetached(
  _AndroidSdk sdk,
  List<String> emulatorArgs,
) async {
  File(_emulatorLogPath).parent.createSync(recursive: true);
  final Process process;
  if (Platform.isWindows) {
    process = await Process.start(
      sdk.emulatorBinary,
      emulatorArgs,
      environment: sdk.avdEnvironment,
      mode: ProcessStartMode.detached,
    );
  } else {
    // `exec` replaces the shell, so the pid is the emulator's own.
    process = await Process.start(
      'sh',
      [
        '-c',
        r'log="$1"; shift; exec "$@" > "$log" 2>&1',
        'sh',
        _emulatorLogPath,
        sdk.emulatorBinary,
        ...emulatorArgs,
      ],
      environment: sdk.avdEnvironment,
      mode: ProcessStartMode.detached,
    );
  }
  return process.pid;
}

/// On Linux (including WSL2) the emulator needs hardware acceleration via
/// /dev/kvm. Granting access is a one-time privileged host change we cannot
/// do automatically, so detect it and fail fast with the exact fix rather
/// than letting the emulator crash on boot. macOS and Windows use their own
/// hypervisors and skip this check.
Future<void> _ensureKvmAccess() async {
  if (!Platform.isLinux) return;
  if (!File('/dev/kvm').existsSync()) {
    _fail(
      '/dev/kvm is missing, so the emulator cannot use hardware '
      'acceleration.\n'
      'Enable virtualization (VT-x/AMD-V) in your BIOS. On WSL2, also enable '
      'nested virtualization, or run the emulator on Windows and attach it '
      'from WSL2 (see the README).',
    );
  }
  // Check real read/write access rather than group membership, so access
  // granted by a udev rule (as in CI) also counts.
  final access = await Process.run('sh', [
    '-c',
    'test -r /dev/kvm && test -w /dev/kvm',
  ]);
  if (access.exitCode == 0) return;

  _fail(
    'Your user cannot access /dev/kvm, so the emulator cannot start.\n'
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
  final ok = await _runSdkManager(sdk, packages);
  if (!ok) _fail('Failed to install: ${packages.join(', ')}');
}

/// Creates the managed AVD if it does not already exist.
///
/// The AVD is created at an explicit `--path` inside [_AndroidSdk.avdHome],
/// and its pointer `.ini` is written there if avdmanager put it elsewhere.
/// Some avdmanager builds (e.g. on GitHub's Ubuntu 24.04 runners) ignore
/// ANDROID_AVD_HOME and follow XDG_CONFIG_HOME instead, which leaves the
/// emulator unable to find the AVD (actions/runner-images#11482).
Future<void> _ensureAvdExists(_AndroidSdk sdk) async {
  final separator = Platform.pathSeparator;
  final avdHome = sdk.avdHome;
  final iniFile = File('$avdHome$separator$_avdName.ini');
  final avdDir = Directory('$avdHome$separator$_avdName.avd');
  final configFile = File('${avdDir.path}${separator}config.ini');
  if (iniFile.existsSync() && configFile.existsSync()) return;

  stdout.writeln('Creating AVD "$_avdName" from $_systemImage...');
  Directory(avdHome).createSync(recursive: true);
  final process = await Process.start(
    sdk.avdmanager,
    [
      'create',
      'avd',
      '--name',
      _avdName,
      '--package',
      _systemImage,
      '--device',
      'pixel_6',
      '--path',
      avdDir.path,
      '--force',
    ],
    environment: sdk.avdEnvironment,
    runInShell: Platform.isWindows,
  );
  // avdmanager asks "Do you wish to create a custom hardware profile?";
  // answer "no" to take the device defaults.
  process.stdin.write('no\n');
  await process.stdin.close();
  final outFuture = process.stdout.transform(utf8.decoder).join();
  final errFuture = process.stderr.transform(utf8.decoder).join();
  final exitCode = await process.exitCode;
  final details = '${await outFuture}\n${await errFuture}'.trim();
  if (exitCode != 0) _fail('Failed to create AVD:\n$details');

  if (!configFile.existsSync()) {
    _fail(
      'avdmanager reported success but ${configFile.path} is missing.\n'
      '$details',
    );
  }
  if (!iniFile.existsSync()) {
    // avdmanager wrote the pointer file somewhere else; write our own so the
    // emulator (which reads ANDROID_AVD_HOME) can find the AVD.
    final target = _systemImage.split(';')[1];
    iniFile.writeAsStringSync(
      'avd.ini.encoding=UTF-8\n'
      'path=${avdDir.absolute.path}\n'
      'path.rel=avd$separator$_avdName.avd\n'
      'target=$target\n',
    );
  }
}

/// Serials of every device adb reports as ready.
Future<List<String>> _connectedSerials(_AndroidSdk sdk) async {
  final out = await _run(sdk.adb, ['devices']);
  return [
    for (final line in const LineSplitter().convert(out ?? ''))
      if (line.trim().split(RegExp(r'\s+')) case [final serial, 'device'])
        serial,
  ];
}

/// True for an Android emulator. Local emulators have `emulator-*` serials;
/// one attached over the network (e.g. from the Windows host into WSL2) has
/// an ip:port serial, so also check the build props every emulator sets.
Future<bool> _isEmulator(_AndroidSdk sdk, String serial) async {
  if (serial.startsWith('emulator-')) return true;
  for (final prop in const ['ro.boot.qemu', 'ro.kernel.qemu']) {
    final value = await _run(sdk.adb, ['-s', serial, 'shell', 'getprop', prop]);
    if (value?.trim() == '1') return true;
  }
  return false;
}

/// The first connected Android emulator, or null. Physical devices are
/// skipped.
Future<String?> _connectedEmulator(_AndroidSdk sdk) async {
  for (final serial in await _connectedSerials(sdk)) {
    if (await _isEmulator(sdk, serial)) return serial;
  }
  return null;
}

/// Waits until an emulator is connected and Android reports
/// `sys.boot_completed`, printing progress so a slow boot does not look
/// stuck. If [emulatorPid] is given (an emulator we started), fails early
/// when that process exits. Returns the emulator's adb serial.
Future<String> _waitForBoot(
  _AndroidSdk sdk, {
  required Duration timeout,
  int? emulatorPid,
}) async {
  final started = DateTime.now();
  final deadline = started.add(timeout);
  var nextReport = started.add(const Duration(seconds: 30));

  while (DateTime.now().isBefore(deadline)) {
    final serial = await _connectedEmulator(sdk);
    if (serial != null) {
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
        stdout.writeln(
          'Emulator booted in '
          '${DateTime.now().difference(started).inSeconds}s.',
        );
        return serial;
      }
    }

    if (emulatorPid != null && !await _isProcessAlive(emulatorPid)) {
      await _failBootWithDiagnostics(sdk, 'The emulator exited during boot.');
    }

    if (DateTime.now().isAfter(nextReport)) {
      final waited = DateTime.now().difference(started).inSeconds;
      stdout.writeln(
        'Still waiting for the emulator to boot (${waited}s, '
        '${serial == null ? 'not attached to adb yet' : 'attached as $serial'}'
        ')...',
      );
      nextReport = DateTime.now().add(const Duration(seconds: 30));
    }
    await Future<void>.delayed(const Duration(seconds: 3));
  }

  await _failBootWithDiagnostics(
    sdk,
    'The emulator did not finish booting within ${timeout.inMinutes} '
    'minutes.',
  );
}

/// True while process [pid] is running. Always true on Windows, where we
/// cannot cheaply check; the boot timeout still applies there.
Future<bool> _isProcessAlive(int pid) async {
  if (Platform.isWindows) return true;
  final result = await Process.run('kill', ['-0', '$pid']);
  return result.exitCode == 0;
}

/// Fails with [message], the end of the emulator's own output, and its
/// acceleration report, which names the missing piece (KVM, WHPX,
/// Hypervisor.framework) on every OS.
Future<Never> _failBootWithDiagnostics(_AndroidSdk sdk, String message) async {
  final logFile = File(_emulatorLogPath);
  final logTail = logFile.existsSync()
      ? (const LineSplitter()
                .convert(logFile.readAsStringSync())
                .reversed
                .take(40)
                .toList()
                .reversed)
            .join('\n')
      : '(no emulator log; it is only captured for an emulator this script '
            'started on macOS/Linux)';

  final result = await Process.run(
    sdk.emulatorBinary,
    ['-accel-check'],
    environment: sdk.avdEnvironment,
    runInShell: Platform.isWindows,
  );
  final report = '${result.stdout}${result.stderr}'.trim();

  _fail(
    '$message\n'
    '--- Last lines of $_emulatorLogPath ---\n'
    '$logTail\n'
    '--- Emulator acceleration check ---\n'
    '${report.isEmpty ? '(no output)' : report}',
  );
}

/// Runs patrol, writing everything to [_logPath] and printing only what a
/// developer needs: progress phases, test steps, the summary, and the error
/// of a failing step. Gradle/plugin warnings stay in the log file. Pass
/// `--verbose` to stream everything instead.
Future<int> _runPatrolQuietly(
  List<String> command, {
  required bool verbose,
}) async {
  final logFile = File(_logPath)..parent.createSync(recursive: true);
  final log = logFile.openWrite()..writeln('patrol ${command.join(' ')}');
  stdout
    ..writeln('Running Patrol (full log: $_logPath)')
    ..writeln(
      'First run builds and installs the app; this takes a few minutes.',
    );

  final process = await Process.start(
    'patrol',
    command,
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
Future<String?> _run(
  String executable,
  List<String> args, {
  Map<String, String>? environment,
}) async {
  try {
    final result = await Process.run(
      executable,
      args,
      environment: environment,
      runInShell: Platform.isWindows,
    );
    return result.exitCode == 0 ? result.stdout as String : null;
  } on ProcessException {
    return null;
  }
}

/// Runs sdkmanager for [packages], accepting license prompts and showing
/// its progress.
Future<bool> _runSdkManager(_AndroidSdk sdk, List<String> packages) async {
  final process = await Process.start(
    sdk.sdkmanager,
    packages,
    runInShell: Platform.isWindows,
  );
  // sdkmanager reads one "y" per license prompt.
  process.stdin.write('y\n' * 50);
  await process.stdin.close();
  // Forward output line by line. Do not use pipe(stdout): it closes our own
  // stdout when sdkmanager finishes, and the next message we print then
  // crashes the script (exit 255).
  await Future.wait([
    _forwardLines(process.stdout, stdout),
    _forwardLines(process.stderr, stderr),
  ]);
  return (await process.exitCode) == 0;
}

/// Copies [source] to [sink] line by line, leaving [sink] open.
Future<void> _forwardLines(Stream<List<int>> source, IOSink sink) {
  return source
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach(sink.writeln);
}

Never _fail(String message) {
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

  /// Pins where AVDs live, for both avdmanager and the emulator. Without
  /// it, on GitHub's Ubuntu 24.04 runners avdmanager follows XDG_CONFIG_HOME
  /// and writes AVDs to ~/.config/.android/avd, while the emulator only
  /// looks in ~/.android/avd, so it cannot find the AVD and exits at once
  /// (actions/runner-images#11482). Keeps any ANDROID_AVD_HOME the
  /// developer already set.
  Map<String, String> get avdEnvironment => {'ANDROID_AVD_HOME': avdHome};

  /// The directory holding the AVD `.ini` files the emulator reads.
  String get avdHome {
    final env = Platform.environment;
    final existing = env['ANDROID_AVD_HOME'];
    if (existing != null && existing.isNotEmpty) return existing;
    final home = env['HOME'] ?? env['USERPROFILE'] ?? '.';
    final separator = Platform.pathSeparator;
    return '$home$separator.android${separator}avd';
  }

  String get emulatorBinary => '$root/emulator/emulator$_exe';
  String get adb => '$root/platform-tools/adb$_exe';
  String get sdkmanager => '$root/cmdline-tools/latest/bin/sdkmanager$_bat';
  String get avdmanager => '$root/cmdline-tools/latest/bin/avdmanager$_bat';
}
