# Grocerly

Flutter app for grocery ordering and fulfilment. The customer app supports
onboarding, account access, catalogue browsing and checkout. Store Admin and
Store Worker work on the same Firestore data (orders, staff, reviews), and the
demo data comes from the seed script in `test_firebase/`, not from the app.

The deployed HQ admin website and customer/worker Android APK are listed in
[DEPLOYMENT.md](DEPLOYMENT.md). They use the existing Grocerly Dev Firebase
project and do not require a local emulator or terminal to run.

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

Android, Web and iOS Firebase app configuration files are present. An iOS
build and sign-in smoke test still require a Mac with Xcode. The ML Kit
document scanner is Android-only; on iOS and Web the Grocery tab offers manual
entry without a scan button. The Windows desktop runner is not configured.
Driver location sharing uses while-in-use permission while the delivery detail
screen is open; Android background location is not supported.

## Demo data and logins

The apps contain no sample data. Branches, the catalogue, Store Workers, orders
in every state, driver positions, and about 35 days of completed orders and
reviews are written to Firestore by `test_firebase/seed.mjs` (data in
`test_firebase/seed-data/`). Re-running it is safe: it overwrites the same
documents and moves the "minutes ago" times to now. Product image links are
preserved when the catalogue is seeded again.

```bash
cd test_firebase
npm install                       # first time only
node seed.mjs                     # the real project (needs gcloud login)
node seed.mjs --catalogue-only    # only branches, categories and products
```

### Reset demo activity

The reset tool previews its changes by default. From `test_firebase/`, run:

```bash
npm run demo:reset
npm run demo:reset -- --apply --confirm-project=mae-assignment-grocerly --seed-orders
```

The second command deletes orders, reviews, carts, grocery lists, notifications,
simulated wallet balances and transaction history, and order delivery proof
photos. It then adds 40 sample orders for the Orders and Dispatch screens,
without recreating the 35-day sales/review history. Omit `--seed-orders` to
start with an empty order board. It keeps Auth accounts, user profiles and
addresses, canonical catalogue branches and their inventory, driver locations,
device tokens, product photos, and the order-number counter. Duplicate branches
with the same name as a seeded branch are removed together with their inventory,
unless a preserved account is still assigned to one. Run it while nobody is placing
orders or using the demo; it cannot undo deleted activity. The confirmation
flag must name the existing Grocerly Dev project.

Ten generic catalogue photos are stored in `test_firebase/product-images/`.
To restore their Storage files and Firestore links, run `npm run images:upload`
for a preview and then:

```bash
npm run images:upload -- --apply --confirm-project=mae-assignment-grocerly
```

Store Worker logins (every account uses the password `Worker123!`). There is
one **Log in** button for every role: the app reads the account's role from
its profile and opens that role's home, so nobody picks a role. The hosted web
build is the HQ console and only lets Store Admin accounts in.

| Role | Email | Branch |
| --- | --- | --- |
| Packing Staff | `daniel.lee@grocerly.my`, `hakim.roslan@grocerly.my`, `bryan.ong@grocerly.my` | SS15 Subang |
| Packing Staff | `hafiz.zainal@grocerly.my` | Bukit Jalil |
| Packing Staff | `syafiq.azman@grocerly.my` | Puchong |
| Delivery Driver | `amir.hamzah@grocerly.my`, `firdaus.rahim@grocerly.my`, `lau.weijie@grocerly.my`, `weijie.tan@grocerly.my`, `kumar.selvam@grocerly.my`, `azlan.shah@grocerly.my`, `jason.tan@grocerly.my`, `marcus.ho@grocerly.my` | All |
| Deactivated (cannot sign in) | `nadia.yusof@grocerly.my`, `ridzuan.ali@grocerly.my` | |

These are demo accounts on the shared project. Change or delete them in the
Firebase console before using real data.

## Firebase maintenance

Only a maintainer who changes Firebase apps, Authentication, or Firestore rules needs the [Firebase CLI](https://firebase.google.com/docs/cli), [Google Cloud CLI](https://docs.cloud.google.com/sdk/docs/install), and FlutterFire CLI. Sign in to an account with access to `mae-assignment-grocerly`, then run:

```bash
firebase login
gcloud auth login
dart pub global activate flutterfire_cli
fvm exec dart run tool/setup_firebase.dart
```

The script uses the project ID in `.firebaserc`. It reuses existing Firebase apps and the Firestore database, configures Android and Web, also configures iOS on macOS, enables email/password sign-in, and deploys `firestore.rules`. The trusted checkout and staff actions additionally require deploying `functions/`; use `npm ci --prefix functions`, `npm run build --prefix functions`, then `firebase deploy --only functions,firestore:rules` from the repository root with the project maintainer's account. Deploy Functions and Rules together because direct client order creation and staff provisioning are denied by the new Rules. Commit any updated `firebase.json`, `lib/firebase_options.dart`, platform configuration files, and rules after reviewing them. Firebase and Google Cloud login credentials stay in each maintainer's home directory.

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

### 2. Security Rules tests (Firebase Emulator Suite)

The real `firestore.rules` and `storage.rules` cannot be faked, so they are
tested against the Firestore and Storage emulators with
`@firebase/rules-unit-testing`. The emulator starts and
stops itself; this needs Node and Java (both expected by the Firebase CLI) but
no device, and works the same on every OS. Emulator ports live in the
`emulators` block of `firebase.json`.

```bash
cd test_firebase
npm install          # first time only
npm test             # starts the emulator, runs the tests, shuts it down
```

The callable Functions have separate emulator tests for checkout pricing,
stock reservation, cancellation and staff authorization:

```bash
npm ci --prefix functions
npm run build --prefix functions
npm run test:functions --prefix test_firebase
```

The Functions tests also cover the wallet (top up, payment, refunds,
shortage settlement) and the notification triggers.

### Wallet, notifications and recipe suggestions

- **Wallet.** Orders are paid from a simulated Grocerly Wallet (Account >
  Wallet). New customers start with RM 0 and top up (RM 1 to 500 at a time);
  no real money moves. Only the Cloud Functions change balances, so the rules
  deny every client write. See `DATABASE/FIRESTORE.md`.
- **Notifications.** Account > Notifications is an in-app inbox, filled by a
  Cloud Function when an order changes. The same events are also sent as push
  notifications through Firebase Cloud Messaging (the app asks for permission
  after sign-in). Push needs the deployed Functions and a real device or an
  emulator with Google Play services; the Firebase emulators cannot send
  pushes, so the inbox entry is what the automated tests check. iOS push also
  needs an APNs key uploaded in the Firebase console and a Mac to build.
- **Recipe to ingredients.** Grocery > "Ingredients from a recipe" asks Gemini
  (through Firebase AI Logic, so there is no API key in the app) for a
  shopping list, which the customer reviews before it joins the list. In the
  Firebase console open *Build > AI Logic*, press *Get started* and choose the
  Gemini Developer API (no billing plan needed for the Flash models). Enabling
  App Check there limits who can call it. The model name is
  `gemini-3.8-flash`; Google retires models on a schedule, so change it
  without code edits with `--dart-define=GEMINI_MODEL=<name>`. It is not
  available against the emulators.


### 3. End-to-end tests (Patrol, Android emulator + Firebase emulators)

[Patrol](https://patrol.leancode.co) drives the real app on an Android
emulator against the Firebase emulators, including native UI. This is the
slow layer, kept to a few whole-journey checks. Tests live in `patrol_test/`
(Patrol's default folder); the first is the customer order journey
(`customer_journey_test.dart`): sign in, browse, add to cart, open the product
details, restart the app and find the saved cart restored, place a delivery
order, track it, cancel it and order it again. The second is the staff
journey (`staff_journey_test.dart`): the admin assigns a packer, the packer
starts the order, and the admin sees it being packed. The third is the shortage
journey (`shortage_journey_test.dart`): a packer offers a replacement for an
unavailable item, the customer accepts it, and the packer carries on and can
mark the order ready. Run them with the Functions emulator on, as in CI, since
checking out calls a Cloud Function. The seed script empties the test customer's saved cart, so
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
# 1. Build Functions and start the Firebase emulators.
cd ..
npm run build --prefix functions
cd test_firebase
npx firebase emulators:start --only auth,firestore,functions,storage --project mae-assignment-grocerly

# 2. In another shell, start your Android emulator (Device Manager, or:
#    fvm flutter emulators --launch <id>), then run the E2E command.
#    It seeds the catalogue, staff, orders, test customer and admin before
#    every run, because these journeys change the saved cart and order #2287.
cd test_firebase
npm run e2e -- emulator-5554
```

Use an emulator for E2E and keep your phone for everyday `fvm flutter run`.
Patrol uninstalls the app after each run. It generates
`patrol_test/test_bundle.dart`, which is git-ignored and must not be
committed. Android Test Orchestrator runs each journey in its own
instrumentation process and clears app data between journeys; it does not
clear the Firebase emulator. To run one journey with `patrol test --target`,
seed first using the command above or rerun
`node seed.mjs --with-customer` from `test_firebase/` with
`FIRESTORE_EMULATOR_HOST=localhost:8085` and
`FIREBASE_AUTH_EMULATOR_HOST=localhost:9099`.

## Code conventions

Everyone writes code the same way, and the rules are enforced by tools (see
"Continuous integration"), not by memory. The reference for the shapes below is
`lib/core/reference/freezed_example.dart`; the database is described in
[`DATABASE/FIRESTORE.md`](DATABASE/FIRESTORE.md).

### Layout and layers

```
lib/features/<role>/<feature>/
  data/{models, services, repositories}
  presentation/{views, ui, view_models}
lib/shared/{models, services, repositories, ui}     used by more than one role
lib/core/                                            app-wide infrastructure
```

Data flows one way: **view -> view model -> repository -> service -> Firestore**.

- **Views and widgets** (`presentation/views`, `presentation/ui`, `shared/ui`)
  show state and call view-model methods. They never import a Firebase package
  or a service. Device-only services (camera, launcher, printing, image picker)
  are the one exception.
- **View models** are Riverpod notifiers. They hold screen state and call
  repositories.
- **Repositories** turn failures into friendly errors and combine services.
- **Services** are the only code that talks to Firebase. One service per
  collection or SDK.
- **Models** hold data and small derived values. They never import Firebase.

### Models and state: always Freezed

Every class in a `models/` folder, and every view-model state or filter, is a
Freezed class (`@freezed abstract class`), so equality, `copyWith` and
`toString` behave the same everywhere. Update state with `copyWith`:

```dart
state = state.copyWith(searchText: text, page: 1);
```

A model stored in Firestore also has its mapping written by hand, the way
Firebase's own documentation shows it, so the field names come from
`firestore_paths.dart`, the single schema, instead of being implied by property
names:

- A document with an id has `fromFirestore(id, data)` and `toFirestore()`. A
  nested value (an array entry) or a document with no id of its own has
  `fromMap(map)` and `toMap()`.
- Read fields with the `FieldReaders` extension
  (`lib/core/firebase/field_readers.dart`): `data.string(...)`,
  `data.dateTime(...)`, `data.latLng(...)`. Plain readers fall back to a default
  so an older document still loads; `required...` readers throw, so a broken
  document is skipped instead of shown half empty.
- The document id is never written as a field. Server times are read but never
  written by the model; the service adds `FieldValue.serverTimestamp()`.
- Every document model gets a round-trip test (see
  `test/core/model_mapping_test.dart`).

### Firestore access

- Collection and field names live in `lib/core/firebase/firestore_paths.dart`.
- **Every path is built in `FirestoreRefs`** (`firestore_refs.dart`). Services
  call `_refs.orders`, `_refs.address(uid, id)`; they never chain
  `.collection().doc()` or read `FirebaseFirestore.instance`.
- Read documents with `snapshot.toModel(fromFirestore: Model.fromFirestore)` and
  `querySnapshot.toModels(fromFirestore: ...)`. They pass the document id and
  skip malformed documents. Write `{...model.toFirestore(), 'createdAt':
  FieldValue.serverTimestamp()}`; never write a server time from the client.
- Apply `FirestoreConfig.readTimeout` to every `get()`.
- Changing a collection means changing `firestore.rules`, its test and
  `DATABASE/FIRESTORE.md` together.

### Errors

A repository declares one exception per feature, extending `AppException`
(`lib/core/errors/app_exception.dart`), and wraps its backend calls in the
shared `guard(...)` instead of writing its own try/catch:

```dart
class OrderException extends AppException {
  const OrderException(super.message);
}

Future<T> _run<T>(Future<T> Function() call) => guard(
  call,
  label: 'order',
  onError: () => const OrderException(kNetworkErrorMessage),
);
```

The message is always safe to show on screen. Raw errors are logged, never
shown.

### Riverpod

- Providers that must outlive a tab (selected branch, cart, session) are not
  `autoDispose`; screen-scoped state is.
- A provider that reads Firestore and can fail sets `retry: (_, _) => null`, so
  the screen shows its "Try again" button instead of retrying silently.
- No side effects in `build`, and no navigation from `ref.listen`; await the
  action, then navigate.
- `riverpod_lint` runs with the analyzer (see "Continuous integration").

### Tests

A change that adds behaviour adds tests next to the existing ones: a
Firestore model gets a round-trip test, a service gets a test on
`fake_cloud_firestore`, a repository or view model gets a test with fakes or
`mocktail`, and a rule change gets a rules test in `test_firebase/`.
`test/core/model_mapping_test.dart` fails if a model writes a field that
`firestore_paths.dart` does not name, or does not read back what it writes.

### Adding a feature

Use the Mason brick instead of copying a neighbouring feature, so the new code
starts in the right shape. One-time setup:

```bash
dart pub global activate mason_cli
mason get
```

1. Add the collection to `FirestoreCollections` and a getter to `FirestoreRefs`.
2. Generate the model, service, repository, view model and service test:

   ```bash
   mason make feature --name review --feature reviews --role customer --collection reviews
   ```

   (`--role` is `customer`, `store_admin` or `store_worker`; `--collection` is
   the `FirestoreRefs` getter. Omit the flags to be prompted.)
3. Generate the model code and format: `fvm dart run build_runner build`.
4. Add the field names to `firestore_paths.dart`, the rules (and their test),
   and `DATABASE/FIRESTORE.md`.

## Code generation

Freezed generates the model code. Annotated files have
`part '<name>.freezed.dart';`; the generator fills it in.

After editing an annotated file, regenerate:

```bash
fvm dart run build_runner build        # one-off
fvm dart run build_runner watch        # while developing
```

Generated `*.freezed.dart` files are committed, so the app builds straight after
a checkout without anyone needing to run the generator first. Regenerate and
commit the result whenever you change an annotated file; CI fails if it is
stale. The analyzer ignores generated files (see `analysis_options.yaml`).

## Continuous integration

Every push and pull request to `main` runs the quality gate in
`.github/workflows/ci.yml`. It mirrors the local checks, so a green CI means
the change follows the team guidelines:

- **flutter** job: pins the Flutter version from `.fvmrc`, then
  `pub get --enforce-lockfile`, the Firestore paths check and the architecture
  check (see below), `dart format --set-exit-if-changed`,
  `dart analyze --fatal-infos` (this also runs the `riverpod_lint` plugin, which
  `flutter analyze` does not), a check that committed generated code is up to
  date, and `flutter test`.
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

Two Dart scripts in `tool/` (cross-platform, no shell) guard the conventions
above:

- `tool/check_firestore_paths.dart` fails if a Firestore path is built anywhere
  except `FirestoreRefs`: a `.collection(...)` call, a string-literal `.doc('x')`
  or `FirebaseFirestore.instance` outside `firestore_refs.dart`.
- `tool/check_architecture.dart` fails if UI code imports a Firebase package or
  a service, if a class in a `models/` folder or a view-model state/filter is
  not Freezed, or if a repository exception does not extend `AppException`.

Before pushing, you can run the same checks locally:

```bash
fvm dart run tool/check_firestore_paths.dart
fvm dart run tool/check_architecture.dart
fvm dart format --output=none --set-exit-if-changed lib test tool patrol_test
fvm dart analyze --fatal-infos
fvm dart run build_runner build
fvm flutter test
(cd test_firebase && npm test)
```

The end-to-end flow is slower and needs the Firebase emulators, so it is not
in this list. Run it when you change a customer journey (see "End-to-end
tests" above); CI runs it on every push to `main`.
