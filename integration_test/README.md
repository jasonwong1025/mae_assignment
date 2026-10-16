# Firebase integration tests (Layer 3, Dart)

These tests run the real `firebase_auth` and `cloud_firestore` SDKs against the
local **Firebase Emulator Suite**, so they exercise `UserService`,
`AuthService` and `AuthRepository` end to end without touching the shared
`mae-assignment-grocerly` project.

They need a running device and the emulators running. The
`--dart-define=USE_FIREBASE_EMULATOR=true` flag is what points the SDKs at the
emulators. The emulators bind to `0.0.0.0` (see `firebase.json`) so a device on
the same network can reach them.

## Run

Start the emulators in one terminal:

```bash
firebase emulators:start --only auth,firestore --project mae-assignment-grocerly
```

Then, in another terminal, run a test against a device:

```bash
# Android emulator (image): the host machine is reached on 10.0.2.2, which the
# connector picks automatically.
fvm flutter test integration_test \
  -d <android-emulator-id> \
  --dart-define=USE_FIREBASE_EMULATOR=true

# Physical Android device: it reaches the host over the LAN, so pass the host
# machine's IP. Find it with `hostname -I` (WSL) or `ip addr`.
fvm flutter test integration_test \
  -d <device-id> \
  --dart-define=USE_FIREBASE_EMULATOR=true \
  --dart-define=FIREBASE_EMULATOR_HOST=<host-lan-ip>
```

Note: a Linux/desktop runner is not configured for this project, and web
integration tests need `flutter drive` with chromedriver. The Android device
or an Android emulator image is the supported path today.

The Firestore Security Rules are tested separately and need no device; see
`test_firebase/`.
