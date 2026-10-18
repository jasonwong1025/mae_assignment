# Grocerly

Flutter app for grocery ordering and fulfilment. The app currently supports onboarding and customer email/password registration and sign-in; the home screen is a placeholder.

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

### 3. End-to-end tests (Patrol, device + emulator)

Patrol drives the real app on a device against the emulators, including native
UI such as the Google sign-in dialog. This is the slow, device-dependent layer,
reserved for a few whole-journey checks rather than everyday logic coverage.
The app only talks to the emulators when started with
`--dart-define=USE_FIREBASE_EMULATOR=true`; a normal run and every release build
use the real backend. An Android emulator image reaches the host emulators on
`10.0.2.2` with no network setup; a physical device needs the host's LAN
address via `--dart-define=FIREBASE_EMULATOR_HOST=<host-ip>`.

Flows live in `integration_test/`. The first is the customer order journey
(`customer_journey_test.dart`): sign in, browse, add to cart, place a delivery
order, and track it. Patrol version pairing follows the
[compatibility table](https://patrol.leancode.co/documentation/compatibility-table)
(`patrol` in `pubspec.yaml` with `patrol_cli` installed separately). The native
runner lives in `android/app/src/androidTest/`.

Install the Patrol CLI once (`dart pub global activate patrol_cli`), then:

```bash
# 1. Start the emulators (Auth + Firestore).
cd test_firebase
npx firebase emulators:start --only auth,firestore --project mae-assignment-grocerly

# 2. In another shell, seed the emulator with the catalogue and a test
#    customer (an auth account plus one saved address). The --with-customer
#    flag is refused against the real project.
cd test_firebase
FIRESTORE_EMULATOR_HOST=localhost:8085 \
FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
node seed.mjs --with-customer

# 3. With a device/emulator connected, run the flow. An Android AVD reaches
#    the host on 10.0.2.2 automatically; a physical device needs the host ip.
patrol test --target integration_test/customer_journey_test.dart \
  --dart-define=USE_FIREBASE_EMULATOR=true
#   physical device: add --dart-define=FIREBASE_EMULATOR_HOST=<host-ip>
```

Patrol generates `integration_test/test_bundle.dart` on each run; it is
git-ignored and must not be committed.

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

Patrol end-to-end tests are not in CI yet; they need a device or emulator and
are run manually.
