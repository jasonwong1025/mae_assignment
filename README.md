# Grocerly

Grocery ordering and fulfilment app for local stores (Flutter + Firebase).

## Setup

The app needs a Firebase project. Everyone uses their **own** project.
The Firebase settings live in a `.env` file on your machine (not in git);
`lib/firebase_options.dart` reads them when the app starts.

### 1. Firebase project (in the Firebase Console)

1. Create a project (the free Spark plan is enough).
2. **Authentication**: Sign-in method, enable **Email/Password**.
3. **Firestore Database**: create the `(default)` database
   (we use `asia-southeast1`, Singapore).
4. **Project settings, Your apps**: add three apps:
   - Android, package name `com.example.mae_assignment`
   - iOS, bundle ID `com.example.maeAssignment`
   - Web

   You can skip downloading `google-services.json` / `GoogleService-Info.plist`;
   the app does not use them.

### 2. Fill in `.env`

```bash
cp .env.example .env
```

Copy each value from **Project settings, Your apps** (select the app, then
"SDK setup and configuration", "Config"). The names match:

| `.env` | Where to find it |
|---|---|
| `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_STORAGE_BUCKET` | Any app's config: `projectId`, `messagingSenderId`, `storageBucket` |
| `FIREBASE_WEB_*` | Web app: `apiKey`, `appId`, `authDomain` |
| `FIREBASE_ANDROID_*` | Android app: `apiKey` (`current_key`), `appId` (`mobilesdk_app_id`) |
| `FIREBASE_IOS_*` | iOS app: `API_KEY`, `GOOGLE_APP_ID`, `BUNDLE_ID`, `CLIENT_ID` |

Shortcut with the Firebase CLI (`npm install -g firebase-tools`, then
`firebase login`):

```bash
firebase apps:list --project <your-project-id>
firebase apps:sdkconfig ANDROID <android-app-id> --project <your-project-id>
firebase apps:sdkconfig IOS <ios-app-id> --project <your-project-id>
firebase apps:sdkconfig WEB <web-app-id> --project <your-project-id>
```

Do **not** run `flutterfire configure`: it would overwrite
`lib/firebase_options.dart` with hard-coded values.

### 3. Deploy the Firestore security rules

```bash
firebase deploy --only firestore:rules --project <your-project-id>
```

Without this step the database blocks every write and sign-up fails.

### 4. Run

The app must be started with the `.env` file:

```bash
flutter pub get
flutter run --dart-define-from-file=.env
```

In VS Code, the "Grocerly" launch config (`.vscode/launch.json`) adds this
for you. In Android Studio, add `--dart-define-from-file=.env` to
"Additional run args" in the run configuration.

If the app stops at start-up with "Firebase settings are missing", the
`.env` file is missing or the flag was not passed.

## Tests

```bash
flutter test
```

Tests use fakes instead of Firebase, so they run without a `.env` file.
