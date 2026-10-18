# Grocerly

Flutter app for grocery ordering and fulfilment. The customer app supports
onboarding, account access, catalogue browsing and checkout; the worker and
admin order flows are still sample-backed.

## Team setup

The app uses the shared Firebase project `mae-assignment-grocerly`. Its Firebase app configuration is committed to this repository, so teammates do not need Firebase CLI access or their own Firebase projects to run the app. Test accounts and Firestore data are shared.

Install Flutter and [FVM](https://fvm.app/documentation/getting-started/installation). In a terminal (PowerShell on Windows), run `dart pub global activate fvm` once. Then, from this repository:

```bash
fvm use
fvm flutter pub get --enforce-lockfile
fvm flutter devices
fvm flutter run -d <device-id>
```

`.fvmrc` pins Flutter 3.47.6, and `pubspec.lock` pins package versions. FVM downloads the project SDK and configures VS Code. The **Grocerly** VS Code launch configuration also works after `fvm use`. If Android SDK licenses are missing, run `fvm flutter doctor --android-licenses` once.

Android and Web are configured for the shared project. The iOS Firebase app still needs configuration on a Mac before iOS can run. The Windows desktop runner is not configured; Windows teammates can run the Android app from Windows.

## Firebase maintenance

Only a maintainer who changes Firebase apps, Authentication, or Firestore rules needs the [Firebase CLI](https://firebase.google.com/docs/cli), [Google Cloud CLI](https://docs.cloud.google.com/sdk/docs/install), and FlutterFire CLI. Sign in to an account with access to `mae-assignment-grocerly`, then run:

```bash
firebase login
gcloud auth login
dart pub global activate flutterfire_cli
fvm exec dart run tool/setup_firebase.dart
```

The script uses the project ID in `.firebaserc`. It reuses existing Firebase apps and the Firestore database, configures Android and Web, also configures iOS on macOS, enables email/password sign-in, and deploys `firestore.rules`. Commit any updated `firebase.json`, `lib/firebase_options.dart`, platform configuration files, and rules after reviewing them. Firebase and Google Cloud login credentials stay in each maintainer's home directory.

When paid services are needed, the project owner should check the [Billing Credits page](https://console.cloud.google.com/billing/credits) for an available balance, expiry date, and eligible services on the chosen account. Then link that account:

```bash
gcloud billing accounts list
gcloud billing projects link mae-assignment-grocerly --billing-account=<credits-billing-account-id>
```

Linking a Cloud Billing account upgrades the Firebase project to Blaze. Set a project budget; [budget alerts do not cap spending](https://docs.cloud.google.com/billing/docs/how-to/budgets). Teammates who only run the app do not need billing access. Members who need console or deployment access require their own project IAM permissions.

If linking fails with `Cloud billing quota exceeded`, request more [billing account project quota](https://support.google.com/code/contact/billing_quota_increase) for that account before retrying. A closed billing account cannot enable billing for the project.

## Tests

Testing has three layers, following the test pyramid: most coverage is in fast,
device-free tests; the emulator and device layers are used only where they are
genuinely needed. The first two layers need no device and run the same way on
macOS, Windows and Linux.

### 1. Unit and widget tests (`flutter_test`)

```bash
fvm flutter test
```

Run in the Dart VM: no device, emulator or network. They cover view models,
repositories, policies, validators, and widgets. Two styles of test double are
used: `mocktail` to stub and verify collaborators (view-model and repository
tests), and the in-memory fakes `firebase_auth_mocks` and `fake_cloud_firestore`
for backend logic that uses Firebase (`AuthService`, `UserService`,
`AuthRepository`). Change `.fvmrc`, the Flutter constraint in `pubspec.yaml`,
and `pubspec.lock` together when the team intentionally upgrades Flutter.

### 2. Firestore Security Rules tests (Firebase Emulator Suite)

The real `firestore.rules` cannot be faked, so they are tested against the
Firestore emulator with `@firebase/rules-unit-testing`. The emulator starts and
stops itself; this needs Node and Java (both expected by the Firebase CLI) but
no device, and works the same on every OS. Emulator ports live in the
`emulators` block of `firebase.json`.

```bash
cd test_firebase
npm install          # first time only
npm test             # starts the emulator, runs the tests, shuts it down
```

### 3. End-to-end tests (Patrol, Android emulator + Firebase emulators)

[Patrol](https://patrol.leancode.co) drives the real app on an Android
emulator against the Firebase emulators, including native UI. This is the
slow layer, kept to a few whole-journey checks. Tests live in `patrol_test/`
(Patrol's default folder); the first is the customer order journey
(`customer_journey_test.dart`): sign in, browse, add to cart, open the product
details, restart the app and find the saved cart restored, place a delivery
order, and track it. The seed script empties the test customer's saved cart, so
re-run it before each local run. The native runner lives in `android/app/src/androidTest/`.

The app only talks to the emulators when started with
`--dart-define=USE_FIREBASE_EMULATOR=true`; normal and release builds use the
real backend. An Android emulator reaches the host's Firebase emulators on
`10.0.2.2` with no network setup.

One-time setup:

- Install the Patrol CLI pinned to the `patrol` package
  ([compatibility table](https://patrol.leancode.co/documentation/compatibility-table)):
  `dart pub global activate patrol_cli 4.8.0`.
- Create an Android emulator (API 35, x86_64, or arm64 on Apple Silicon) in
  Android Studio's **Device Manager**. Hardware acceleration is required: on
  Linux/WSL2 add yourself to the `kvm` group (`sudo gpasswd -a "$USER" kvm`,
  then log in again); on Windows enable *Windows Hypervisor Platform*; macOS
  needs nothing. See
  [Configure hardware acceleration](https://developer.android.com/studio/run/emulator-acceleration).

Each run:

```bash
# 1. Start the Firebase emulators (Auth + Firestore).
cd test_firebase
npx firebase emulators:start --only auth,firestore --project mae-assignment-grocerly

# 2. In another shell, seed the catalogue and a test customer (refused
#    against the real project).
cd test_firebase
FIRESTORE_EMULATOR_HOST=localhost:8085 \
FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
node seed.mjs --with-customer

# 3. Start your Android emulator (Device Manager, or:
#    fvm flutter emulators --launch <id>), then run every test in patrol_test/.
#    Add --device <id> if a phone is also connected (see `fvm flutter devices`).
patrol test --dart-define=USE_FIREBASE_EMULATOR=true
```

Use an emulator for E2E and keep your phone for everyday `fvm flutter run`.
Patrol uninstalls the app after each run. It generates
`patrol_test/test_bundle.dart`, which is git-ignored and must not be
committed.

## Code generation

New immutable models and sealed view-model states use
[Freezed](https://pub.dev/packages/freezed). Annotated files have a
`part '<name>.freezed.dart';` line; the generator fills it in. See
`lib/core/reference/freezed_example.dart` for the two patterns (data class and
sealed union) to copy. Existing hand-written models are left as they are; we do
not retrofit them.

After editing an annotated file, regenerate:

```bash
fvm dart run build_runner build        # one-off
fvm dart run build_runner watch        # while developing
```

Generated `*.freezed.dart` (and later `*.g.dart`) files are committed, so the
app builds straight after a checkout without anyone needing to run the
generator first. Regenerate and commit the result whenever you change an
annotated file. The analyzer ignores generated files (see
`analysis_options.yaml`).

## Continuous integration

Every push and pull request to `main` runs the quality gate in
`.github/workflows/ci.yml`. It mirrors the local checks, so a green CI means
the change follows the team guidelines:

- **flutter** job: pins the Flutter version from `.fvmrc`, then
  `pub get --enforce-lockfile`, the Firestore paths check (see below),
  `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos`, a
  check that committed Freezed output is up to date, and `flutter test`.
- **firestore-rules** job: runs the `test_firebase` rules tests against the
  Firestore emulator (self-managed by `firebase-tools`, no device).
- **e2e** job (pushes to `main` and manual runs only, not pull requests):
  boots an Android emulator with
  [android-emulator-runner](https://github.com/ReactiveCircus/android-emulator-runner),
  starts and seeds the Firebase emulators with `firebase emulators:exec`, and
  runs `patrol test`. The setup follows Google's
  [Now in Android](https://github.com/android/nowinandroid) workflow
  (`free-disk-space`, `.github/ci-gradle.properties`, `setup-gradle`). On
  failure it uploads the Android test reports as the `e2e-reports` artifact.

Firestore collection and document paths must go through the constants in
`lib/core/firebase/firestore_paths.dart`, so each path lives in one place and
stays in step with `firestore.rules`. `tool/check_firestore_paths.dart` fails
if any file under `lib/` passes a string literal to `.collection()` or
`.doc()`. It is written in Dart so it runs the same on macOS, Windows and
Linux.

Before pushing, you can run the same checks locally:

```bash
fvm dart run tool/check_firestore_paths.dart
fvm dart format .
fvm flutter analyze --fatal-infos
fvm dart run build_runner build
fvm flutter test
(cd test_firebase && npm test)
```

The end-to-end flow is slower and needs the Firebase emulators, so it is not
in this list. Run it when you change a customer journey (see "End-to-end
tests" above); CI runs it on every push to `main`.
