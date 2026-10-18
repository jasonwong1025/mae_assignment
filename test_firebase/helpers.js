import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import {
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";

const here = dirname(fileURLToPath(import.meta.url));

// Matches the project id used everywhere else so the emulator UI and the
// Flutter app share one project.
export const PROJECT_ID = "mae-assignment-grocerly";

// The emulator ports from firebase.json.
const FIRESTORE_PORT = 8085;
const STORAGE_PORT = 9199;

/**
 * Boots one test environment loaded with the real firestore.rules. Reuse it
 * across a file's tests and clear data between them (see setup.js).
 */
export function newTestEnv() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(join(here, "..", "firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: FIRESTORE_PORT,
    },
    storage: {
      rules: readFileSync(join(here, "..", "storage.rules"), "utf8"),
      host: "127.0.0.1",
      port: STORAGE_PORT,
    },
  });
}

/**
 * A signed-in user's Firestore handle. `email` is put on the auth token so
 * rules that compare against request.auth.token.email can be exercised.
 */
export function firestoreForUser(testEnv, uid, email) {
  return testEnv
    .authenticatedContext(uid, email ? { email } : undefined)
    .firestore();
}

/** A signed-in user's Storage handle. */
export function storageForUser(testEnv, uid, email) {
  return testEnv
    .authenticatedContext(uid, email ? { email } : undefined)
    .storage();
}

/** A signed-out visitor's Storage handle. */
export function storageForGuest(testEnv) {
  return testEnv.unauthenticatedContext().storage();
}

/** A signed-out visitor's Firestore handle. */
export function firestoreForGuest(testEnv) {
  return testEnv.unauthenticatedContext().firestore();
}

/**
 * Seeds data with rules disabled, so tests start from a known state without
 * fighting the rules they are about to check.
 */
export function seed(testEnv, work) {
  return testEnv.withSecurityRulesDisabled((context) =>
    work(context.firestore())
  );
}
