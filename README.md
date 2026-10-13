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

```bash
fvm flutter test
```

Tests use fakes and do not connect to Firebase. Change `.fvmrc`, the Flutter constraint in `pubspec.yaml`, and `pubspec.lock` together when the team intentionally upgrades Flutter.
