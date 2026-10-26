# Grocerly Dev deployment

Grocerly runs on the existing Firebase project `mae-assignment-grocerly`.
No local terminal or Firebase Emulator Suite is needed to use the deployed apps.

| Component | Location |
| --- | --- |
| HQ admin website | https://mae-assignment-grocerly.web.app |
| Customer and worker Android APK | https://mae-assignment-grocerly.web.app/downloads/grocerly.apk |
| Android package | `com.example.mae_assignment` |
| Backend | Firebase Auth, Firestore, Storage, and eight Cloud Functions in `asia-southeast1` |

The same APK serves customers and workers. Sign in with the appropriate role.
The web build is for HQ admins. Existing demo accounts and data remain in the
shared Grocerly Dev project.

## Android signing and updates

The Android release signing files are private and ignored by Git:

- `android/app/grocerly-release.jks`
- `android/key.properties`

Back up both files securely. Future APK updates must use the same signing key.
The registered release certificate SHA-256 is
`e2730b2f9c524a39186d4e6ff7f750eb503421dbfc381a10421c812dffe7e95f`.
Do not upload the keystore or `key.properties` to source control.

The terminal debug build and signed release APK use the same Android package
name. Android cannot keep both installed together. Remove the debug build once
before installing the release APK; later release updates can install over this
release copy using the same signing key.

## Continuous deployment

The [CD workflow](.github/workflows/cd.yml) publishes the latest `main` commit
after its push-triggered CI run passes, including the Android end-to-end test.
It builds a signed release APK and the HQ web app, then deploys Cloud Functions,
Firestore rules and indexes, Storage rules, and Firebase Hosting to the existing
Grocerly Dev project. The hosted APK is replaced at the download URL above.
The same APK is also retained as a GitHub Actions artifact for 14 days. No
local terminal needs to stay open for either the deployment or the live apps.

The workflow uses GitHub's short-lived OpenID Connect credentials to impersonate
`grocerly-github-deploy@mae-assignment-grocerly.iam.gserviceaccount.com` through
the `grocerly-github/main-cd` Workload Identity provider. Its provider condition
limits access to this repository's `cd.yml` on `main`. The repository's Actions
secrets are:

| Secret | Purpose |
| --- | --- |
| `GROCERLY_WIF_PROVIDER` | Google Workload Identity provider resource name |
| `GROCERLY_DEPLOY_SERVICE_ACCOUNT` | Deployment service account email |
| `GROCERLY_ANDROID_KEYSTORE_BASE64` | Base64-encoded private release keystore |
| `GROCERLY_ANDROID_KEY_PROPERTIES_BASE64` | Base64-encoded private signing properties |

Never print or commit either signing secret. If the signing files change, update
the two secrets together and confirm that the release certificate still matches
the SHA-256 above. Android updates also need a higher `version` build number in
`pubspec.yaml` so devices can install them over the existing release.

To rerun a deployment, use **Actions > CD > Run workflow** on `main`. Manual
runs deploy only the current `main` commit after that commit has passed CI.
The workflow skips older CI completions when a newer commit is already on
`main`. A failing build or deploy stops before the website is published.

## Publish an update manually

Run from the repository root after testing the changes:

```bash
fvm flutter build apk --release
fvm flutter build web --release
mkdir -p build/web/downloads
cp build/app/outputs/flutter-apk/app-release.apk build/web/downloads/grocerly.apk
firebase deploy --only functions,firestore:rules,firestore:indexes,storage,hosting --project mae-assignment-grocerly
```

Increase `version` in `pubspec.yaml` for an Android update. Keep the private
signing files in place. The hosted APK is copied into `build/web` after each
web build because Flutter can replace that directory.

Firebase App Check is configured for the sideloaded Android APK using
reCAPTCHA Enterprise. App Check is enforced for Firebase AI Logic. If the
Android package name or signing key changes, update the Firebase Android app
registration and reCAPTCHA key before publishing another APK.
An emulator or debug build needs a registered App Check debug token to call
Firebase AI Logic while enforcement is enabled.

The live project uses the Blaze plan. Monitor Firebase and Google Cloud usage
and billing in the project consoles. A Google Cloud budget sends alerts; it
does not automatically stop charges.
