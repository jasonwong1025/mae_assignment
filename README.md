# Grocerly

Grocery ordering and fulfilment app for local stores (Flutter + Firebase).

## Setup

The app needs a Firebase project. Everyone uses their **own** project, so the
Firebase config files are not in git (see `.gitignore`). You generate them
once on your machine.

### 1. Tools

```bash
npm install -g firebase-tools        # Firebase CLI
dart pub global activate flutterfire_cli
firebase login
```

### 2. Firebase project (in the Firebase Console)

1. Create a project (the free Spark plan is enough).
2. **Authentication**: Sign-in method, enable **Email/Password**.
3. **Firestore Database**: create the `(default)` database
   (we use `asia-southeast1`, Singapore).

### 3. Connect the app to your project

From the project folder:

```bash
flutter pub get
flutterfire configure --project=<your-project-id> --platforms=android,ios,web
```

This creates (only on your machine):

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`

### 4. Deploy the Firestore security rules

Open `firebase.json` and add the `"firestore"` entry next to `"flutter"`:

```json
{
  "flutter": { "...": "left as generated" },
  "firestore": { "rules": "firestore.rules" }
}
```

Then:

```bash
firebase deploy --only firestore:rules --project <your-project-id>
```

Without this step the database blocks every write and sign-up fails.

### 5. Run

```bash
flutter run
```

If the build says `lib/firebase_options.dart` or `google-services.json` is
missing, step 3 has not been done yet.

## Tests

```bash
flutter test
```

Tests use fakes instead of Firebase, so they run without step 3.
