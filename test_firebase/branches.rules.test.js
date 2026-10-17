import { beforeEach, describe, test } from "vitest";
import {
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from "firebase/firestore";
import { firestoreForGuest, firestoreForUser, seed } from "./helpers.js";

const ADMIN = { uid: "admin", email: "admin@example.com" };
const CUSTOMER = { uid: "alice", email: "alice@example.com" };

/** A branch document like the Flutter app writes it (fields trimmed). */
const BRANCH = { name: "SS15 Subang", isTemporarilyClosed: false };

let testEnv;
beforeEach(async () => {
  testEnv = globalThis.__TEST_ENV__;
  // The rules look up the caller's role in users/{uid}.
  await seed(testEnv, async (db) => {
    await setDoc(doc(db, "users", ADMIN.uid), { role: "storeAdmin" });
    await setDoc(doc(db, "users", CUSTOMER.uid), { role: "customer" });
    await setDoc(doc(db, "branches", "ss15"), BRANCH);
  });
});

describe("branches/{branchId}", () => {
  test("signed-in users can read branches", async () => {
    const db = firestoreForUser(testEnv, CUSTOMER.uid, CUSTOMER.email);
    await assertSucceeds(getDoc(doc(db, "branches", "ss15")));
  });

  test("signed-out visitors cannot read branches", async () => {
    const db = firestoreForGuest(testEnv);
    await assertFails(getDoc(doc(db, "branches", "ss15")));
  });

  test("admin can add and edit a branch", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertSucceeds(setDoc(doc(db, "branches", "puchong"), BRANCH));
    await assertSucceeds(
      updateDoc(doc(db, "branches", "ss15"), { isTemporarilyClosed: true })
    );
  });

  test("customers cannot add or edit a branch", async () => {
    const db = firestoreForUser(testEnv, CUSTOMER.uid, CUSTOMER.email);
    await assertFails(setDoc(doc(db, "branches", "puchong"), BRANCH));
    await assertFails(
      updateDoc(doc(db, "branches", "ss15"), { isTemporarilyClosed: true })
    );
  });

  test("nobody can delete a branch", async () => {
    const db = firestoreForUser(testEnv, ADMIN.uid, ADMIN.email);
    await assertFails(deleteDoc(doc(db, "branches", "ss15")));
  });
});
