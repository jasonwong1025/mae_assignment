// Runs a Patrol end-to-end flow against the Firebase emulators, wiring the
// device to the host's emulators automatically so nobody edits a define:
//   - Android AVD (emulator): reaches the host on 10.0.2.2 (built in).
//   - Physical device:        `adb reverse` tunnels the emulator ports over
//                              the adb connection, so the app reaches them on
//                              localhost. This works regardless of Wi-Fi /
//                              router isolation, unlike a LAN-ip approach.
//
// Run:  fvm dart run tool/run_e2e.dart [extra patrol test args]
// Defaults to the customer journey flow when no --target is given.
//
// Prerequisites: emulators running and seeded (see the README), and one
// device connected (`adb devices`). Written in Dart (not a shell script) so
// it runs the same on macOS, Windows and Linux.

import 'dart:convert';
import 'dart:io';

/// Emulator ports from firebase.json (firestore, auth).
const _emulatorPorts = [8085, 9099];

Future<void> main(List<String> args) async {
  final serial = await _connectedDeviceSerial();
  if (serial == null) {
    stderr.writeln(
      'No connected device. Start an emulator or plug in a device '
      '(check with `adb devices`).',
    );
    exit(1);
  }

  // The emulators must be up on the host before the device can use them.
  if (!await _emulatorReachable('localhost', 8085)) {
    stderr.writeln(
      '\nThe Firestore emulator is not running on this host (localhost:8085).'
      '\nStart it, then re-seed (emulator data is cleared on restart):\n'
      '  cd test_firebase\n'
      '  npx firebase emulators:start --only auth,firestore '
      '--project mae-assignment-grocerly\n'
      '  FIRESTORE_EMULATOR_HOST=localhost:8085 '
      'FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 '
      'node seed.mjs --with-customer',
    );
    exit(1);
  }

  final defines = <String>['--dart-define=USE_FIREBASE_EMULATOR=true'];

  if (await _isAndroidEmulator(serial)) {
    stdout.writeln(
      'Target: Android emulator ($serial); emulators reachable on 10.0.2.2.',
    );
  } else {
    // Physical device: tunnel the emulator ports over adb so the app can
    // reach them on localhost. More reliable than a LAN ip, which fails
    // under Wi-Fi client isolation or when the device is on another subnet.
    stdout.writeln(
      'Target: physical device ($serial); tunnelling emulator ports with '
      'adb reverse.',
    );
    for (final port in _emulatorPorts) {
      final ok = await _run('adb', [
        '-s',
        serial,
        'reverse',
        'tcp:$port',
        'tcp:$port',
      ]);
      if (ok == null) {
        stderr.writeln(
          'adb reverse failed for port $port. Is the device authorised '
          'for USB debugging?',
        );
        exit(1);
      }
    }
    // With the tunnel, the app reaches the emulators on the device's own
    // loopback rather than 10.0.2.2 (the AVD default). Setting the host
    // explicitly also disables the SDK's localhost -> 10.0.2.2 remap (see
    // FirebaseEmulators.connect), which would otherwise defeat the tunnel.
    defines.add('--dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1');
  }

  // Default to the customer journey flow unless the caller named a target.
  final passedArgs = [...args];
  if (!passedArgs.contains('--target')) {
    passedArgs.insertAll(0, const [
      '--target',
      'integration_test/customer_journey_test.dart',
    ]);
  }

  // Target the detected device explicitly, so patrol never stops to ask
  // when more than one device (e.g. Chrome) is available.
  if (!passedArgs.contains('--device') && !passedArgs.contains('-d')) {
    passedArgs.addAll(['--device', serial]);
  }

  final command = ['test', ...passedArgs, ...defines];
  stdout.writeln('patrol ${command.join(' ')}');

  final process = await Process.start(
    'patrol',
    command,
    mode: ProcessStartMode.inheritStdio,
  );
  exit(await process.exitCode);
}

/// The first fully-connected device serial from `adb devices`, or null.
Future<String?> _connectedDeviceSerial() async {
  final result = await _run('adb', ['devices']);
  if (result == null) return null;
  for (final line in const LineSplitter().convert(result)) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length == 2 && parts[1] == 'device') return parts[0];
  }
  return null;
}

/// True for an Android emulator (AVD). AVD serials look like
/// `emulator-5554`, and AVDs set the `ro.kernel.qemu` build prop to 1.
Future<bool> _isAndroidEmulator(String serial) async {
  if (serial.startsWith('emulator-')) return true;
  final qemu = await _run('adb', [
    '-s',
    serial,
    'shell',
    'getprop',
    'ro.kernel.qemu',
  ]);
  return qemu?.trim() == '1';
}

/// True if a TCP connection to [host]:[port] succeeds within a short window.
Future<bool> _emulatorReachable(String host, int port) async {
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

/// Runs a command and returns stdout, or null if it could not be launched
/// or exited non-zero.
Future<String?> _run(String executable, List<String> args) async {
  try {
    final result = await Process.run(executable, args);
    return result.exitCode == 0 ? result.stdout as String : null;
  } on ProcessException {
    return null;
  }
}
